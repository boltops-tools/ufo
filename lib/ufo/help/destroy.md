## Examples

Ufo provides a quick way to destroy an ECS service. To destroy an ECS service, you must make sure that the desired number of tasks is first set to 0. It is easy to forget to do this and waste time. So as part of destroying the service ufo will scale the ECS service down to 0 automatically first and then destroys the service.  Ufo also prompts you before destroying the service.

    ufo destroy hi-web

If you would like to bypass the prompt, you can use the `--sure` option.

    ufo destroy hi-web --sure
