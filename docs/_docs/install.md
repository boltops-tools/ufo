---
title: Installation
nav_order: 3
---

## Install with RubyGems

You can install ufo with RubyGems:

```sh
gem install ufo
```

Or you can add ufo to your Gemfile in your project if you are working with a ruby project.  It is not required for your project to be a ruby project to use ufo.

{% highlight ruby %}
gem "ufo"
{% endhighlight %}

## Dependencies

* Docker: You will need a working version of [Docker](https://docs.docker.com/engine/installation/) installed as ufo shells out and calls the `docker` command.
* AWS: Set up your AWS credentials at `~/.aws/credentials` and `~/.aws/config`.  This is the [AWS standard way of setting up credentials](https://aws.amazon.com/blogs/security/a-new-and-standardized-way-to-manage-credentials-in-the-aws-sdks/).

{% include prev_next.md %}
