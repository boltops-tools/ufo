---
title: Setup Ufo
nav_order: 5
---

The easiest way to create this ufo folder is by using the `ufo init` command.  For this tutorial we'll [tongueroo/demo-ufo](https://github.com/tongueroo/demo-ufo) which is a small test sinatra app.
Let's run the command in our newly cloned project.

```sh
git clone https://github.com/tongueroo/demo-ufo.git
cd demo-ufo
ufo init --app=demo --image=tongueroo/demo-ufo
```

You should see output similiar to this:

```sh
$ ufo init --app=demo --image=tongueroo/demo-ufo
Setting up ufo project...
      create  .env
      create  .ufo/params.yml
      create  .ufo/settings.yml
      create  .ufo/settings/cfn/default.yml
      create  .ufo/settings/network/default.yml
      create  .ufo/task_definitions.rb
      create  .ufo/templates/fargate.json.erb
      create  .ufo/templates/main.json.erb
      create  .ufo/variables/base.rb
      create  .ufo/variables/development.rb
      create  .ufo/variables/production.rb
   identical  Dockerfile
      create  bin/deploy
      append  .gitignore
      create  .dockerignore
Starter ufo files created.
Congrats 🎉 You have successfully set up ufo for your project.
$
```

The `ufo init` command generated a few starter ufo files for you. The standard directory structure of the ufo folder looks like this:

```sh
.ufo
├── output
├── settings.yml
├── task_definitions.rb
├── templates
|   └── main.json.erb
└── variables
    ├── base.rb
    ├── production.rb
    └── development.rb
```

The explanation of the folders and files were covered in detailed earlier at [Structure]({% link _docs/structure.md %}).

## Settings

Take a look at the `settings.yml` file and notice that it contains some default configuration settings so you do not have to type out these options repeatedly for some of the ufo commands.

```yaml
# More info: http://ufoships.com/docs/settings/
base:
  image: tongueroo/demo-ufo
  # clean_keep: 30 # cleans up docker images on your docker server.
  # ecr_keep: 30 # cleans up images on ECR and keeps this remaining amount. Defaults to keep all.
  # defaults when an new ECS service is created by ufo ship
  network_profile: default # .ufo/settings/network/default.yml file
  cfn_profile: default # .ufo/settings/cfn/default.yml file

development:
  # cluster: dev # uncomment if you want the cluster name be other than the default
                 # the default is to match UFO_ENV.  So UFO_ENV=development means the ECS
                 # cluster will be name development
  # When you have AWS_PROFILE set to one of these values, ufo will switch to the desired
  # environment. This prevents you from switching AWS_PROFILE, forgetting to
  # also switch UFO_ENV, and accidentally deploying to production vs development.
  # aws_profiles:
  #   - dev_profile1
  #   - dev_profile2

production:
  # cluster: prod
  # aws_profiles:
  #   - prod_profile
```

The `image` value is the name that ufo will use as a base portion of the name to generate a Docker image name, it should not include the tag portion.

The other settings are optional.  You can learn more about them at [Settings]({% link _docs/settings.md %}).

{% include prev_next.md %}
