---
title: Structure
---

Ufo creates a `.ufo` folder within your project which contains the required files used by ufo to build and deploy docker images to ECS.  The standard directory structure of the `.ufo` folder looks like this:

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

The table below covers the purpose of each folder and file.

File / Directory  | Description
------------- | -------------
<code>output/</code>  | The folder where the generated task definitions are written to.  The way the task definitions are generated are covered in [ufo tasks build]({% link _docs/tutorial-ufo-tasks-build.md %}).
<code>settings.yml</code>  | Ufo's settings file, where you and adjust the default [settings]({% link _docs/settings.md %}).
<code>task_definitions.rb</code>  | This where you define the task definitions and specify the variables to be used by the ERB templates.
<code>templates/</code>  | The ERB templates with the task definition json code.  The template are covered in more detail in [ufo tasks build]({% link _docs/tutorial-ufo-tasks-build.md %}).
<code>templates/main.json.erb</code>  | This is the main and starter template task definition json file that ufo initially generates.
<code>variables</code>  | This is where you can define shared variables that are made available to the template_definitions.rb and your templates. More info at [Variables]({% link _docs/variables.md %}).

Now that you know where the ufo configurations are located and what they look like.  Let use ufo!

<a id="prev" class="btn btn-basic" href="{% link _docs/install.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/tutorial.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>

