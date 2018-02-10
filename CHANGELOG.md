# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [2.2.2]
- Remove role passed to create_service. Fixes ufo ship when target-group-arn is provided.

## [2.2.1]
- require aws-sdk-ecr

## [2.2.0]
- only use required aws-sdk components
- allow overriding one off task command
- change default environment to development
- cleanup: help uses markdown files
- starter files: comment out command and fallback to the dockerfile command
- update docs to reflect full env naming
- update generated gitignore
- update help: remove -prod

## [2.1.0]
* ufo init: only require --app and --image option

## [2.0.3]
* add aws log group as a comment in the starter project

## [2.0.2]
* ufo init: update cli help

## [2.0.1]
* ufo init: remove --env option requirement

## [2.0.0]
* shared variable support
* UFO_ENV introduced
* settings: AWS_PROFILE and UFO_ENV mapping to ecs cluster

## [1.7.1]
* only create log group if it doesnt already exist

## [1.7.0]
* automatically create task definintion log group

## [1.6.3]
* fix target_group_prompt

## [1.6.2]
* update bin/deploy starter project script
* update help menu
* update docs

## [1.6.1]
* exit if docker push fails

## [1.6.0]
* rename ufo docker cleanup -> ufo docker clean
* rename ufo docker image_name -> ufo docker name
* add docs

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

