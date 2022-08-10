#!/bin/bash

set -e

aws --profile sreami \
    --region eu-west-2 \
cloudformation \
create-stack \
--stack-name cca-sre-aem-poc-cf \
--template-url "https://cca-sre-poc-aem-install.s3.eu-west-2.amazonaws.com/quickstart-aem-opencloud/templates/workload-main.template.yaml" \
--on-failure DO_NOTHING \
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
--tags \
Key=CostCode,Value=IS9210S101 \
Key=ServiceOwner,Value=SRE \
Key=ServiceRole,Value="AEM POC CF Stack" \
Key=Environment,Value=dev \
--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
