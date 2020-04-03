# Introduction

This is a LEP (Linux Nginx PHP) container for hosting various types of PHP sites.


# Script directories

## Directory: /docker-entrypoint-pre-init.d

Any file with the .sh extension in this directory will be sourced in before initialization takes place.

## Directory: /docker-entrypoint-init.d

Any file with the .sh extension in this directory will be sourced for initialization.

## Directory: /docker-entrypoint-pre-exec.d

Any file with the .sh extension in this directory will be sourced in after initialization, before startup.


