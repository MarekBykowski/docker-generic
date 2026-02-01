#!/bin/bash

set -x

cat <<-'EOF'
Dockerfile and image are intended to be used without and behind the proxy.
Localize these files and decide:
- Dockerfile::COPY apt.conf /etc/apt/
- .bash_aliases::Prevent from exporting it with `if [[ ! : ]]; then <proxy>; fi`
EOF

username=$USER

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
	  -v /home/${username}:/home/${username}/host
	  -v $PWD/workdir:/home/${username}/workdir
	  -v /lib/modules:/lib/modules
	  -v /boot:/boot
	)

if [[ $1 == b ]]; then
	docker build --no-cache \
	  --build-arg username=${username} --build-arg gid=$(id -g) \
	  --build-arg uid=$(id -u) --build-arg password=password \
		-t $docker_image .
elif [[ $1 == r ]]; then
	docker run -d ${args[@]} $docker_image
elif [[ $1 == m ]]; then
	cat <<- EOF
	docker stop $docker_container
	docker rm $docker_container
	docker rmi $docker_image
	docker commit -m "Update" $docker_container $docker_image
	docker run -d ${args[@]} $docker_image
	EOF
fi
