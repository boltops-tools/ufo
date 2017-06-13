module Ufo
  module Docker::Help
    def base
<<-EOL

The docker cache task builds a docker image using the Dockerfile.base file and
updates the FROM Dockerfile image with the generated image from Dockerfile.base.

Examples:

$ ufo docker base

$ ufo docker base --no-push # do not push the image to the registry

Docker image tongueroo/hi:base-2016-10-21T15-50-57-88071f5 built.
EOL
    end

    def build
<<-EOL
Examples:

$ ufo docker build

$ ufo docker build --push # also pushes the image to the docker registry

Docker image tongueroo/hi:ufo-2016-10-21T15-50-57-88071f5 built.
EOL
    end

    def name
<<-EOL
Examples:

$ ufo docker name

Docker image name that will be used: tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5
EOL
    end

    def clean
<<-EOL
Examples:

Say you currently have these images:

* tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5

* tongueroo/hi:ufo-2016-10-16T19-29-06-88071f5

* tongueroo/hi:ufo-2016-10-17T19-29-06-88071f5

* tongueroo/hi:ufo-2016-10-18T19-29-06-88071f5

To clean them up and keep the 3 more recent:

$ ufo docker clean tongueroo/hi

This will remove tongueroo/hi:ufo-2016-10-15T19-29-06-88071f5.
EOL
    end

    extend self
  end
end
