---
title: Helpers
nav_order: 17
---

The `task_definitions.rb` file has access to helper methods. These helper methods provide useful contextual information about the project.

For example, one of the helper methods provides the exposed port in the Dockerfile of the project. This is useful if someone changes the exported port in the Dockerfile, he will likely forget also to update the ufo variable.  You can reference the port via the helper to prevent this from happening. Here is a list of the helpers:

Helper  | Description
------------- | -------------
full\_image\_name | The full docker image name that ufo builds. The "base" portion of the docker image name is defined in `settings.yml`. For example, the base portion is `tongueroo/demo-ufo` and the full image name is `tongueroo/demo-ufo:ufo-[timestamp]-[sha]`. The base name does not include the generated Docker tag, which contains a timestamp and git sha of the project.
dockerfile\_port | Exposed port extracted from the Dockerfile of the project. 
env_vars(text) | This method takes a block of text that contains the env values in `key=value` format and converts that block of text to the proper task definition JSON format.
env_file(path) | This method takes a `.env` file which contains a simple key-value list of environment variables and converts the list to the proper task definition JSON format.
task_definition_name | The name of the task_definition.  So if the code looks like this `task_definition "demo-web" do`, the task_definition_name is "demo-web".

To call the helper in task_definitions.rb you must add `helper.` in front.  So `full_image_name` is called via `helper.full_image_name`.

The 2 classes which provide these special helper methods are in [ufo/dsl.rb](https://github.com/tongueroo/ufo/blob/master/lib/ufo/dsl.rb) and [ufo/dsl/helper.rb](https://github.com/tongueroo/ufo/blob/master/lib/ufo/dsl/helper.rb). Refer to these classes for the full list of the helper methods.

{% include prev_next.md %}