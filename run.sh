#/bin/bash
make clean
clear
make
cat $1 | mini_l > $1.mil
echo $1.mil
echo "Running mil_run on generated mil file..."
mil_run $1.min
