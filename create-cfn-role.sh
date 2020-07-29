#!/bin/bash
# Bash template based on https://github.com/eppeters/bashtemplate.sh
# sudo chmod +x *.sh
# ./create-cfn-role.sh

set -euo pipefail
IFS=$'\n\t'

AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')

AWS_ACCOUNT_ID=$(aws s3 mb s3://ceoa-$(aws sts get-caller-identity --output text --query 'Account'))

#/ Usage: create-cfn-role.sh ROLE_NAME TTL
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

STACK_NAME=${2:-${STACK_NAME:-}}
if [ -z "$STACK_NAME" ]; then
    usage
fi

TTL=${3:-${TTL:-}}
if [ -z "$TTL" ]; then
    usage
fi

aws cloudformation create-stack --stack-name $ROLE_NAME --capabilities CAPABILITY_NAMED_IAM --disable-rollback --template-body file://cfn-role.yml --parameters ParameterKey=MyRoleName,ParameterValue=$ROLE_NAME ParameterKey=TTL,ParameterValue=$TTL

# https://docs.aws.amazon.com/cli/latest/reference/cloudformation/wait/stack-create-complete.html#examples

echo "WAITING on $ROLE_NAME to be created..."
aws cloudformation wait stack-create-complete --stack-name $ROLE_NAME

echo "$ROLE_NAME stack has successfully been created"

# Delete the stack
echo "Deleting $STACK_NAME stack"
aws cloudformation delete-stack --stack-name $STACK_NAME
echo "WAITING on $STACK_NAME to be deleted..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME

echo "$STACK_NAME stack has been successfully deleted"

echo "$ROLE_NAME stack will be automatically deleted in $TTL minutes"



