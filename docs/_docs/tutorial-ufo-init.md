---
title: Setup Ufo
---

The easiest way to create this ufo folder is by using the `ufo init` command.  For this tutorial we'll [tongueroo/hi](https://github.com/tongueroo/hi) which is a small test sinatra app.
Let's run the command in our newly clone project.

```sh
git clone https://github.com/tongueroo/hi.git
cd hi
ufo init --app=hi --image=tongueroo/hi
```

You should see output similiar to this:

```
$ ufo init --app=hi --image=tongueroo/hi
Setting up ufo project...
created: ./bin/deploy
created: ./Dockerfile
created: ./ufo/settings.yml
created: ./ufo/task_definitions.rb
created: ./ufo/templates/main.json.erb
created: ./ufo/variables/base.rb
created: ./ufo/variables/prod.rb
created: ./ufo/variables/stag.rb
created: ./.env
Starter ufo files created.
$ ufo ship hi-web
Building docker image with:
  docker build -t tongueroo/hi:ufo-2017-09-10T15-00-19-c781aaf -f Dockerfile .
....
Software shipped!
$
```

The `ufo init` command generated a few starter ufo files for you. The standard directory structure of the ufo folder looks like this:

```sh
ufo
├── output
├── settings.yml
├── task_definitions.rb
└── templates
    └── main.json.erb
```

The explanation of the folders and files were covered in detailed earlier at [Structure]({% link _docs/structure.md %}).

### Settings

Take a look at the `ufo/settings.yml` file and notice that it contains some default configuration settings so you do not have to type out these options repeatedly for some of the ufo commands.

```yaml
image: tongueroo/hi
```

The `image` value is the name that ufo will use as a base to generate a Docker image name.

The other settings are optional.  You can learn more about them at [Settings]({% link _docs/settings.md %}).

<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ufo-docker-build.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

