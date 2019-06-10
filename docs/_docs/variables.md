---
title: Shared Variables
nav_order: 17
---

Often, you end up using the set of common variables across your task definitions for a project.  Ufo supports a shared variables concept to support this.  You specify variables files in the `.ufo/variables` folder and they are made available to your `.ufo/task_definitions.rb` as well as your `.ufo/templates` files.

For example, given `variables/base.rb`:

```
@image = helper.full_image_name # includes the git sha tongueroo/demo-ufo:ufo-[sha].
@cpu = 128
@memory_reservation = 256
@environment = helper.env_file(".env")
```

You can now use `@image` in your `.ufo/templates/main.json.erb` without having to declare them in the `.ufo/task_definitions.rb` file explicitly.  Variables are automatically made available to all templates and the `task_definition.rb` file.

## Layering

Shared variables also support a concept called layering.  The `variables/base.rb` file is treated specially and will always be evaluated.  Additionally, ufo will also evaluate the `variables/[UFO_ENV].rb` according to what UFO_ENV's value is. Thanks to layering, you can easily override variables to suit different environments like `production` or `development`. For example:

`.ufo/variables/base.rb`:

```ruby
@image = helper.full_image_name # includes the git sha tongueroo/demo-ufo:ufo-[sha].
@cpu = 128
@memory_reservation = 256
@environment = helper.env_file(".env")
```

When `ufo ship` is ran with `UFO_ENV=production` the `variables/production.rb` will be evaluated and layered on top of the variables defined in `base.rb`:

`.ufo/variables/production.rb`:

```ruby
@environment = helper.env_vars(%Q[
  RAILS_ENV=production
  SECRET_KEY_BASE=secret
])
```

When `ufo ship` is ran with `UFO_ENV=development` the `variables/development.rb` will be evaluated and layered on top of the variables defined in `base.rb`:


`.ufo/variables/development.rb`:

```ruby
@environment = helper.env_vars(%Q[
  RAILS_ENV=development
  SECRET_KEY_BASE=secret
])
```

{% include prev_next.md %}