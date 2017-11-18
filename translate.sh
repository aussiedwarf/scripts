#!/bin/bash
#translate /mnt/c paths to windows compatible paths

COMMAND=""

while [ "$1" != "" ]; do
    if [[ $1 == /mnt/* ]]
    then
      T="C:"${1:6}
      COMMAND="$COMMAND $T"
    elif [[ $1 == -I/mnt/* ]]
    then
      T=-IC:
      T="$T${1:8}"
      COMMAND="$COMMAND $T"
    
    elif [[ $1 == -L/mnt/* ]]
    then
      T=-LC:
      T="$T${1:8}"
      COMMAND="$COMMAND $T"
    else
      COMMAND="$COMMAND $1"
    fi
    
    shift
done

echo "TRANSLATE: $COMMAND"
$COMMAND
