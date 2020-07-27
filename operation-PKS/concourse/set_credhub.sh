#!/bin/bash

source ./login_credhub.sh
PIPELINE_NAME=hello-pipeline
PREFIX='/concourse/main'

credhub set -t value -n /concourse/main/hello-credhub/hello -v test