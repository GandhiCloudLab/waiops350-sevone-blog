#!/usr/bin/env bash

function post_install() {

echo "-----------------------------------"
echo "4.1 Patch ServiceAccount and recreate the pod ${WEBHOOK_NAME}-mb-webhook-server-xxxx-xxxx .... "
echo "-----------------------------------"

PROBE_INSTANCE=$WEBHOOK_NAME
IRC_NAMESPACE=$NAMESPACE

## PATCH serviceaccount
SA_NAME="$PROBE_INSTANCE-mb-webhook-sa"
oc patch -n $NAMESPACE serviceaccount $SA_NAME -p '{"imagePullSecrets": [{"name": "ibm-entitlement-key-secret"}]}'

## Recreate pod
sleep 5
oc delete pod $(oc get po -n $NAMESPACE | grep $WEBHOOK_NAME-mb-webhook-server |awk '{print$1}') -n $NAMESPACE
sleep 5
echo "Make sure that below pod is in running state, before using the webhook"
oc get po -n $NAMESPACE | grep $WEBHOOK_NAME-mb-webhook-server

echo "-----------------------------------"
echo "4.2. Obtain the Probe Webhook URL"
echo "-----------------------------------"
### 1. probe webhook URL
PROBE_HOSTNAME=$(oc get route $PROBE_INSTANCE-mb-webhook -n $IRC_NAMESPACE  -o jsonpath='{.spec.host}')
PROBE_URI=$(oc get route $PROBE_INSTANCE-mb-webhook -n $IRC_NAMESPACE -o jsonpath='{.spec.path}')
PROBE_WEBHOOK_URL=https://$PROBE_HOSTNAME$PROBE_URI

### Print Webhook URL.
echo "================================================================"
echo "WEBHOOK_URL=$PROBE_WEBHOOK_URL"
echo "WEBHOOK_USER=$WEBHOOK_USER"
echo "WEBHOOK_PASSWORD=$WEBHOOK_PASSWORD"

echo "#!/bin/bash" > 00-config2.sh
echo "WEBHOOK_URL=$PROBE_WEBHOOK_URL" >> 00-config2.sh
echo "================================================================"
}
