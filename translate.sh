#!/bin/bash
#translate /mnt/c paths to windows compatible paths

COMMAND=""

while [ "$1" != "" ]; do
    if [[ $1 == /mnt/* ]]
    then
      T=${1:6}
      COMMAND="$COMMAND $T"
    else
      COMMAND="$COMMAND $1"
    fi
    
    shift
done

$COMMAND
