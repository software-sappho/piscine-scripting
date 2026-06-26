#!/bin/bash

mkdir struct
cd struct
mkdir 0 1 2 3 4 5 6 7 8 9 A
touch 3/text.txt
touch 4/text2.txt
touch A/text3.txt
tar -cf file-struct.tar *
mv file-struct.tar ..