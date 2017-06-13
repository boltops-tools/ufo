---
title: ufo init
---

The easiest way to create this ufo folder is by using the `ufo init` command.  For this tutorial we'll [tongueroo/hi](https://github.com/tongueroo/hi) which is a small test sinatra app.
Let's run the command in our newly clone project.

```sh
git clone https://github.com/tongueroo/hi.git
cd hi
ufo init --app=hi --env stag --cluster=stag --image=tongueroo/hi
```

You should see output similiar to this:

<img src="/img/tutorials/ufo-init.png" class="doc-photo" />

The standard directory structure of the ufo folder looks like this:

```sh
ufo
├── output
├── settings.yml
├── task_definitions.rb
└── templates
    └── main.json.erb
```

The explanation of the folders and files were covered in detailed earlier at [Structure]({% link _docs/structure.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ufo-docker-build.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

