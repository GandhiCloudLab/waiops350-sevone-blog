#!/usr/bin/env bash

source ./00-config1.sh
source ./00-config2.sh

#### Sample msg
#### Sample NOI event used in the mapping
#### https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.5.0?topic=reference-normalized-alert-mapping-rules

my_main() {

  date1=$(date '+%Y-%m-%d %H:%M:%S')
  echo "******************************************************************************************"
  echo " Pushing clear event to Generic Webhook started ....$date1"
  echo "******************************************************************************************"
  
  DATA_FILE=@./data/my-event-clear.json

  H_CONTENT="Content-Type: application/json"
  H_ACCEEPT="Accept: application/json"

  curl --silent -X POST -v -u $WEBHOOK_USER:$WEBHOOK_PASSWORD -H "$H_ACCEEPT" -H "$H_CONTENT" -d $DATA_FILE $WEBHOOK_URL

  date1=$(date '+%Y-%m-%d %H:%M:%S')
  echo "******************************************************************************************"
  echo "  Pushing clear event to Generic Webhook completed ....$date1"
  echo "******************************************************************************************"
}

my_main



