## Examples

You only need to specific the task definition version number, though you can specify the name also

    ufo rollback hi-web 1
    ufo rollback hi-web hi-web:1

To see recent task definitions:

    ufo releases

If you set a current service with `ufo current`, then the commands get shorten:

    ufo rollback hi-web:1
    ufo rollback 1
