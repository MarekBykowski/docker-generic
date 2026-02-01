#!/bin/bash

set -x

docker_image=generic
docker_safe="${docker_image//:/_}"
docker_container=${docker_safe}_hello

args=(
	  --name $docker_container
	  --hostname $docker_safe
	  --privileged
	  --restart always
	  -p 50022:22
	  -p 55900:5900
	  -p 56080:6080
	  -v /home/mbykowsx:/home/mbykowsx/host
	  -v $PWD/workdir:/home/mbykowsx/workdir
	  -v /lib/modules:/lib/modules
	  -v /boot:/boot
	)

if [[ $1 == b ]]; then
	docker build --no-cache \
	  --build-arg username=mbykowsx --build-arg gid=$(id -g) \
	  --build-arg uid=$(id -u) --build-arg password=password \
		-t $docker_image .
elif [[ $1 == r ]]; then
	:<<-EOF
	docker run -d \
	  --name $docker_container \
	  --hostname $docker_safe \
	  --privileged \
	  -p 50022:22 \
	  -p 55900:5900 \
	  -p 56080:6080 \
	  -v /home/mbykowsx:/home/mbykowsx/host \
	  -v $PWD/workdir:/home/mbykowsx/workdir \
	  -v /lib/modules:/lib/modules \
	  -v /boot:/boot \
	  $docker_image
	EOF
	docker run -d ${args[@]} $docker_image
elif [[ $1 == m ]]; then
	cat <<- EOF
	docker stop $docker_container
	docker rm $docker_container
	docker commit -m "Update" $docker_container $docker_image
	docker run -d ${args[@]} $docker_image
	EOF
fi
