#!/bin/bash

# looping over each word
for i in dog cat hotdog
do
    echo i is $i
done

# looping over 3 4 5
for i in `seq 3 5`
do
    echo i in seq is $i
done

# looping over N L M N O P
for i in {N..P}
do
    echo i in letter list is $i
done

# looping over all the words in a file
for d in $(<data_file)
do
    echo d in data_file is $d
done

# looping over all the file names having the word 'grub' in them
for f in $(find /etc 2>/dev/null | grep grub)
do
    echo grub named things are $f
done
