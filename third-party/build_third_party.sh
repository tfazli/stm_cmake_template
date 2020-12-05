#!/bin/bash

E_HIGHLIGHT="\033[1;35m"
E_NORMAL="\033[0m"
set -e

skip=0
if [ "$1" = "--proceed" ]; then
    skip=1
fi

DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $DIR/src
for script in *.sh;
do
    if [ $skip -eq 1 ]; then
        if [ "$script" = "$2" ]; then
            skip=0
        else
            echo -e "\n${E_HIGHLIGHT}$script${E_NORMAL} skipped\n"
            continue;
        fi
    fi
    echo -e "\n${E_HIGHLIGHT}$script${E_NORMAL}\n"
    ./$script
done

echo -e "\n${E_HIGHLIGHT}Finished building third party${E_NORMAL}\n"

