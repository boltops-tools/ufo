The `ufo init` command setup a project to be ufo ready. It creates a `.ufo` folder with a starter structure.

The command requires the `--image` option.  If the `--app` option is not provided, then it is inferred and set as the parent folder name. Example:

    cd demo
    ufo init --app demo --image org/repo
    ufo init --image org/repo # same as --app demo

## Examples

    $ mkdir demo
    $ cd demo
    $ ufo init --app demo --image org/repo
    Generating .ufo structure
          create  .ufo/config.rb
          create  .ufo/config/web/base.rb
          create  .ufo/config/web/dev.rb
          create  .ufo/config/web/prod.rb
          create  .ufo/resources/iam_roles/execution_role.rb
          create  .ufo/resources/iam_roles/task_role.rb
          create  .ufo/resources/task_definitions/web.yml
          create  .ufo/vars/base.rb
          create  .ufo/vars/dev.rb
          create  .ufo/vars/prod.rb
          create  .gitignore
          create  .dockerignore
          create  Dockerfile
