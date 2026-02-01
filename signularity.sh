#!/bin/bash

set -x


docker_image=generic
docker_safe="${docker_image//:/_}"
singularity_image_tar=${docker_safe}.tar
singularity_image_sif=${docker_safe}.sif

if [[ $1 == convert ]]; then
	docker save $docker_image -o $singularity_image_tar

	DIR=/yocto
	SINGULARITY_TMPDIR="$DIR/.singularity/tmp"
	SINGULARITY_CACHEDIR="$DIR/.singularity/cache"
	mkdir -p "$SINGULARITY_TMPDIR" "$SINGULARITY_CACHEDIR"
	export SINGULARITY_TMPDIR
	export SINGULARITY_CACHEDIR

	echo SINGULARITY_TMPDIR=$SINGULARITY_TMPDIR
	echo SINGULARITY_CACHEDIR=$SINGULARITY_CACHEDIR

	singularity build $singularity_image_sif docker-archive://$singularity_image_tar
elif [[ $1 == run ]]; then
	image=$singularity_image_sif

	singularity exec \
		--env PATH="$PATH" \
		$image \
		echo "PATH from within container: $PATH"

	singularity shell \
		--env PATH="$PATH" \
		$image
	:<<-EOF
	singularity exec \
		--env PATH="$PATH" \
		$image \
		sh -c '
		  set -e
		  test -d workdir || mkdir -p workdir
		  cd workdir
		  QCOW="$PWD/core-image-cxl-sdk-cxlx86-64.rootfs.wic.qcow2"
		  exec run_qemu.pl \
		    -dbg 0x3 \
		    -dut bfm=cxl2.0 \
		    -qc "$QCOW" \
		    -ovmf \
		    -kvm \
		    -nographic \
		    -ip localhost:9230
		'
	EOF
fi
