#!/usr/bin/env bash
# sudo chmod +x *.sh
# ./test.sh
set -euo pipefail
IFS=$'\n\t'


array=( "one" "two" "three" )
for i in "${array[@]}"
do
	echo $i
done 