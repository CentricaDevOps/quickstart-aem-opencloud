#!/bin/bash

set -e

# ensure we are in the quick start directory
cd "$(dirname ${BASH_SOURCE[0]})"

# sync up the s3 bucket
aws --profile sreami s3 sync ./ s3://cca-sre-poc-aem-install/quickstart-aem-opencloud/

set +e
# ensure current stack is deleted
stackid=$(aws --profile sreami --region eu-west-2 cloudformation describe-stacks --stack-name cca-sre-aem-poc-cf |jq -r '.Stacks[].StackId' || echo Nope)
set -e


if [ ! $stackid = "Nope" ]; then
    stkstatus=$(aws --profile sreami --region eu-west-2 cloudformation describe-stacks --stack-name $stackid |jq -r '.Stacks[].StackStatus')
    if [ ! "$stkstatus" =  "DELETE_IN_PROGRESS" ]; then
        aws --profile sreami --region eu-west-2 cloudformation delete-stack --stack-name $stackid
    fi
    cn=1
    while [ $stkstatus =  "DELETE_IN_PROGRESS" ]; do
        waited=$(( cn * 5 ))
        echo "Waiting for stack to delete: $waited minutes"
        sleep 300
        cn=$(( cn + 1 ))
        if [ $cn -gt 10 ];then
            echo "Not waiting any longer, $waited minutes: go and have a rummage yourself"
            exit 1
        fi
    done
    echo "stack deleted"
    echo "deleting secret aem-opencloud-aemssl-private-key"
    aws --profile sreami secretsmanager delete-secret --secret-id aem-opencloud-aemssl-private-key --force-delete-without-recovery --region eu-west-2
    echo "deleting secret aem-opencloud-aem-keystore-password"
    aws --profile sreami secretsmanager delete-secret --secret-id aem-opencloud-aem-keystore-password --force-delete-without-recovery --region eu-west-2
fi

# now create the stack
echo "Creating Stack"
aws --profile sreami \
    --region eu-west-2 \
cloudformation \
create-stack \
--stack-name cca-sre-aem-poc-cf \
--template-url "https://cca-sre-poc-aem-install.s3.eu-west-2.amazonaws.com/quickstart-aem-opencloud/templates/workload-main.template.yaml" \
--disable-rollback \
--parameters \
ParameterKey="AOCStackPrefix",ParameterValue="aem-opencloud" \
ParameterKey="AemDispatcherVersion",ParameterValue="4.3.5" \
ParameterKey="AemVersion",ParameterValue="65" \
ParameterKey="AuthorDispatcherInstanceType",ParameterValue="t3.small" \
ParameterKey="AuthorInstanceType",ParameterValue="m5.2xlarge" \
ParameterKey="AvailabilityZones",ParameterValue=\"eu-west-2a,eu-west-2b\" \
ParameterKey="BaseAmiImageName",ParameterValue="/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2" \
ParameterKey="BastionAMIOS",ParameterValue="Amazon-Linux2-HVM" \
ParameterKey="BastionInstanceType",ParameterValue="t3.micro" \
ParameterKey="CloudfrontPriceClass",ParameterValue="PriceClass_All" \
ParameterKey="EnableCloudfront",ParameterValue="true" \
ParameterKey="LambdaZipsBucketName",ParameterValue="cca-sre-poc-aem-lambda" \
ParameterKey="OrchestratorInstanceType",ParameterValue="t3.small" \
ParameterKey="PrivateSubnet1CIDR",ParameterValue="10.2.16.0/24" \
ParameterKey="PrivateSubnet2CIDR",ParameterValue="10.2.18.0/24" \
ParameterKey="PublicSubnet1CIDR",ParameterValue="10.2.20.0/24" \
ParameterKey="PublicSubnet2CIDR",ParameterValue="10.2.22.0/24" \
ParameterKey="PublishDispatcherInstanceType",ParameterValue="t3.small" \
ParameterKey="PublishInstanceType",ParameterValue="m5.2xlarge" \
ParameterKey="QSS3BucketName",ParameterValue="cca-sre-poc-aem-install" \
ParameterKey="QSS3BucketRegion",ParameterValue="eu-west-2" \
ParameterKey="QSS3KeyPrefix",ParameterValue="quickstart-aem-opencloud/" \
ParameterKey="RemoteAccessCIDR",ParameterValue="212.228.47.123/32" \
ParameterKey="S3DataBucketName",ParameterValue="cca-sre-poc-aem-data" \
ParameterKey="S3InstallBucketName",ParameterValue="cca-sre-poc-aem-install" \
ParameterKey="S3InstallKeyPrefix",ParameterValue="quickstart-aem-opencloud/" \
ParameterKey="VPCCIDR",ParameterValue="10.2.16.0/21" \
ParameterKey="KeyPairName",ParameterValue="cca-test" \
ParameterKey="JavaJDKVersion",ParameterValue="8u341" \
--tags \
Key=CostCode,Value=IS9210S101 \
Key=ServiceOwner,Value=SRE \
Key=ServiceRole,Value="AEM POC CF Stack" \
Key=Environment,Value=dev \
--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
