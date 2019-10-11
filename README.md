# Overview

This repository contains a *Dockerfile* for [Netatalk](http://netatalk.sourceforge.net), a freely-available Open Source AFP fileserver. AFP stands for *AppleShare file server* and it is the standard file server protocol used by macOS. Therefore, you can use a *netatalk* server as a file server for your Macs.

The Dockerfile is based on the work of [cptactionhank](https://hub.docker.com/r/cptactionhank/netatalk). However, it is updated to the latest version of *netatalk* and to the latest *Debian* release. I also integrated some of the things of the open pull requests of the original repository. The Dockerfile supports the architectures `linux/arm64`, `linux/arm/v7` and `linux/amd64`.

The remainder of this README is just a copy of the original one.

## I'm in the fast lane! Get me started

To quickly get started with running an [Netatalk] container first you can run the following command:

```bash
docker run --detach --publish 548:548 mytracks/netatalk:latest
```

**Important:** This does not announce the AFP service on the network; connecting to the server should be performed by Finder's `Go -> Connect Server (CMD+K)` and then typing `afp://[docker_host]`.

Default configuration of [Netatalk] has two share called _Share_ which shares the containers `/media/share` and called _TimeMachine_ which shares the containers `/media/timemachine` mounting point. Host mounting a volume to this path will be the quickest way to start sharing files on your network.

```bash
docker run --detach --volume [host_path]:/media/share --volume [host_path]:/media/timemachine --publish 548:548 mytracks/netatalk:latest
```

## The slower road

With the slower roads documentation some knowledge in administering Docker and [Netatalk] assumed.

### Configuring shares

There are two ways of configuring the [Netatalk] which is either by mounting a configuration file or editing the file from the container itself. Documentation of the configuration file `/etc/afp.conf` can be found [here](http://netatalk.sourceforge.net/3.1/htmldocs/afp.conf.5.html).

#### Host mounted configuration

This is quite a simple way to change the configuration by supplying an additional docker flag when creating the container.

```bash
docker run --detach --volume [host_path]:/etc/afp.conf --volume [host_path]:/media/share --volume [host_path]:/media/timemachine --publish 548:548 mytracks/netatalk:latest
```

#### Container edited configuration

Other ways of enabling customizations of the [Netatalk] configuration file is by mounting the `/etc` by `--volume /etc` such that this directory will remain persistent between restarts and then modify the configuration file. However the first option would be the recommended way to do this.

### Setting up access credentials

To setup access credentials you should supply the following environment variables from the table below.

|Variable           |Description|
|---------------|-----------|
|AFP_USER       | create a user in the container and allow it access to /media/share    |
|AFP_PASSWORD   | password
|AFP_UID        | _uid_ of the created user
|AFP_GID        | _gid_ of the created user

#### Example

```bash
docker run --detach \
    --volume /mnt/sda1/share:/media/share \
    --net "host" \
    --env AFP_USER=$(id -un) \
    --env AFP_PASSWORD=secret \
    --env AFP_UID=$(id -u) \
    --env AFP_GID=$(id -g) \
    mytracks/netatalk:latest
```

This replaces all occurrences of `%USER%` in `afp.conf` with `AFP_USER`

```ini
[Global]
log file = /var/log/netatalk.log

[Share]
path = /media/share
valid users = %USER%
```

### Service discovery

This image includes an avahi daemon which is off by default. Enable by setting the environment variable `AVAHI=1` with `docker run -e AVAHI=1 ...`

Service discovery works only when the [Avahi] daemon is on the same network as your users which is why you need to supply `--net=host` flag to Docker when creating the container, but do consider that `--net=host` is considered a security threat. Alternatively you can install and setup an mDNS server on the host and have this describing the AFP service for your container.

## Acknowledgments

Thanks to @rrva for his work updating this image to [Netatalk] version 3.1.8 and slimming down this image for everyone to enjoy.

## Contributions

This image has been created with the best intentions and an expert understanding of docker, but it should not be expected to be flawless. Should you be in the position to do so, I request that you help support this repository with best-practices and other additions.

If you see out of date documentation, lack of tests, etc., you can help out by either
- creating an issue and opening a discussion, or
- sending a pull request with modifications

This work is made possible with the great services from [Docker] and [GitHub].

[Netatalk]: http://netatalk.sourceforge.net/
[Docker]: https://www.docker.com/
[GitHub]: https://www.github.com/
[Avahi]: http://www.avahi.org/


