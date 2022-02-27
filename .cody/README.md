# Overview

CodeBuild is used to run **acceptance-level tests**.

## Deploy Project

To update the CodeBuild project that handles deployment:

    cody deploy ufo -t acceptance

## Start Build

To start a CodeBuild build:

    cody start ufo -t acceptance

To specify a branch:

    cody start ufo -t acceptance -b feature
