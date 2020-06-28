---
title: Structure
nav_order: 11
---

Ufo creates a `.ufo` folder within your project which contains the required files used by ufo to build and deploy docker images to ECS.  The standard directory structure of the `.ufo` folder looks like this:

```sh
.ufo
├── output
├── params.yml
├── settings.yml
├── settings/cfn/default.yml
├── settings/network/default.yml
├── task_definitions.rb
├── templates
|   └── main.json.erb
└── variables
    ├── base.rb
    ├── production.rb
    └── development.rb
```

The table below covers the purpose of each folder and file.

File / Directory  | Description
------------- | -------------
iam_roles/  | Where ufo managed iam roles associated with the task definition can be defined. For more details see: [IAM Roles]({% link _docs/iam-roles.md %}).
output/  | The folder where the generated task definitions are written to.  The way the task definitions are generated is covered in [ufo tasks build]({% link _docs/tutorial-ufo-tasks-build.md %}).
params  | This is where you can adjust the params that get send to the aws-sdk api calls for the [ufo task](https://ufoships.com/reference/ufo-task/) command. More info at [Params]({% link _docs/ufo-task-params.md %}).
settings.yml  | Ufo's general settings file, where you adjust the default [settings]({% link _docs/settings.md %}).
settings/cfn/default.yml  | Ufo's cfn settings. You can customize the CloudFormation resource properties here.
settings/network/default.yml  | Ufo's network settings. You can customize the vpc and subnets to used here.
task_definitions.rb  | This is where you define the task definitions and specify the variables to be used by the ERB templates.
templates/  | The ERB templates with the task definition json code.  The templates are covered in more detail in [ufo tasks build]({% link _docs/tutorial-ufo-tasks-build.md %}).
templates/main.json.erb  | This is the main and starter template task definition json file that ufo initially generates.
variables  | This is where you can define shared variables that are made available to the `template_definitions.rb` and your templates. More info at [Variables]({% link _docs/variables.md %}).

Now that you know where the ufo configurations are located and what they look like, let’s use ufo!

{% include prev_next.md %}
