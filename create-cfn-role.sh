#!/bin/bash
# Bash template based on https://github.com/eppeters/bashtemplate.sh
# sudo chmod +x *.sh
# ./create-cfn-role.sh

set -euo pipefail
IFS=$'\n\t'

#/ Usage: launch-stack.sh ROLE_NAME CFN_STACK_NAME
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

ROLE_NAME=${1:-${ROLE_NAME:-}}
if [ -z "$ROLE_NAME" ]; then
    usage
fi

CFN_STACK_NAME=${2:-${CFN_STACK_NAME:-}}
if [ -z "$CFN_STACK_NAME" ]; then
    usage
fi


aws cloudformation create-stack --stack-name cfn-role-$ROLE_NAME --capabilities CAPABILITY_NAMED_IAM --disable-rollback --template-body file://cfn-role.yml --parameters ParameterKey=MyRoleName,ParameterValue=$ROLE_NAME ParameterKey=MyStackName,ParameterValue=$CFN_STACK_NAME