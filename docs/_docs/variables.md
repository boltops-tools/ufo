---
title: Shared Variables
---

Often times, you end up using the set of common variables across your task definitions for a project.  Ufo supports a shared variables concept to help with this.  You specify variables files in the `ufo/variables` folder and they are made availale to your `ufo/task_definitions.rb` as well as your `ufo/templates` files.

For example, given `config/variables/base.rb`:

```
@image = helper.full_image_name # includes the git sha tongueroo/hi:ufo-[sha].
@cpu = 128
@memory_reservation = 256
@environment = helper.env_file(".env")
```

You can now use @image in your `ufo/templates/main.json.erb` without having to explicitly declaring them in the `ufo/task_definitions.rb` file.  Variables are automatically made available to all templates and the `task_definition.rb` file also.

### Layering

Shared variables also support a concept called layering.  The `config/variables/base.rb` file is treated specially and will always be evaluated.  Additionally, ufo will also evaluate the `config/variables/[UFO_ENV].rb` according to what UFO_ENV's value is. Thanks layering, you can easily override variables to suite different environments like production or staging. For example:

`ufo/variables/base.rb`:

```ruby
@image = helper.full_image_name # includes the git sha tongueroo/hi:ufo-[sha].
@cpu = 128
@memory_reservation = 256
@environment = helper.env_file(".env")
```

When `ufo ship` is ran with `UFO_ENV=production` he `config/variables/production.rb` will be evaluated and layered on top of the variables defined in `base.rb:

`ufo/variables/production.rb`:

```ruby
@environment = helper.env_vars(%Q[
  RAILS_ENV=production
  SECRET_KEY_BASE=secret
])
```

When `ufo ship` is ran with `UFO_ENV=staging` he `config/variables/staging.rb` will be evaluated and layered on top of the variables defined in `base.rb:


`ufo/variables/production.rb`:

```ruby
@environment = helper.env_vars(%Q[
  RAILS_ENV=staging
  SECRET_KEY_BASE=secret
])
```


<a id="prev" class="btn btn-basic" href="{% link _docs/ufo-env.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/helpers.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
