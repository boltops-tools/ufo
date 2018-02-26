The `ufo init` command provides a way to quickly setup a project to be ufo ready. It creates a ufo folder with all the starter supporting files in order to use ufo.  This page demonstrates how to use `ufo init`.  The command requires these options: `--app` and `--image`.

## Examples

For this example we will use [tongueroo/hi](https://github.com/tongueroo/hi) which is a small test sinatra app.  Let's run the command in our newly clone project.

    $ git clone https://github.com/tongueroo/hi.git
    $ cd hi
    $ ufo init --app=hi --image=tongueroo/hi
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

## Options: app and image

The `app` is that application name that you want to show up on the ECS dashboard.  It is encouraged to have the app name be a single word.

The `image` is the base portion of image name that will be pushed to the docker registry, ie: DockerHub or AWS ECR.  The image should **not** include the tag since the tag is generated upon a `ufo ship`.  For example:

    tongueroo/hi => tongueroo/hi:ufo-2018-02-08T21-04-02-3c86158

The generated `tongueroo/hi:ufo-2018-02-08T21-04-02-3c86158` image name gets pushed to the docker registry.

## Directory Structure

The standard directory structure of the `.ufo` folder that was created looks like this:

    ufo
    ├── output
    ├── settings.yml
    ├── task_definitions.rb
    ├── templates
    ├   └── main.json.erb
    └── variables
        ├── base.rb
        ├── production.rb
        └── development.rb

For a explanation of the folders and files refer to [Structure]({% link _docs/structure.md %}).


