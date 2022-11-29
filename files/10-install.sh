#!/usr/bin/env bash

source ./00-config1.sh
source ./00-config2.sh

source ./common/00-util.sh
source ./common/01-secrets.sh
source ./common/02-create-subscription.sh
source ./common/03-webhook-probe.sh
source ./common/04-post-install.sh

install_main() {

  date1=$(date '+%Y-%m-%d %H:%M:%S')
  echo "******************************************************************************************"
  echo " Probe integration for IBM SevOne Network Performance Management (NPM) with AI Manager Started ....$date1"
  echo "******************************************************************************************"

  create_secrets
  create_subscription

  verify_pod_running "netcool-integrations-operator" "1/1     Running"
  if [[ $GLOBAL_POD_VERIFY_STATUS == "true" ]]; then 

    install_probe
    verify_resource "sa" "${WEBHOOK_NAME}-mb-webhook-sa"
    if [[ $GLOBAL_RESOURCE_VERIFY_STATUS == "true" ]]; then
        post_install
    fi

  fi
  
  date1=$(date '+%Y-%m-%d %H:%M:%S')
  echo "******************************************************************************************"
  echo " Probe integration for IBM SevOne Network Performance Management (NPM) with AI Manager completed ....$date1"
  echo "******************************************************************************************"
}

install_main

