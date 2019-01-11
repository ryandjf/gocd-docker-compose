#!/bin/sh

set -x

if [ "$(id -u)" = "0" ]; then
  # get gid of docker socket file
  SOCK_DOCKER_GID=`ls -ng /var/run/docker.sock | cut -f3 -d' '`
  echo "SOCK_DOCKER_GID is $SOCK_DOCKER_GID"
  
  # get group of docker inside container
  if [ $(getent group docker) ]; then
    echo "group docker exists."
  else
    echo "group docker does not exist."
    groupadd docker
  fi
  
  CUR_DOCKER_GID=`getent group docker | cut -f3 -d: || true`

  # if they don't match, adjust
  if [ ! -z "$SOCK_DOCKER_GID" -a "$SOCK_DOCKER_GID" != "$CUR_DOCKER_GID" ]; then
    groupmod -g ${SOCK_DOCKER_GID} -o docker
    echo "Modify group id"
  fi
  if ! groups go | grep -q docker; then
    usermod -aG docker go
    echo "add go user to docker group"
  fi
fi
