#!/bin/bash

skeletonDir="/home/skeleton"
if [[ -d "$skeletonDir" ]]; then
	useradd --create-home --skel "$skeletonDir" $@
else
	echo "Can't find skeleton directory: $skeletonDir"
fi
