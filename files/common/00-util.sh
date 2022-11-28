#!/usr/bin/env bash

echo "  started ..... $(date)"

function verify_pod_running() {

    POD_NAME_TEXT=$1
    POD_STATUS_TEXT=$2

    export GLOBAL_POD_VERIFY_STATUS=false

    echo "----------------------------------------------------------------------"
    echo "Verify POD Running... (pod : $POD_NAME_TEXT) "
    echo "----------------------------------------------------------------------"
    # echo "Executing the below command ...."
    echo "oc get pods -n ${NAMESPACE} | grep ${POD_NAME_TEXT} | grep -c '${POD_STATUS_TEXT}'"

    MAX_LOOP_COUNT=50
    RESOURCE_COUNT=0
    RESOURCE_FOUND=false
    LOOP_COUNT=0

    while [[ ${RESOURCE_FOUND} == "false" && $LOOP_COUNT -lt $MAX_LOOP_COUNT ]]; do
        LOOP_COUNT=$((LOOP_COUNT+1))
        echo "Trying for $LOOP_COUNT / $MAX_LOOP_COUNT."

        RESOURCE_COUNT=$(oc get pods -n ${NAMESPACE} | grep ${POD_NAME_TEXT} | grep -c "${POD_STATUS_TEXT}")
        echo "RESOURCE_COUNT : $RESOURCE_COUNT"

        if [[ $RESOURCE_COUNT -gt 0 ]]; 
        then
            RESOURCE_FOUND=true
        else
            RESOURCE_FOUND=false
            sleep 5
        fi
    done

    if [[ $RESOURCE_FOUND == "true" ]]; 
    then
        echo "POD found ($POD_NAME_TEXT pod) with the status ($POD_STATUS_TEXT pod)"
        export GLOBAL_POD_VERIFY_STATUS=true
    else
        echo "POD not found ($POD_NAME_TEXT pod) with the status ($POD_STATUS_TEXT pod). Terminating.. Retry the install"
        export GLOBAL_POD_VERIFY_STATUS=false
    fi

    echo "Verify Status : ${GLOBAL_POD_VERIFY_STATUS} "
}

function verify_resource() {

    RESOURCE_TEXT=$1
    RESOURCE_NAME_TEXT=$2

    export GLOBAL_RESOURCE_VERIFY_STATUS=false

    echo "----------------------------------------------------------------------"
    echo "Verify Resource Running... (Resource : $RESOURCE_TEXT     : $RESOURCE_NAME_TEXT) "
    echo "----------------------------------------------------------------------"
    # echo "Executing the below command ...."
    echo "oc get $RESOURCE_TEXT -n ${NAMESPACE} | grep -c ${RESOURCE_NAME_TEXT} "

    MAX_LOOP_COUNT=50
    RESOURCE_COUNT=0
    RESOURCE_FOUND=false
    LOOP_COUNT=0

    while [[ ${RESOURCE_FOUND} == "false" && $LOOP_COUNT -lt $MAX_LOOP_COUNT ]]; do
        LOOP_COUNT=$((LOOP_COUNT+1))
        echo "Trying for $LOOP_COUNT / $MAX_LOOP_COUNT."

        RESOURCE_COUNT=$(oc get ${RESOURCE_TEXT} -n ${NAMESPACE} | grep -c ${RESOURCE_NAME_TEXT})
        echo "RESOURCE_COUNT : $RESOURCE_COUNT"

        if [[ $RESOURCE_COUNT -gt 0 ]]; 
        then
            RESOURCE_FOUND=true
        else
            RESOURCE_FOUND=false
            sleep 5
        fi
    done

    if [[ $RESOURCE_FOUND == "true" ]]; 
    then
        echo "Resource found ($RESOURCE_TEXT : $RESOURCE_NAME_TEXT )"
        export GLOBAL_RESOURCE_VERIFY_STATUS=true
    else
        echo "Resource not found ($RESOURCE_TEXT : $RESOURCE_NAME_TEXT ). Terminating.. Retry the install"
        export GLOBAL_RESOURCE_VERIFY_STATUS=false
    fi

    echo "Verify Status : ${GLOBAL_RESOURCE_VERIFY_STATUS} "
}
