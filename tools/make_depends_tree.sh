usage () {
	echo "usage: $0 [ <MOD_DIR | MOD_FILE> | <MOD_DIR MOD_FILE>"
	echo "Reading the MOD_DIR directory(ies) or the MOD_FILE file(s)"
	echo "print the dependancy list"
}

getmodname() { 
	# given a directory, return the name of fortran modules in it
	grep -iHER '^\ *module\ [^ ]*$' $1/*.f90 | # -i because fortran is case insensitive
	awk -F ':' '{print $2}' | 
	awk '{print $2}'
}

getmodfile() {
	# given a directory, return the name of fortran module file in it
	grep -iHER '^\ *module\ [^ ]*$' $1/*.f90 | # -i because fortran is case insensitive
	awk -F ':' '{print $1}'
}

get_modules_name_from_file() { 
	# given a module file, print the index of all the module used in it
	if [[ $# -ne 1 ]];then
		echo "get_modules_name_from_file: <module> missing"
		exit
	fi
	local module=$1
	grep -iE '^\ *use\ *[^ ]*$' $module | 
	awk '{print $2}' | 
	while read used_mod ; do
		i=0
			while [[ ${MOD_NAME[$i]^^} != ${used_mod^^} && $i -le ${#MOD_NAME[@]} ]];do # fortran isn't case sensitive so we won't either
			i=$(( $i + 1 ))
		done
		echo $i
	done
}

get_modules_recursively() {
	# Recursiv functions that takes modules names in arg.
	# for each module used in each parameter, call the function in this module
	# then print the args.
	# So the will travel trough the dependancies, the deeper the module, the highest in the tree
	used_mod=( $( for module in $@; do
		for i in $( get_modules_name_from_file $module ); do
			echo ${MOD_FILE[$i]}
		done 
	done) )
	if [[ ${#used_mod[@]} -gt 0 ]];then
		get_modules_recursively ${used_mod[@]}
	fi
	echo $@
}

delete_multiple_args() {
	# Given several args, for each args, look for duplicate in the following and delete them
	# At the end, each arg is unique ans the order is preserved
	local ARGS="$@"
	local cur
	while [[ ${#ARGS} -gt 0 ]]; do
		cur=$(echo $ARGS | awk '{print $1}')
		curn=${cur//\//\\/}
		ARGS=$(echo $ARGS | sed "s/${curn}//g")
		echo -n "$cur "
	done
}

case $# in
0)	
	usage
	exit 0;;
1)
	if [[ -f $1 ]] ;then
		INPUT=$1
		DIR=$(dirname $INPUT)
		FROMFILE=1
	elif [[ -d $1 ]] ;then
		DIR=${1/%\/}
		INPUT=($( getmodfile $DIR ))
	fi
	;;
2)
	if [[ -d $1 ]] ;then
		DIR=${1/%\/}
	else
		echo "error:$0 $1 $2: $1 must be a directory"
		ERR=1
	fi
	if  [[ -f $2 ]]; then
		INPUT=$2
		FROMFILE=1
	else
		echo "error:$0 $1 $2: $2 must be a regular file"
		ERR=1
	fi
	if [[ $ERR -eq 1 ]]; then
		exit 1
	fi
	;;
*)
	echo "$0:error: too much arguments"
	exit 2
	;;
esac

MOD_FILE=( $( getmodfile $DIR ) )
MOD_NAME=( $( getmodname $DIR ) )

DEPEND_LIST=($( delete_multiple_args $(get_modules_recursively ${INPUT[@]}) ))
echo "${DEPEND_LIST[@]}"

