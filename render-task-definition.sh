#!/bin/bash
set -e

VERSION="latest"
AWS_ACCOUNT_ID="303981612052"
REGION="eu-central-1"

# Render the task definition
jsonnet --ext-str version="$VERSION" --ext-str aws_account_id="$AWS_ACCOUNT_ID" --ext-str region="$REGION" task-definition.jsonnet > task-definition.json

# Register the task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json --region "$REGION"
