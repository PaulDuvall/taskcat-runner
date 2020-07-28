#!/bin/bash
# Bash template based on https://github.com/eppeters/bashtemplate.sh
# sudo chmod +x *.sh
# ./cfn-auto-delete.sh

set -euo pipefail
IFS=$'\n\t'

#/ Usage: cfn-auto-delete.sh
#/ Description: Create an IAM Role for a specific CloudFormation Stack 
#/ Options:
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 1 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

STACK_NAME=${1:-${STACK_NAME:-}}
if [ -z "$STACK_NAME" ]; then
    usage
fi

TTL=${2:-${TTL:-}}
if [ -z "$TTL" ]; then
    usage
fi

# aws cloudformation create-stack --stack-name cloudformation-admin-iam --capabilities CAPABILITY_NAMED_IAM --disable-rollback --template-body file://cloudformation-admin-iam.yml

aws cloudformation create-stack --stack-name ttl --capabilities CAPABILITY_NAMED_IAM --disable-rollback --template-body file://cloudformation-stack-ttl.yml --parameters ParameterKey=StackName,ParameterValue=$STACK_NAME ParameterKey=TTL,ParameterValue=$TTL