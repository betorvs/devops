#!/bin/bash

DIR="$PWD/$1"

docker run --rm -t -v $DIR:/vol -i centos:centos6 /bin/bash
