#!/usr/bin/env bash

function install_probe() {

echo "-----------------------------------"
echo "3.1 Gather AI Manager ObjectServer connection information ..."
echo "-----------------------------------"

### 1. Set the AI Manager namespace variable.
IRC_NAMESPACE=$NAMESPACE

### 2. Determine the Issue Resolution Core instance name.
IRC_INSTANCE=$(kubectl get issueresolutioncore -n $IRC_NAMESPACE -o custom-columns=name:metadata.name --no-headers)

### 3. Gather service information and credentials.
IRC_PRIMARY_OBJECTSERVER_SVC=$IRC_INSTANCE-ir-core-ncoprimary
IRC_BACKUP_OBJECTSERVER_SVC=$IRC_INSTANCE-ir-core-ncobackup
IRC_PRIMARY_OBJECTSERVER_PORT=$(kubectl get svc -n $IRC_NAMESPACE $IRC_PRIMARY_OBJECTSERVER_SVC -o jsonpath='{.spec.ports[?(@.name=="primary-tds-port")].port}')
IRC_BACKUP_OBJECTSERVER_PORT=$(kubectl get svc -n $IRC_NAMESPACE $IRC_BACKUP_OBJECTSERVER_SVC -o jsonpath='{.spec.ports[?(@.name=="backup-tds-port")].port}')
IRC_OMNI_USERNAME=aiopsprobe
IRC_OMNI_PASSWORD=$(kubectl get secret -n $IRC_NAMESPACE $IRC_INSTANCE-ir-core-omni-secret -o jsonpath='{.data.OMNIBUS_PROBE_PASSWORD}' | base64 --decode && echo)

### 4. Extract the ObjectServer TLS certificate 
oc extract secret/$IRC_INSTANCE-ir-core-ncoprimary-tls -n $IRC_NAMESPACE --to=. --keys=tls.crt


echo "-----------------------------------"
echo "3.2 Create Secrets for ObjectServer credentials ."
echo "-----------------------------------"

### 1. Create a secret with the ObjectServer credentials for the probe to authenticate with the ObjectServer.
PROBE_OMNI_SECRET=noi-probe-secret
oc create secret generic $PROBE_OMNI_SECRET -n $IRC_NAMESPACE --from-literal=AuthUserName=$IRC_OMNI_USERNAME  --from-literal=AuthPassword=$IRC_OMNI_PASSWORD

### 2. Create a secret for the probe to use for basic authentication.
PROBE_AUTH_SECRET=sevone-probe-client-basic-auth
oc create secret generic $PROBE_AUTH_SECRET -n $IRC_NAMESPACE --from-literal=serverBasicAuthenticationUsername=$WEBHOOK_USER  --from-literal=serverBasicAuthenticationPassword=$WEBHOOK_PASSWORD

### 3. Create a Network Policy in the IBM Cloud Pak Watson AI Ops namespace.
echo "-----------------------------------"
echo "3.3. Create a Network Policy ..."
echo "-----------------------------------"

cat << EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-allow-objectserver
  namespace: ${IRC_NAMESPACE}
spec:
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: noi-integrations
    ports:
      - protocol: TCP
        port: 4100
  podSelector:
    matchLabels:
      app.kubernetes.io/instance: ${IRC_INSTANCE}
      app.kubernetes.io/managed-by: ir-core-operator
      app.kubernetes.io/name: IssueResolutionCore
  policyTypes:
  - Ingress
EOF

### 4. Create a Probe for Webhook Integrations with the WebhookProbe custom resource.
echo "-----------------------------------"
echo "3.4. Create a Probe for Webhook Integrations with the WebhookProbe custom resource ..."
echo "-----------------------------------"

PROBE_INSTANCE=

cat << EOF | oc apply -f -
apiVersion: probes.integrations.noi.ibm.com/v1
kind: WebhookProbe
metadata:
  name: ${PROBE_INSTANCE}
  labels:
    app.kubernetes.io/name: ${PROBE_INSTANCE}
    app.kubernetes.io/managed-by: netcool-integrations-operator
    app.kubernetes.io/instance: ${PROBE_INSTANCE}
  namespace: ${NAMESPACE}
spec:
  helmValues:
    netcool:
      backupHost: '${IRC_BACKUP_OBJECTSERVER_SVC}.${IRC_NAMESPACE}.svc'
      backupPort: ${IRC_BACKUP_OBJECTSERVER_PORT}
      backupServer: 'AGGB'
      connectionMode: SSLAndAuth
      primaryHost: '${IRC_PRIMARY_OBJECTSERVER_SVC}.${IRC_NAMESPACE}.svc'
      primaryPort: ${IRC_PRIMARY_OBJECTSERVER_PORT}
      primaryServer: 'AGGP'
      secretName: '${PROBE_OMNI_SECRET}'
    probe:
      jsonParserConfig:
        notification:
          jsonNestedHeader: ''
          jsonNestedPayload: ''
          messageDepth: 3
          messageHeader: ''
          messagePayload: json
      integration: sevone
      enableTransportDebugLog: false
      messageLevel: debug
      heartbeatInterval: 10
    ingress:
      enabled: true
      host: ''
    arch: amd64
    webhook:
      uri: /probe/sevone
      serverBasicAuthenticationCredentialsSecretName: '${PROBE_AUTH_SECRET}'
      tls:
        enabled: true
        secretName: ''
  license:
    accept: true
  version: $PROBE_VERSION
EOF

rm tls.crt

echo "Process completed .... "

}

