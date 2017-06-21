---
title: Setup Ufo
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
service_cluster:
  default: stag # default cluster
  # can override the default cluster for each service.  CLI overrides all of these settings.
  hi-web-stag:
  hi-clock-stag:
  hi-worker-stag:
```

The `image` value is the name that ufo will use as a base to generate a Docker image name.

The `service_cluster` mapping provides a way to set default service-to-cluster mappings so that you do not have to specify the `--cluster` repeatedly.  This is very helpful. For example:

```
ufo ship hi-web-stag --cluster hi-cluster
ufo ship hi-web-stag # same as above because it is configured in ufo/settings.yml
ufo ship hi-web-stag --cluster special-cluster # overrides the default setting in `ufo/settings.yml`.
```


<a id="prev" class="btn btn-basic" href="{% link _docs/tutorial.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial-ufo-docker-build.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

