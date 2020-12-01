#!/bin/bash
function f1 {
    echo in f1
    exit 2
    # script will get terminated here
    # echo $? - 2
    echo more in f1
}

echo starting
f1
echo after f1
