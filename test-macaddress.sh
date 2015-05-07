#!/bin/bash

MAC="$1"

#echo $MAC |grep  ^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}$ && echo "valid" || echo "invalid"
echo $MAC |grep -q "^\([0-9A-Fa-f]\{2\}:\)\{5\}[0-9A-Fa-f]\{2\}$" || echo "error"
