---
title: ufo init
---

The `ufo init` command provides a way to quickly setup a project to be ufo ready. It creates a ufo folder with all the starter supporting files in order to use ufo.  This page demonstrates how to use `ufo init`.  The command has a few required options `--app`, `--env`, `--cluster`, and `--image`.

For this example we will use [tongueroo/hi](https://github.com/tongueroo/hi) which is a small test sinatra app.

Let's run the command in our newly clone project.

```sh
git clone https://github.com/tongueroo/hi.git
cd hi
ufo init --app=hi --env prod --cluster=prod --image=tongueroo/hi
```

You should see output similiar to this:

<img src="/img/tutorials/ufo-init.png" class="doc-photo" />

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
    ├── prod.rb
    └── stag.rb
```

The explanation of the folders and files were covered in detailed earlier at [Structure]({% link _docs/structure.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/commands.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/ufo-ship.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

