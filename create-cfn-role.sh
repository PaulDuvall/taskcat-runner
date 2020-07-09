#!/bin/bash
# sudo chmod +x *.sh
# ./create-cfn-role.sh

aws cloudformation create-stack --stack-name cfn-role --capabilities CAPABILITY_NAMED_IAM --disable-rollback --template-body file://cfn-role.yml --parameters ParameterKey=MyRoleName,ParameterValue=pmd-test-cfn-role