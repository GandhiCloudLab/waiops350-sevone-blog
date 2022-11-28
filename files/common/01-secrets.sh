#!/usr/bin/env bash

function create_secrets() {
  echo "-----------------------------------"
  echo "1.1 Create a secret for your entitlement key ..."
  echo "-----------------------------------"

  oc create secret docker-registry cp.icr.io \
      --docker-username=cp\
      --docker-password=$ENTITLEMENT_KEY \
      --docker-server=cp.icr.io \
      --namespace=$NAMESPACE

  oc create secret docker-registry ibm-entitlement-key-secret \
      --docker-username=cp\
      --docker-password=$ENTITLEMENT_KEY \
      --docker-server=cp.icr.io \
      --namespace=$NAMESPACE

  echo "-----------------------------------"
  echo "1.2 Create service account for your entitlement key ..."
  echo "-----------------------------------"

cat <<EOF | oc apply -f -
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: sevone-probe-service-account
      namespace: $NAMESPACE
      labels:
        managedByUser: 'true'
    imagePullSecrets:
      - name: cp.icr.io
      - name: ibm-entitlement-key-secret
EOF

  echo "Process completed .... "
}