# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [1.5.0]
* add ufo ships command
* refactor code into modules: ecr, docker, tasks
* improve error message when task_definitions.rb evaluation errors
* rename --force option to --sure

## [1.2.0]

* allow -h, --help, help options at the end of the command

## [1.1.0]

* print out useful error for ERB template errors

## [1.0.1]

* simplify `ufo task` command option

## [1.0.0]

* add `ufo task` command
* been using in production for a while, ready for 1.0.0 release

## [0.1.6]

* default wait for deployment to false

## [0.1.5]

* helper.env_file instead of env_vars method

## [0.1.2]

* remove byebug dependency and fix task register task

## [0.1.1]

- rename `ufo docker full_image_name` to `ufo docker image_name`

## [0.1.0]

- clean up for initial stable release

## [0.0.5]

- add docker base command
- add docker image cleaners
- service_cluster settings.yml
- Initial conceptual release

