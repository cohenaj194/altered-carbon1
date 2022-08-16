# CLI tools

## stack-lookup

Obtains the stack records of any stack:

Required environmental variables:
* S3 `AWS_ACCESS_KEY_ID`
* S3 `AWS_SECRET_ACCESS_KEY`
* S3 `AWS_REGION`

Help output:

```
Looks up information on altered-carbon stacks:

list-stacks           list stacks 
stack-records         output stack-records json list for all stacks matching a given STACK_NAME
download-kubeconfigs  download all kubeconfigs of a stack to ~/Downloads/

examples: 

  cli/stack-lookup list-stacks 
  cli/stack-lookup list-stacks foobar
  cli/stack-lookup stack-records foobar 
  cli/stack-lookup download-kubeconfigs foobar 
```

## deploy-default-stack

Triggers a pipeline on either `default.prod` or `default.stage`.  There is a different version of this script for github vs gitlab.

Required environmental variables for gitlab:
* `AC_GITLAB_PIPELINE_TRIGGER_TOKEN`.

Github requires that you run the following and authorize the cli tool:

```
gh auth login
```

Help output:

```
Triggers altered-carbon deployments:
  
  cli/deploy-default-stack $STACK_NAME $SLEEVE (apply/destroy)

Examples: 

  cli/deploy-default-stack mystackname simple-aws apply

Sleeves: 

  environment-check
  simple-aws
  simple-azure
  simple-gcp

can deploy to default staging with an extra argument:

  cli/deploy-default-stack mystackname simple-aws apply staging
```