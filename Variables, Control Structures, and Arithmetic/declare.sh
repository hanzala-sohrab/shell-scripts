#!/bin/bash
declare -l lstring="ABCdef"
declare -u ustring="ABCdef"
declare -r readonly="A Value"
declare -a Myarray
declare -A Myarray1

echo lstring = $lstring
echo ustring = $ustring
echo readonly = $readonly
readonly="new val"
Myarray[2]="2nd val"
echo 'Myarray[2]= ' ${Myarray[2]}
Myarray1["hotdog"]="baseball"
echo 'Myarray1[hotdog]= ' ${Myarray1["hotdog"]}
