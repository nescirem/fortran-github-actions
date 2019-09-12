#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
none='\e[0m'

###################
# gfortran | ifort | 
Compiler=$1
# debug | release |
DEBUG=$2
###################

if [ -z $Compiler  ];then
	if [ `command -v gfortran` ];then Compiler="gfortran";
	elif [ `command -v ifort` ];then Compiler="ifort";
	else
		echo -e "$red No supported fortran compiler is installed, please install Intel fortran or GUN fortran$none" && exit 1
	fi
fi
if [ -z $DEBUG  ]; then DEBUG="release"; fi;

shpath=$(cd `dirname $0`; pwd)

if [ `command -v sudo`  ];then
	sudo="sudo"
else
	sudo=""
fi

# make clean
echo -e "$yellow clean$none"
cd $shpath/ && make clean

# make executable program
echo -e "$green build executable file 'main'$none"
cd $shpath/
make all FC=$Compiler DDBUG=$DEBUG

echo  -e "$green Done.$none"
echo

# run test
sleep 1
echo  -e "$green Run executable file './bin/main'$none"
echo " --------------------------------"
cd $shpath/bin
eval ./main
echo " --------------------------------"
