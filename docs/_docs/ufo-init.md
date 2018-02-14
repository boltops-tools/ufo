---
title: ufo init
---

The `ufo init` command provides a way to quickly setup a project to be ufo ready. It creates a ufo folder with all the starter supporting files in order to use ufo.  This page demonstrates how to use `ufo init`.  The command requires these options: `--app` and `--image`.

For this example we will use [tongueroo/hi](https://github.com/tongueroo/hi) which is a small test sinatra app.

Let's run the command in our newly clone project.

```sh
git clone https://github.com/tongueroo/hi.git
cd hi
ufo init --app=hi --image=tongueroo/hi
```

You should see output similiar to this:

```sh
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
```

The standard directory structure of the ufo folder looks like this:

```sh
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
```

The explanation of the folders and files were covered in detailed earlier at [Structure]({% link _docs/structure.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/commands.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-ship.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

