#!/bin/bash
declare -l lstring="ABCdef"     # for lowercase
declare -u ustring="ABCdef"     # for uppercase
declare -r readonly="A Value"
declare -a Myarray              # Array indexed using integers
declare -A Myarray1             # Array indexed using strings

echo lstring = $lstring
echo ustring = $ustring
echo readonly = $readonly
readonly="new val"
Myarray[2]="2nd val"
echo 'Myarray[2]= ' ${Myarray[2]}
Myarray1["hotdog"]="baseball"
echo 'Myarray1[hotdog]= ' ${Myarray1["hotdog"]}
