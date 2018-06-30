The `ufo init` command provides a way to quickly setup a project to be ufo ready. It creates a ufo folder with all the starter supporting files in order to use ufo.  This page demonstrates how to use `ufo init`.  The command requires the `--image` option.  If the `--app` option is not provided, then it is inferred and set as the parent folder name. Example:

    cd demo
    ufo init --image tongueroo/demo-ufo # same as --app demo

## Examples

For this example we will use [tongueroo/demo-ufo](https://github.com/tongueroo/demo-ufo) which is a small test sinatra app.  Let's run the command in our newly clone project.

    $ git clone https://github.com/tongueroo/demo-ufo.git
    $ cd demo-ufo
    $ ufo init --app=demo --image=tongueroo/demo-ufo
    Setting up ufo project...
          create  .ufo/settings.yml
          create  .ufo/task_definitions.rb
          create  .ufo/templates/main.json.erb
          create  .ufo/variables/base.rb
          create  .ufo/variables/development.rb
          create  .ufo/variables/production.rb
          create  Dockerfile
          create  bin/deploy
          append  .gitignore
    Starter ufo files created.

## More Short Examples

    ufo init --image httpd --app demo
    ufo init --image 123456789012.dkr.ecr.us-west-2.amazonaws.com/myimage --app demo
    ufo init --image tongueroo/demo-ufo --app demo --launch-type fargate --execution-role-arn arn:aws:iam::123456789012:role/ecsTaskExecutionRole
    ufo init --image httpd --app demo --vpc-id vpc-123

## Important options

The `app` is that application name that you want to show up on the ECS dashboard.  It is encouraged to have the app name be a single word.  If the option is not provided, the app name is inferred and is the parent folder name.

The `image` is the base portion of image name that will be pushed to the docker registry, ie: DockerHub or AWS ECR.  The image should **not** include the tag since the tag is generated upon a `ufo ship`.  For example:

    tongueroo/demo-ufo => tongueroo/demo-ufo:ufo-2018-02-08T21-04-02-3c86158

The generated `tongueroo/demo-ufo:ufo-2018-02-08T21-04-02-3c86158` image name gets pushed to the docker registry.

The `--vpc-id` option is optional but very useful. If not specified then ufo will use the default vpc for the network settings like subnets and security groups, which might not be what you want.

## Directory Structure

The standard directory structure of the `.ufo` folder that was created looks like this:

    ufo
    ├── output
    ├── settings.yml
    ├── task_definitions.rb
    ├── templates
    │   └── main.json.erb
    └── variables
        ├── base.rb
        ├── production.rb
        └── development.rb

For a explanation of the folders and files refer to [Structure]({% link _docs/structure.md %}).

## Fargate Support

For ECS Fargate, the ECS task definition structure is a bit different.  To initialize a project to support Fargate use the `--launch-type fargate` option.  You'll be prompted for a execution role arn.  This value gets added to the generated `.ufo/variables/base.rb` and used in the `.ufo/templates/main.json.erb`.

    ufo init --image tongueroo/demo-ufo --app demo --force --launch-type fargate

You can also generate the init ufo files and bypass the prompt by providing the `--execution-role-arn` option upfront.

    ufo init --image tongueroo/demo-ufo --app demo --force --launch-type fargate --execution-role-arn arn:aws:iam::123456789012:role/ecsTaskExecutionRole

Important: You will need to adjust adjust the generated `.ufo/params.yml` and set the subnet and security_group values which are required for Fargate.

For more information and a demo of Fargate support, check out the [Fargate Docs]({% link _docs/fargate.md %}).

## Custom Templates

If you would like the `ufo init` command to use your own custom templates, you can achieve this with the `--template` and `--template-mode` options.  Example:

    ufo init --app=demo --image=tongueroo/demo-ufo --template=tongueroo/ufo-custom-template

This will clone the repo on GitHub into the `~/.ufo/templates/tongueroo/ufo-custom-template` and use that as an additional template source.  The default `--template-mode=additive` mode means that if there's a file in `tongueroo/ufo-custom-template` that exists it will use that in place of the default template files.

If you do not want to use any of the original default template files within the ufo gem at all, you can use the `--template-mode=replace` mode. Replace mode will only use templates from the provided `--template` option.  Example:

    ufo init --app=demo --image=tongueroo/demo-ufo --template=tongueroo/ufo-custom-template --template-mode=replace

You can also specific the full GitHub url. Example:

    ufo init --app=demo --image=tongueroo/demo-ufo --template=https://github.com/tongueroo/ufo-custom-template

If you would like to use a local template that is not on GitHub, then created a top-level folder in `~/.ufo/templates` without a subfolder. Example:

    ufo init --app=demo --image=tongueroo/demo-ufo --template=my-custom # uses ~/.ufo/templates/my-custom
