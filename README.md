# Introduction

This is a LEP (Linux Nginx PHP) container for hosting various types of PHP sites.


# Environment


## START_POSTFIX

If set to "yes", this will start postfix inside the container.

The following also needs to be specified...

* `POSTFIX_ROOT_ADDRESS`: The email address for system email.
* `POSTFIX_MYHOSTNAME`: Hostname for local email delivery.
* `POSTFIX_RELAYHOST`: The contents of relayhost, the server we're relaying mail via.

The follwing aliases are created and forwarded to `$POSTFIX_ROOT_ADDRESS`: abuse, admin, administrator, webmaster, postmaster, hostmaster, noreply



# Script directories


## Directory: /docker-entrypoint-pre-init.d

Any file with the .sh extension in this directory will be sourced in before initialization takes place.


## Directory: /docker-entrypoint-init.d

Any file with the .sh extension in this directory will be sourced for initialization.


## Directory: /docker-entrypoint-pre-exec.d

Any file with the .sh extension in this directory will be sourced in after initialization, before startup.


