#!/bin/sh

#
# Time-stamp: <2024/07/20 12:35:38 (UT+8) daisuke>
#

###########################################################################
#
# NetBSD utils
#
#  netbsd_pkgsrc.sh
#
#   utility to manage pkgsrc
#
#   author: Kinoshita Daisuke
#
#   version 1.0: 20/Jul/2024
#
###########################################################################

###########################################################################

#
# optional arguments
#

#
#  -c : location of "cvs" command (default: /usr/bin/cvs)
#  -d : directory where finding "pkgsrc" directory (default: /usr)
#  -e : location of "expr" command (defualt: /bin/expr)
#  -h : printing help message
#  -m : location of "make" command (default: /usr/bin/make)
#  -r : revision (default: pkgsrc-2024Q2)
#  -s : CVS repository (default: anoncvs@anoncvs.NetBSD.org:/cvsroot)
#  -v : verbosity level (default: 0)
#

#
# positional arguments
#
#  action: fetch, update, clean
#

#
# usage
#
#  downloading pkgsrc-current to /usr/pkgsrc
#   % netbsd_pkgsrc.sh -r current -d /usr fetch
#
#  downloading pkgsrc-2020Q1 to /usr/pkgsrc
#   % netbsd_pkgsrc.sh -r pkgsrc-2020Q1 -d /usr fetch
#
#  downloading pkgsrc-2024Q2 to /usr/pkgsrc
#   % netbsd_pkgsrc.sh -r pkgsrc-2024Q2 -d /usr fetch
#
#  updating existing /usr/pkgsrc
#   % netbsd_pkgsrc.sh -d /usr update
#
#  cleaning "work" directories under /usr/pkgsrc
#   % netbsd_pkgsrc.sh -d /usr clean
#

###########################################################################

###########################################################################

#
# default values of parameters
#

# cvs command
cvs='/usr/bin/cvs'

# expr command
expr='/bin/expr'

# make command
make='/usr/bin/make'

# CVS root
cvs_root='anoncvs@anoncvs.NetBSD.org:/cvsroot'

# base directory
dir_base='/usr'

# revision
revision='pkgsrc-2024Q2'

# verbosity level
verbosity=0

# list of work directories in pkgsrc source tree
list_workdir=""

# number of work directories to be cleaned
n_dir=0

###########################################################################

###########################################################################

#
# functions
#

# function to print help message
print_help_message () {
    echo "$0"
    echo ""
    echo "Utility to manage pkgsrc source tree for NetBSD"
    echo ""
    echo " (c) Kinoshita Daisuke, 2024"
    echo ""
    echo "USAGE:"
    echo ""
    echo "  $0 [options] action"
    echo ""
    echo "OPTIONAL ARGUMENTS:"
    echo ""
    echo "  -c : location of \"cvs\" command (default: /usr/bin/cvs)"
    echo "  -d : directory where finding \"pkgsrc\" directory (default: /usr)"
    echo "  -e : location of \"expr\" command (default: /bin/expr)"
    echo "  -h : printing help message"
    echo "  -m : location of \"make\" command (default: /usr/bin/make)"
    echo "  -r : revision (current, pkgsrc-2024Q1, pkgsrc-2024Q2, ...)"
    echo "  -s : CVS root (default: anoncvs@anoncvs.NetBSD.org:/cvsroot)"
    echo "  -v : verbosity level (default: 0)"
    echo ""
    echo "POSITIONAL ARGUMENTS"
    echo ""
    echo "  action : \"fetch\" or \"update\" or \"clean\""
    echo ""
}

# function to fetch pkgsrc source tree
pkgsrc_fetch () {
    # changing directory
    cd $dir_base
    # command to fetch pkgsrc source tree
    if [ $revision = "current" ]
    then
	command_cvs="$cvs -d $cvs_root -q checkout -P pkgsrc"
    else
	command_cvs="$cvs -d $cvs_root -q checkout -r $revision -P pkgsrc"
    fi
    # priting status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# starting to fetch pkgsrc source tree"
	echo "#"
	echo "#  command: $command_cvs"
	echo "#"
    fi
    # executing command
    $command_cvs
    # priting status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# finished to fetch pkgsrc source tree"
	echo "#"
	echo "#  command: $command_cvs"
	echo "#"
    fi
}

# function to update pkgsrc source tree
pkgsrc_update () {
    # changing directory
    cd $dir_pkgsrc
    # command to update pkgsrc source tree
    command_cvs="$cvs -q update -dP"
    # priting status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# starting to update pkgsrc source tree"
	echo "#"
	echo "#  command: $command_cvs"
	echo "#"
    fi
    # executing command
    $command_cvs
    # priting status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# finished to update pkgsrc source tree"
	echo "#"
	echo "#  command: $command_cvs"
	echo "#"
    fi
}

# function to clean work directories of pkgsrc source tree
pkgsrc_clean () {
    # changing directory
    cd $dir_pkgsrc

    # priting status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# now, finding work directories of pkgsrc source tree"
	echo "#"
    fi
    # finding work directories
    for dir_work in $dir_pkgsrc/*/*/work*
    do
	# appending work directory to the list
	list_workdir="$list_workdir $dir_work"
	# counting number of work directories
	n_dir=`$expr $n_dir + 1`
    done
    # priting status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# finished finding work directories of pkgsrc source tree"
	echo "#"
    fi
    
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# list of work directories to be cleaned:"
	echo "#"
	for dir_work in $list_workdir
	do
            echo "#  $dir_work"
	done
	echo "#"
	echo "# number of work directories to be cleaned = $n_dir"
	echo "#"
    fi

    # priting status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# now, cleaning work directories of pkgsrc source tree"
	echo "#"
    fi
    # cleaning work directories
    for dir_work in $list_workdir
    do
	if [ -e $dir_work ]
	then
            dir_package=${dir_work%/*}
            cd $dir_package
            $make clean
	fi
    done
    # priting status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# finished cleaning work directories of pkgsrc source tree"
	echo "#"
    fi
}

# function to print input parameters
print_parameters () {
    echo "#"
    echo "# input parameters"
    echo "#"
    echo "#  CVS server"
    echo "#   CVS_ROOT        : $cvs_root"
    echo "#   Revision        : $revision"
    echo "#"
    echo "#  Directories"
    echo "#   dir_base        : $dir_base"
    echo "#   dir_pkgsrc      : $dir_pkgsrc"
    echo "#"
    echo "#  Commands"
    echo "#   cvs command     : $cvs"
    echo "#   expr command    : $expr"
    echo "#   make command    : $make"
    echo "#"
    echo "#  Verbosity level"
    echo "#   verbosity level : $verbosity"
    echo "#"
    echo "#  Action"
    echo "#   action          : $action"
    echo "#"
}

# function to check existence of directory
check_existence () {
    if [ ! -e $dir_pkgsrc ]
    then
	echo "ERROR:"
	echo "ERROR: directory \"$dir_pkgsrc\" does not exist!"
	echo "ERROR:"
	exit 1
    fi
    if [ ! -d $dir_pkgsrc ]
    then
	echo "ERROR:"
	echo "ERROR: \"$dir_pkgsrc\" is not a directory!"
	echo "ERROR:"
	exit 1
    fi
}

###########################################################################

###########################################################################

#
# command-line argument analysis
#

# command-line argument analysis
while getopts "c:d:hr:s:" args
do
    case "$args" in
	c)
	    # -c option: location of "cvs" command
	    cvs=$OPTARG
	    ;;
        d)
            # -d option: base directory
            dir_base=$OPTARG
            ;;
	e)
	    # -e option: location of "expr" command
	    expr=$OPTARG
	    ;;
        h)
            # -h option: printing help message
            print_help_message
            exit 1
            ;;
	m)
	    # -m option: loation of "make" command
	    make=$OPTARG
	    ;;
        r)
            # -r option: revision
            revision=$OPTARG
            ;;
	s)
	    # -s option: CVS root
	    cvs_root=$OPTARG
	    ;;
	v)
	    # -v option: verbosity level
	    verbosity=`$expr $verbosity + 1`
	    ;;
        \?)
            print_help_message
            exit 1
    esac
done
shift $((OPTIND - 1))

# pkgsrc directory
dir_pkgsrc=${dir_base}/pkgsrc

# check existence of pkgsrc directory
check_existence

# if length of the first positional argument is zero, then stop
if [ -z $1 ]
then
    echo "ERROR:"
    echo "ERROR: one positional argument has to be given!"
    echo "ERROR:  \"fetch\" or \"update\" or \"clean\""
    echo "ERROR:"
    exit 1
fi

# if length of the second positional argument is non-zero, then stop
if [ ! -z $2 ]
then
    echo "ERROR:"
    echo "ERROR: number of positional arguments must be one!"
    echo "ERROR:"
    exit 1
fi

# positional argument
action=$1

# check of value of "action"
if [ $action != "fetch" ] && [ $action != "update" ] && [ $action != "clean" ]
then
    echo "ERROR:"
    echo "ERROR: value for \"action\" must be \"fetch\" or \"update\" or \"clean\"!"
    echo "ERROR:"
    exit 1
fi

###########################################################################

###########################################################################

#
# management of pkgsrc source tree
#

if [ $verbosity -gt 0 ]
then
    print_parameters
fi

if [ $action = "fetch" ]
then
    pkgsrc_fetch
elif [ $action = "update" ]
then
    pkgsrc_update
elif [ $action = "clean" ]
then
    pkgsrc_clean
fi

if [ $verbosity -gt 0 ]
then
    print_parameters
fi

###########################################################################
