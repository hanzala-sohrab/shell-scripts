export a=first
export b=second
export c=third
echo a is '['$a']' b is '['$b']' c is '['$c']'
read a b <data_file     # 1st word of 1st line will be stored in 'a' and the rest of the words in 'b'
echo a is '['$a']' b is '['$b']' c is '['$c']'
