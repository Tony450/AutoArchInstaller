#!/bin/bash

echo "$(hostnamectl | grep "Operating System" | cut -d ':' -f 2 | xargs) $(uname -r)"