# Lightweight and minimalistic, dockerized version of the node with command line tools built in

Everything about deployment here is pretty straightforward:
- build the image;
- deploy the service.

Docker's multi-stage build is being utilized to make resulting image small in size.
Sources are pulled from `master` branch by default.
There's a code-modification trick being applied to allow the `console` CLI tool to connect to the node remotely (see the [Dockerfile](./Dockerfile) for details).

Deployment assumes Docker Compose usage.
There are few variables to set up &mdash; see [.env](.env) for details.

Firstly, build:
```console
$ docker-compose build --no-cache --build-arg GC_TON_NODE=<github commit id> node
```

Then deploy:
```console
$ docker-compose up --detach --force-recreate node
```

When the node starts syncing, you'll be able to see the progress via the command below:
```console
$ docker-compose exec node console --cmd getstats
```

__NOTE__: all the tools from [ton-labs-node-tools](https://github.com/tonlabs/ton-labs-node-tools) are accessible via `exec` command like the one above.
