#!/bin/bash

REGION=$1
TASK_NAME=$2
SERVICE_NAME=$3


OLD_IMAGE==$(aws ecs describe-task-definition --task-definition first-run-task-definition | jq '.taskDefinition | .containerDefinitions[0].image' | tr -d '"')
NEW_IMAGE="435429793199.dkr.ecr.us-east-1.amazonaws.com/mes-rd-test:$BUILD_NUMBER"
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$TASK_NAME" --region "$REGION")
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$NEW_IMAGE" '.taskDefinition | .containerDefinitions[0].image = $OLD_IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')
NEW_REVISION=$(aws ecs register-task-definition --region "$REGION" --cli-input-json "$NEW_TASK_DEFINITION")
NEW_REVISION_DATA=$(echo $NEW_REVISION | jq '.taskDefinition.revision')
NEW_SERVICE=$(aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $TASK_NAME --force-new-deployment)
