# altered-carbon

A reusable dynamic pipeline that can create on demand standardized deployments in single "push button" deployments. The generic nature makes it simple to being coding in and easy to use across multiple different infrastructure providers. 

# Terminology 

* `SLEEVE`: This is the type of deployment being called when the pipeline is triggered. This env var determines what jobs will be run in the pipeline.
* `stack`: This is the name that will be givent to group of resources created or updated in a triggered pipeline is called. Most resources in the created stack will have the `STACK_NAME` sting included.  Note that `stack` is a concept not an env var set in the pipeline.
* `STACK_NAME`: This is a name unique to each deployment, once a `stack` is created its `STACK_NAME` will be locked to the `SLEEVE` and `ENV_NAME` it was created on. Many resources in the `stack` will contain this string to identify it. 
* `ENV_NAME`: This is the specific environment where a stack is being deployed. This should be a string ending in either `prod` or `staging` to determine where it is deployed. This can be more complex if you have several environments to work on such as `dev.staging`, `dev.prod`, `demo.staging`, `demo.prod`, etc.  This can also be used to change the containers used in separate jobs of a single `SLEEVE` allowing for different code to exist between environments in a staging/production manner. 

# SLEEVE Options:

| Sleeve | Description |
|---|---|
| environment-check | `environment-check` echos out the possible s3 bucket path of terraform state files given a `STACK_NAME`, `SLEEVE` and `ENV_NAME`. |
| simple-aws | `simple-aws` creates an aws ec2 instance given a `STACK_NAME`, `SLEEVE` and `ENV_NAME`. |
| simple-azure | `simple-azure` creates an azure vm instance given a `STACK_NAME`, `SLEEVE` and `ENV_NAME`. |
| simple-gcp | `simple-gcp` creates an gcp vm instance given a `STACK_NAME`, `SLEEVE` and `ENV_NAME`. |

# Using altered-carbon deployments

## Creating new deployments

To create or update a a `STACK` trigger a new job of the altered-carbon pipeline and change the following environmental variables:

* `STACK_NAME`
* `SLEEVE`
* `ENV_NAME`

Note: Your `STACK_NAME` should be unique, your `SLEEVE` determines which standardized deployment is used, `ENV_NAME` will be the same for every stack deployed on that particular environment. 

## Deploy via the api

If you request a pipeline trigger token (seen below as `AC_GITLAB_PIPELINE_TRIGGER_TOKEN`), we can give you api commands to run at the end of your scripts and pipelines to trigger altered-carbon deployments. The specific deployment will depend on environmental variables set in the pipeline trigger request.  

Here is a basic api example, I have my `ENV_NAME` in my gitlab environmental vars set to `default.prod`, so it is not required to set this value in the trigger:
```
curl --request POST \
  --form token=$AC_GITLAB_PIPELINE_TRIGGER_TOKEN \
  --form ref=master \
  --form "variables[STACK_NAME]=my-test-stack" \
  --form "variables[SLEEVE]=simple-aws" \
  https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/trigger/pipeline
```

To destroy this set the `DESTROY` variable equal to the `SLEEVE` name:
```
curl --request POST \
  --form token=$AC_GITLAB_PIPELINE_TRIGGER_TOKEN \
  --form ref=master \
  --form "variables[STACK_NAME]=my-test-stack" \
  --form "variables[SLEEVE]=simple-aws" \
  --form "variables[DESTROY]=simple-aws" \
  https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/trigger/pipeline
```

Here is an api example triggering a deployment to create a `simple-aws` stack on `default.staging`, here you need to supply the basic env_name info in the trigger:

```
curl --request POST \
  --form token=$AC_GITLAB_PIPELINE_TRIGGER_TOKEN \
  --form ref=master \
  --form "variables[STACK_NAME]=my-test-stack" \
  --form "variables[SLEEVE]=simple-aws" \
  --form "variables[ENV_NAME]=default.staging" \
  https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/trigger/pipeline
```

If you would like to use a different aws account to deploy your instance into this can be changed by entering the desired aws specific variables:

```
curl --request POST \
  --form token=$AC_GITLAB_PIPELINE_TRIGGER_TOKEN \
  --form ref=master \
  --form "variables[STACK_NAME]=my-test-stack" \
  --form "variables[SLEEVE]=simple-aws" \
  --form "variables[ENV_NAME]=default.staging" \
  --form "variables[DEPLOY_AWS_ACCESS_KEY_ID]=$AWS_ACCESS_KEY_ID" \
  --form "variables[DEPLOY_AWS_SECRET_ACCESS_KEY]=$AWS_SECRET_ACCESS_KEY" \
  --form "variables[DEPLOY_AWS_REGION]=$AWS_REGION" \
  --form "variables[AWS_MACHINE_IMAGE]=$AWS_MACHINE_IMAGE" \
  https://gitlab.com/api/v4/projects/$GITLAB_PROJECT_ID/trigger/pipeline
```

# Setting up an altered carbon project

## Gitlab runners

## Gitlab CI/CD Environmental Variables

Altered Carbon relies on environmental variables to connect to your various cloud accounts, backend s3 storage and to monitor its own pipelines allowing for concurrancy. Depending on the value you may want to mask some of these variables. 

**Make sure none of the environmentsal varialbes are `protected`**, protected variables can only be used by protected branches.  Setting the following env vars to `protected` status will cause new testing branches to fail when you attempt to trigger pipelines within them. 

| Variable Name | Description | Example |
|---|---|---|
| AC_GITLAB_PROJECT_ID | The project ID of your local version of Altered-Carbon, this value is important for api interaction and pipeline url's | `12345678` |
| AWS_ACCESS_KEY_ID | The default aws access key, used for deploying ec2 instances and interacting with altered-carbons backend s3 bucket | |
| AWS_MACHINE_IMAGE | The default ec2 machine image in your default chosen region | `ami-002068ed284fb165b` |
| AWS_REGION | The default region to deploy ec2 instances into | `us-east-2` | 
| AWS_SECRET_ACCESS_KEY | The default aws secret access key, used for deploying ec2 instances and interacting with altered-carbons backend s3 bucket | |
| AZURE_APPID | `appId` from azure rbac role. To create rbac role vars the following run: `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/AZURE_SUBSCRIPTION_ID"` | `asdfa4df-2341-11aa-1f1f-asdfc1234asdf` |
| AZURE_PASSWORD | `password` from azure rbac role. To create rbac role vars the following run: `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/AZURE_SUBSCRIPTION_ID"` | `asdf4asf-2341-11aa-1f1f-asdfc1234asd` |
| AZURE_REGION | The desired region to deploy azure instances into | `useast` |
| AZURE_SERVICE_PRINCIPAL_URL | `name` from azure rbac role. To create rbac role vars the following run: `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/AZURE_SUBSCRIPTION_ID"` | `http://foobar-46-15` |
| AZURE_SUBSCRIPTION_ID | The subscription id of the azure account where you want to deploy instances.  This can be found using: `az login && az account list --output table` | `asdf4asf-2341-11aa-1f1f-asdfc1234asd` |
| AZURE_TENANT | `tenant` from azure rbac role. To create rbac role vars the following run: `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/AZURE_SUBSCRIPTION_ID"` | `asdf4asf-2341-11aa-1f1f-asdfc1234asd` |
| DESTROY | Set this value to `nil` by default, this value will be supplied when a pipeline is triggered in the api request | `nil` | 
| GCP_PROJECT_NAME | The name of your gcp project | `my-team-123456` |
| GCP_REGION | The default region you want to deploy gcp instances into | `us-west1` |
| GCP_ZONE | The default zone you want to deploy gcp instances into | `us-west1-c` |
| GITLAB_API_PRIVATE_TOKEN | Create a gitlab private api token and add this value under `GITLAB_API_PRIVATE_TOKEN`.  This is used by jobs such as `stack_records` to make gitlab api calls insuring that duplicate pipelines are not running against the same stack | `p-1234567qwe890rtyuz` | 
| GOOGLE_APPLICATION_CREDENTIALS_BASE64 | Take your entire google application credentials file, encode this with `base64` and add the resulting value in, to be used for deploying gcp instances, can be decoded with `base64 -d` | `ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOiAiZm9vYmFyIiwKICAicHJpdmF0ZV9rZXlfaWQiOiAiZm9vYmFyIiwKICAicHJpdmF0ZV9rZXkiOiAiLS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tXG5mb29iYXJcbi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS1cbiIsCiAgImNsaWVudF9lbWFpbCI6ICJmb29iYXIuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICJjbGllbnRfaWQiOiAiZm9vYmFyIiwKICAiYXV0aF91cmkiOiAiaHR0cHM6Ly9hY2NvdW50cy5nb29nbGUuY29tL28vb2F1dGgyL2F1dGgiLAogICJ0b2tlbl91cmkiOiAiaHR0cHM6Ly9vYXV0aDIuZ29vZ2xlYXBpcy5jb20vdG9rZW4iLAogICJhdXRoX3Byb3ZpZGVyX3g1MDlfY2VydF91cmwiOiAiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vb2F1dGgyL3YxL2NlcnRzIiwKICAiY2xpZW50X3g1MDlfY2VydF91cmwiOiAiaHR0cHM6Ly93d3cuZ29vZ2xlYXBpcy5jb20vcm9ib3QvdjEvbWV0YWRhdGEveDUwOS9hbHRlcmVkLWNhcmJvbiU0MGZvb2Jhci5pYW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQ==` |
| S3_BUCKET_REGION | The region containing your backend s3 bucket | `us-east-1` | 
| S3_STORAGE_BUCKET | The name of the s3 bucket where you want to store altered-carbon stack records and terraform state files | `mybucketname` | 
| SLEEVE | Set this value to `nil` by default, this value will be supplied when a pipeline is triggered in the api request | `nil` |
| SSH_PRIVATE_KEY_BASE64 | Base64 encode a private machine only ssh key to be used in deploying instances, can be decoded with `base64 -d` | `Zm9vYmFyCg==` |
| SSH_PUBLIC_KEY | Include the public machine ssh key to be used in deploying instances, leave out the `ssh-rsa ` as gitlab environmental variables cannot contain whitespace | | 
| STACK_NAME | Set this value to `nil` by default, this value will be supplied when a pipeline is triggered in the api request | `nil` | 
| ENV_NAME | Set this to the default environment | `default.stage` |
| TF_PUBLIC_PROD_SHA | The sha of your production environments container | `:latest` | 
| TF_PUBLIC_STAGE_SHA | The sha of your staging environments container | `@sha256:563905db78d34acc7fdb57fca054d8a7ded567397d146ec496acc842d3316f37` | 

# Setup account credentials

## Setup AWS IAM user

To create an aws IAM user credentials follow this guide: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey

Make sure your user has the following role to enable the proper ec2 and s3 permissions needed to run altered-carbon: 

```
{

}
```

## Setup S3 backend buket

Create an S3 bucket, add its name under the `S3_STORAGE_BUCKET` env var and add its region under the `S3_BUCKET_REGION`. Your IAM user can contain the needed S3 permissions so no changes are required to add security policies directly onto your bucket.  However it is recommended that you lock this bucket so that only admins and the altered carbon IAM user can access the bucket.

## Setup Azure user

To create an rbac token for use (or when we need to rotate the token) in altered carbon on azure run the following:

```
az login
az acr login --name foobar
# if you dont have the SUBSCRIPTION_ID use this:
# SUBSCRIPTION_ID="$(az account list --output table | grep $YOUR_AZ_SUBSCRIPTION_NAME | awk '{print $6}')"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$AZURE_SUBSCRIPTION_ID"
```

You will then get output similar to the following save this in a local file and use the following values for AC env vars: 

```
{
  "appId": "$AZURE_APPID",
  "displayName": "azure-cli-YYYY-MM-DD-YY-MM-SS",
  "name": "$AZURE_SERVICE_PRINCIPAL_URL",
  "password": "$AZURE_PASSWORD",
  "tenant": "$AZURE_TENANT"
}
```

Note the `$AZURE_SERVICE_PRINCIPAL_URL` is the name of the cli file you created starting with `http://`. The `displayName` is not used in an env var and is the `$AZURE_SERVICE_PRINCIPAL_URL` but without the `http://`.

To test if this works run `az login --service-principal -u "$AZURE_SERVICE_PRINCIPAL_URL" -p "$AZURE_PASSWORD" --tenant "$AZURE_TENANT"`

## Azure password exparation

The `AZURE_PASSWORD` env var will expire once every 2 years on your azure app registration used for AC. To reset it go to the following: 

https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/Credentials/appId/$AZURE_APPID/isMSAApp/

Click `+ New client secret` and create a new secret with a 24 month exparation.  Then copy the `Value` (this will only be shown once) replace the `AZURE_PASSWORD` env var in altered carbon and replace the password field of your local azure cli file.

The full list of azure app registations will be found here: https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade

## Setup GCP user

To create a gcp `service account` follow these steps: https://cloud.google.com/docs/authentication/production
