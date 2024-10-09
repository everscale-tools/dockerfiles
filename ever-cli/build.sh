#!/bin/bash

docker build --no-cache --build-arg EVER_CLI_REPO_REF=245c3b9 -t sergemedvedev/ever-cli:0.40.1 .

