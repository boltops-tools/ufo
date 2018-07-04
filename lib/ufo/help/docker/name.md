It is sometimes handy to grab the name of the Docker image that was just generated.  Let's say ou needed the image name so you can feed it into another script that you have. The command `ufo docker name` returns the image of the most recently built Docker image.

## Examples

    ufo docker build # stores the docker image name in the .ufo/data folder
    ufo docker name  # fetches image name from .ufo/data folder

An example image name would look something like this: `tongueroo/demo-ufo:ufo-2018-02-15T19-29-06-88071f5`

Note, the `.ufo/data` folder is an internal data folder and it's structure can change in future releases.

If you want to generate a brand new name for whatever purpose, you can use the `--generate` flag.  The generate does not write to the `.ufo/data` folder.  It only generates a fresh name to stdout.  If you run it multiple times, it will generate new names.  You can notice this by seeing that the timestamp will always update:

    ufo docker name --generate  # example: tongueroo/demo-ufo:ufo-2018-02-15T10-00-00-88071f5
    ufo docker name --generate  # example: tongueroo/demo-ufo:ufo-2018-02-15T10-00-08-88071f5
    ufo docker name --generate  # example: tongueroo/demo-ufo:ufo-2018-02-15T10-00-16-88071f5
