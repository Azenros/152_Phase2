#/bin/bash
make clean
clear
make
cat $1 | mini_l > $1.mil
