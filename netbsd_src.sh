#!/bin/sh

#
# Time-stamp: <2024/07/20 20:03:14 (UT+8) daisuke>
#

###########################################################################
#
# NetBSD utils
#
#  netbsd_src.sh
#
#   utility to manage NetBSD source tree
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
#  -d : directory where finding "src" and "xsrc" directories (default: /usr)
#  -h : printing help message
#  -r : revision (default: netbsd-10)
#  -s : CVS repository (default: anoncvs@anoncvs.NetBSD.org:/cvsroot)
#  -v : verbosity level (default: 0)
#

#
# positional arguments
#
#  action: fetch, update
#

#
# usage
#
#  downloading NetBSD-current source code to /usr/src and /usr/xsrc
#   % netbsd_src.sh -r current -d /usr fetch
#
#  downloading NetBSD-10 source code to /usr/src and /usr/xsrc
#   % netbsd_src.sh -r netbsd-10 -d /usr fetch
#
#  downloading NetBSD-9 source code to /usr/src and /usr/xsrc
#   % netbsd_src.sh -r netbsd-9 -d /usr fetch
#
#  updating existing /usr/src and /usr/xsrc
#   % netbsd_src.sh -d /usr update
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
revision='netbsd-10'

# verbosity level
verbosity=0

###########################################################################

###########################################################################

#
# functions
#

# function to print help message
print_help_message () {
    echo "$0"
    echo ""
    echo "Utility to manage NetBSD source tree"
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
    echo "  -d : directory where finding \"src\" directory (default: /usr)"
    echo "  -h : printing help message"
    echo "  -r : revision (current, netbsd-9, netbsd-10, ...)"
    echo "  -s : CVS root (default: anoncvs@anoncvs.NetBSD.org:/cvsroot)"
    echo "  -v : verbosity level (default: 0)"
    echo ""
    echo "POSITIONAL ARGUMENTS"
    echo ""
    echo "  action : \"fetch\" or \"update\""
    echo ""
}

# function to fetch src and xsrc
src_fetch () {
    # changing directory
    cd $dir_base
    # command to fetch src and xsrc
    if [ $revision = "current" ]
    then
	command_src="$cvs -d $cvs_root -q checkout -P src"
	command_xsrc="$cvs -d $cvs_root -q checkout -P xsrc"
    else
	command_src="$cvs -d $cvs_root -q checkout -r $revision -P src"
	command_xsrc="$cvs -d $cvs_root -q checkout -r $revision -P xsrc"
    fi

    # printing status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# starting to fetch src and xsrc of NetBSD"
	echo "#"
	echo "#  command: $command_src"
	echo "#  command: $command_xsrc"
	echo "#"
    fi

    # executing commands
    $command_src
    $command_xsrc

    # printing status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# finished to fetch src and xsrc of NetBSD"
	echo "#"
	echo "#  command: $command_src"
	echo "#  command: $command_xsrc"
	echo "#"
    fi
}

# function to update src and xsrc
src_update () {
    # existence check of directories
    check_existence
    
    # command to update src
    command_src="$cvs -q update -dP"
    # command to update xsrc
    command_xsrc="$cvs -q update -dP"

    # printing status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# starting to update src and xsrc of NetBSD"
	echo "#"
	echo "#  command: $command_src"
	echo "#  command: $command_xsrc"
	echo "#"
    fi

    # changing directory
    cd $dir_src
    # updating src
    $command_src

    # changing directory
    cd $dir_xsrc
    # updating xsrc
    $command_xsrc

    # printing status
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# finished to update src and xsrc of NetBSD"
	echo "#"
	echo "#  command: $command_src"
	echo "#  command: $command_xsrc"
	echo "#"
    fi
}

# function to check existence of directory
check_existence () {
    if [ ! -e $dir_src ]
    then
        echo "ERROR:"
        echo "ERROR: directory \"$dir_src\" does not exist!"
        echo "ERROR:"
        exit 1
    fi
    if [ ! -d $dir_src ]
    then
        echo "ERROR:"
        echo "ERROR: \"$dir_src\" is not a directory!"
        echo "ERROR:"
        exit 1
    fi

    if [ ! -e $dir_xsrc ]
    then
        echo "ERROR:"
        echo "ERROR: directory \"$dir_xsrc\" does not exist!"
        echo "ERROR:"
        exit 1
    fi
    if [ ! -d $dir_xsrc ]
    then
        echo "ERROR:"
        echo "ERROR: \"$dir_xsrc\" is not a directory!"
        echo "ERROR:"
        exit 1
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
    echo "#   dir_src         : $dir_src"
    echo "#   dir_xsrc        : $dir_xsrc"
    echo "#"
    echo "#  Commands"
    echo "#   cvs command     : $cvs"
    echo "#"
    echo "#  Verbosity level"
    echo "#   verbosity level : $verbosity"
    echo "#"
    echo "#  Action"
    echo "#   action          : $action"
    echo "#"
}

###########################################################################

###########################################################################

#
# command-line argument analysis
#

# command-line argument analysis
while getopts "c:d:hr:s:v" args
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
        h)
            # -h option: printing help message
            print_help_message
            exit 1
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

# src directory
dir_src=${dir_base}/src

# xsrc directory
dir_xsrc=${dir_base}/xsrc

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
if [ $action != "fetch" ] && [ $action != "update" ]
then
    echo "ERROR:"
    echo "ERROR: value for \"action\" must be \"fetch\" or \"update\"!"
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
    src_fetch
elif [ $action = "update" ]
then
    src_update
fi

if [ $verbosity -gt 0 ]
then
    print_parameters
fi

###########################################################################
