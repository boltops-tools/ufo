---
title: Helpers
---

The task\_definitions.rb file has access to special variables and helper methods available. These helper methods provide useful contextual information about the project.

For example, one of the variable provides the exposed port in the Dockerfile of the project. This is useful if someone changes the exported port in the Dockerfile, he likely to forget to also update the ufo variable so it is referenced via the helper. Here is a list of the important helpers:

Helper  | Description
------------- | -------------
full\_image\_name | The full docker image name that ufo builds. The "base" portion of the docker image name is defined in ufo/settings.yml. For example, the base portion is `tongueroo/hi` and the full image name is `tongueroo/hi:ufo-[timestamp]-[sha]`. The base name does not include the generated Docker tag, which contains a timestamp and git sha of the Dockerfile that is used.
dockerfile\_port | Exposed port extracted from the Dockerfile of the project. 
env_vars(text) | This method takes a block of text that contains the env values in key=value format and converts that block of text to the proper task definition json format.
env_file(path) | This method takes an `.env` file which contains a simple key value list of environment variables and converts the list to the proper task definition json format.

To call the helper in task_definitions.rb you must add `helper.` in front.  So full\_image\_name  is called via `helper.full_image_name`.

The 2 classes which provide these special helper methods are in [ufo/dsl.rb](https://github.com/tongueroo/ufo/blob/master/lib/ufo/dsl.rb) and [ufo/dsl/helper.rb](https://github.com/tongueroo/ufo/blob/master/lib/ufo/dsl/helper.rb). Refer to these classes for the full list of the special variables and methods.

<a id="prev" class="btn btn-basic" href="{% link _docs/variables.md %}">Back</a>
<a id="next" class="btn btn-primary" href="{% link _docs/conventions.md %}">Next Step</a>
<p class="keyboard-tip">Pro tip: Use the <- and -> arrow keys to move back and forward.</p>
