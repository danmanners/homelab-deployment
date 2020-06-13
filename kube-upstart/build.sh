#!/bin/bash
docker run --rm -v $(pwd):/mnt --env-file $(pwd)/env puppet/kubetool:5.1.0