---
title: Secrets
nav_order: 20
---

## What are Secrets?

[ECS supports injecting secrets or sensitive data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html) into the the environment as variables.  ECS decrypts the secrets straight from AWS to the ECS task environment. It never passes through the machine calling `ufo ship` IE: your laptop, a deploy server, or CodeBuild, etc.

ECS supports 2 storage backends for secrets:

1. [Secrets Manager](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-secrets.html#secrets-envvar)
2. [Systems Manager Parameter Store](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-parameters.html#secrets-envvar-parameters)

Here are both of the formats:

Secrets manager format:

```json
{
  "containerDefinitions": [{
    "secrets": [{
      "name": "environment_variable_name",
      "valueFrom": "arn:aws:secretsmanager:region:aws_account_id:secret:secret_name-AbCdEf"
    }]
  }]
}
```

Parameter store format:

```json
{
  "containerDefinitions": [{
    "secrets": [{
      "name": "environment_variable_name",
      "valueFrom": "arn:aws:ssm:region:aws_account_id:parameter/parameter_name"
    }]
  }]
}
```

## UFO Support

Ufo supports both forms of secrets. You create a `.secrets` file and can reference it in the `.ufo/templates/main.json.erb`

```json
{
  "family": "<%= @family %>",
  # ...
  <% if @secrets %>
  "secrets": <%= helper.secrets_file(".secrets") %>,
  <% end %>
}
```

The `.secrets` file is like an env file that will understand a secrets-smart format.  Example:

    NAME1=SSM:my/parameter_name
    NAME2=SECRETSMANAGER:/my/secret_name-AbCdEf

The `SSM:` and `SECRETSMANAGER:` prefix will be expanded to the full ARN. You can also just specify the full ARN.

    NAME1=arn:aws:ssm:region:aws_account_id:parameter/my/parameter_name
    NAME2=arn:aws:secretsmanager:region:aws_account_id:secret:my/secret_name-AbCdEf

In turn, this generates:

```json
{
  "containerDefinitions": [{
    "secrets": [
      {
        "name": "NAME1",
        "valueFrom": "arn:aws:ssm:us-west-2:111111111111:parameter/demo/development/foo"
      },
      {
        "name": "NAME2",
        "valueFrom": "arn:aws:secretsmanager:us-west-2:111111111111:secret:/demo/development/my-secret-test-qRoJel"
      }
    ]
  }]
}
```

## SSM Parameter Names with Leading Slash

If your SSM parameter has a leading slash then do **not** include when using it in the .secrets file. Example:

    aws ssm get-parameter --name /demo/development/foo

So use:

    FOO=SSM:demo/development/foo

The extra slash seems to confuse ECS. For secretsmanager names, you do include the leading slash.

## Substitution

Ufo also does a simple substition on the value. For example, the `:UFO_ENV` is replaced with the actual value of `UFO_ENV=development`. Example:

    NAME1=SSM:demo/:UFO_ENV/parameter_name
    NAME2=SECRETSMANAGER:demo/:UFO_ENV/secret_name-AbCdEf

Expands to:

    NAME1=arn:aws:ssm:region:aws_account_id:parameter/demo/development/parameter_name
    NAME2=arn:aws:secretsmanager:region:aws_account_id:secret:/demo/development/secret_name-AbCdEf

## IAM Permission

If you're using secrets, you'll need to provide an IAM execution role so the EC2 instance has permission to read the secrets. Here's a starter example:

.ufo/iam_roles/execution_role.rb

```ruby
managed_iam_policy("AmazonEC2ContainerRegistryReadOnly")
managed_iam_policy("AmazonSSMReadOnlyAccess")
managed_iam_policy("CloudWatchLogsFullAccess")
managed_iam_policy("SecretsManagerReadWrite")
```

More info [ECS IAM Roles]({% link _docs/iam-roles.md %})

## Debugging Tip

Be sure that the secrets exist. If they do not you will see an error like this in the ecs-agent.log:

/var/log/ecs/ecs-agent.log

    level=info time=2020-06-26T00:59:46Z msg="Managed task [arn:aws:ecs:us-west-2:111111111111:task/development/91828be6a02b48f982cd9122db5e39b2]: error transitioning resource [ssmsecret] to [CREATED]: fetching secret data from SSM Parameter Store in us-west-2: invalid parameters: /my-parameter-name" module=task_manager.go

Sometimes there is even no error message in the ecs-agent.log. As a debugging step, try removing all secrets and seeing if that the container will start up.

{% include prev_next.md %}
