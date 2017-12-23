#!/bin/bash
#translate /mnt/c paths to windows compatible paths

COMMAND=""

while [ "$1" != "" ]; do
    if [[ $1 == /mnt/* ]]
    then
      T="D:"${1:6}
      COMMAND="$COMMAND $T"
    elif [[ $1 == -I/mnt/* ]]
    then
      T=-ID:
      T="$T${1:8}"
      COMMAND="$COMMAND $T"
    
    elif [[ $1 == -L/mnt/* ]]
    then
      T=-LD:
      T="$T${1:8}"
      COMMAND="$COMMAND $T"
    elif [[ $1 == -o/mnt/* ]]
    then
      T=-oD:
      T="$T${1:8}"
      COMMAND="$COMMAND $T"
    else
      COMMAND="$COMMAND $1"
    fi
    
    shift
done

echo "TRANSLATE: $COMMAND"
$COMMAND
