---
title: Run Single Task
nav_order: 40
---

Sometimes you do not want to run a long running `service` but a one time task. Running Rails migrations are an example of a one off task.  Here is an example of how you would run a one time task.

    ufo task demo-web -c bundle exec rake db:migrate

At the end of the output you should see you the task ARN:


    $ ufo task demo-web -c bundle exec rake db:migrate
    ...
    Running task_definition: demo-web
    Task ARN: arn:aws:ecs:us-west-2:994926937775:task/a0e4229d-3d39-4b26-9151-6ab6869b84d4
    $

You can describe that task for more details:

    aws ecs describe-tasks --tasks arn:aws:ecs:us-west-2:994926937775:task/a0e4229d-3d39-4b26-9151-6ab6869b84d4

You can check out the [ufo task](http://ufoships.com/reference/ufo-task/) reference for more details.

{% include prev_next.md %}