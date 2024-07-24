#!/bin/sh

#
# Time-stamp: <2024/07/24 09:12:46 (UT+8) daisuke>
#

###########################################################################
#
# NetBSD utils
#
#  utility to build custom kernel and user land
#
#  author: Kinoshita Daisuke
#
#  version 1: 22/Jul/2024
#
###########################################################################

###########################################################################
#
# usage
#
#  options:
#
#   -a : action (make or install, default: make)
#   -c : kernel config file (default: /usr/src/sys/arch/amd64/conf/GENERIC)
#   -d : base directory where source code is located (default: /usr)
#   -h : print help message
#   -j : number of CPU cores to be used for compilation (default: 1)
#   -t : build target (tools, kernel, modules, distribution, or updatecfg)
#        (default: tools)
#
#  examples:
#
#   building tools
#    % netbsd_build.sh -t tools -a make
#
#   building a custom kernel
#    % netbsd_build.sh -t kernel -a make -c /usr/src/sys/arch/amd64/conf/FOO
#
#   installing a custom kernel
#    % netbsd_build.sh -t kernel -a install -c /usr/src/sys/arch/amd64/conf/FOO
#
#   building modules
#    % netbsd_build.sh -t modules -a make
#
#   installing modules
#    % netbsd_build.sh -t modules -a install
#
#   building user land
#    % netbsd_build.sh -t distribution -a make
#
#   building user land using 4 CPU cores
#    % netbsd_build.sh -t distribution -a make -j 4
#
#   installing user land
#    % netbsd_build.sh -t distribution -a install
#
#   updating configuration files in /etc
#    % netbsd_build.sh -t updatecfg
#
###########################################################################

###########################################################################

#
# parameters
#

# locations of commands
awk='/usr/bin/awk'
cp='/bin/cp'
egrep='/usr/bin/egrep'
expr='/bin/expr'
mkdir='/bin/mkdir'
mv='/bin/mv'
rm='/bin/rm'

# number of cores to be used
ncore=1

# base directory
dir_base='/usr'

# custom kernel configuration file
file_cfg='/usr/src/sys/arch/amd64/conf/GENERIC'

# build target (tools or kernel or modules or distribution)
build_target='tools'

# action (make or install)
action='make'

# options
build_options='-O ../obj -T ../tools -U -x'

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
    echo "Utility to build custom kernel and user land for NetBSD"
    echo ""
    echo " (c) Kinoshita Daisuke, 2024"
    echo ""
    echo "USAGE:"
    echo ""
    echo "  $0 [options] files"
    echo ""
    echo "OPTIONS:"
    echo ""
    echo "  -a : action (make or install, default: make)"
    echo "  -c : kernel config file (default: /usr/src/sys/arch/amd64/conf/GENERIC)"
    echo "  -d : base directory where source code is located: (default: /usr)"
    echo "  -h : printing help message"
    echo "  -j : number of CPU cores to be used (default: 1)"
    echo "  -t : build target (tools, kernel, modules, or distribution, default: tools)"
    echo "  -v : verbosity level (default: 0)"
    echo ""
}

###########################################################################

###########################################################################

#
# command-line argument analysis
#

# command-line argument analysis
while getopts "a:c:d:hj:t:v" args
do
    case "$args" in
	a)
	    # -a option: action
	    action=$OPTARG
	    ;;
	c)
	    # -c option: configuration file for custum kernel
	    file_cfg=$OPTARG
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
        j)
            # -j option: number of CPU cores to be used
            ncore=$OPTARG
            ;;
	t)
	    # -t option: target
	    build_target=$OPTARG
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

# check of value of "action"
if [ $action != "make" ] && [ $action != "install" ]
then
    echo "ERROR:"
    echo "ERROR: value for action must be either \"make\" or \"install\"!"
    echo "ERROR:"
    exit 1
fi

# check of value of build_target
if [ $build_target != "tools" ] && [ $build_target != "kernel" ] && [ $build_target != "modules" ] && [ $build_target != "distribution" ] && [ $build_target != "updatecfg" ]
then
    echo "ERROR:"
    echo "ERROR: value for distribution must be either"
    echo "ERROR: \"tools\" or \"kernel\" or \"modules\""
    echo "ERROR: or \"distribution\" or \"updatecfg\"!"
    echo "ERROR:"
    exit 1
fi

# priting parameters
if [ $verbosity -gt 0 ]
then
    echo "#"
    echo "# parameters given"
    echo "#"
    echo "#  dir_base     = $dir_base"
    echo "#  ncore        = $ncore"
    echo "#  file_cfg     = $file_cfg"
    echo "#  build_target = $build_target"
    echo "#  action       = $action"
    echo "#  verbosity    = $verbosity"
    echo "#"
fi

###########################################################################

###########################################################################

#
# checks of files and directories
#

# directories and files
dir_src="${dir_base}/src"
dir_xsrc="${dir_base}/xsrc"
dir_obj="${dir_src}/../obj"
dir_tools="${dir_src}/../tools"
file_buildsh="${dir_src}/build.sh"
file_paramh="${dir_src}/sys/sys/param.h"

# check of source directory
if [ ! -e $dir_base ];
then
    echo "ERROR:"
    echo "ERROR: $dir_base does not exist!"
    echo "ERROR:"
    exit 1
fi
if [ ! -d $dir_base ];
then
    echo "ERROR:"
    echo "ERROR: $dir_base is not a directory!"
    echo "ERROR:"
    exit 1
fi

# check of src directory
if [ ! -e "$dir_src" ];
then
    echo "ERROR:"
    echo "ERROR: directory $dir_src does not exist!"
    echo "ERROR:"
    exit 1
fi
if [ ! -d "$dir_src" ];
then
    echo "ERROR:"
    echo "ERROR: $dir_src is not a directory!"
    echo "ERROR:"
    exit 1
fi

# check of xsrc directory
if [ ! -e "$dir_xsrc" ];
then
    echo "ERROR:"
    echo "ERROR: directory $dir_xsrc does not exist!"
    echo "ERROR:"
    exit 1
fi
if [ ! -d "$dir_xsrc" ];
then
    echo "ERROR:"
    echo "ERROR: $dir_xsrc is not a directory!"
    echo "ERROR:"
    exit 1
fi

# check of build.sh file
if [ ! -e "$file_buildsh" ]
then
    echo "ERROR:"
    echo "ERROR: file $file_buildsh does not exist!"
    echo "ERROR:"
fi

# check of param.h file
if [ ! -e "$file_paramh" ]
then
    echo "ERROR:"
    echo "ERROR: file $file_paramh does not exist!"
    echo "ERROR:"
fi

# check of kernel configuration file
if [ ! -e "$file_cfg" ]
then
    echo "ERROR:"
    echo "ERROR: file $file_cfg does not exist!"
    echo "ERROR:"
fi

###########################################################################

#
# carrying out build process
#

# changing directory
cd $dir_src

# build
if [ $build_target = "tools" ]
then
    if [ $action = "make" ]
    then
	# if obj directory exists, then remove
	if [ -e $dir_obj ]
	then
	    # commands to be executed
	    command_rename_obj="$mv ${dir_obj} ${dir_obj}.old"
	    command_delete_obj="bg $rm -rf ${dir_obj}.old"
	    command_make_obj="$mkdir ${dir_obj}"
	    # executing commands
	    $command_rename_obj
	    $command_delete_obj
	    $command_make_obj
	    # printing information
	    if [ $verbosity -gt 0 ]
	    then
		echo "#"
		echo "# executed commands"
		echo "#"
		echo "#  $command_rename_obj"
		echo "#  $command_delete_obj"
		echo "#  $command_make_obj"
		echo "#"
	    fi
	fi
	# if obj directory exists, then remove
	if [ -e $dir_tools ]
	then
	    # commands to be executed
	    command_rename_tools="$mv ${dir_tools} ${dir_tools}.old"
	    command_delete_tools="bg $rm -rf ${dir_tools}.old"
	    command_make_tools="$mkdir ${dir_tools}"
	    # executing commands
	    $command_rename_tools
	    $command_delete_tools
	    $command_make_tools
	    # printing information
	    if [ $verbosity -gt 0 ]
	    then
		echo "#"
		echo "# executed commands"
		echo "#"
		echo "# $command_rename_tools"
		echo "# $command_delete_tools"
		echo "# $command_make_tools"
		echo "#"
	    fi
	fi
	# command to be executed
	command_build="$file_buildsh $build_options -j $ncore $build_target"
	# executing command
	$command_build
	# printing information
	if [ $verbosity -gt 0 ]
	then
	    echo "#"
	    echo "# executed command"
	    echo "#"
	    echo "# $command_build"
	    echo "#"
	fi
    else
	echo "ERROR:"
	echo "ERROR: no action \"install\" for build target \"tools\""
	echo "ERROR:"
	exit 1
    fi
elif [ $build_target = "kernel" ]
then
    if [ $action = "make" ]
    then
	# command to be executed
	command_build="$file_buildsh $build_options -j $ncore ${build_target}=${file_cfg}"
	# executing command
	$command_build
	# printing information
	if [ $verbosity -gt 0 ]
	then
	    echo "#"
	    echo "# executed commands"
	    echo "#"
	    echo "# $command_build"
	    echo "#"
	fi
    else
	# acquiring kernel version number
	line=`$egrep '^#define[[:space:]]__NetBSD_Version__' $file_paramh`
	version=`echo $line | $awk '{print $3}'`
	# acquiring kernel configuration file name
	cfg=${file_cfg##*/}
	# acquiring architecture name
	arch=`echo $file_cfg | $awk -F'/' '{print $6}'`
	# commands to be executed
	command_rename="$mv -f /netbsd /netbsd.old"
	command_install1="$cp ${dir_obj}/sys/arch/${arch}/compile/${cfg}/netbsd /netbsd"
	command_install2="$cp ${dir_obj}/sys/arch/${arch}/compile/${cfg}/netbsd /netbsd.${version}.${cfg}"
	# executing commands
	$command_rename
	$command_install1
	$command_install2
	# printing information
	if [ $verbosity -gt 0 ]
	then
	    echo "#"
	    echo "# executed commands"
	    echo "#"
	    echo "# $command_rename"
	    echo "# $command_install1"
	    echo "# $command_install2"
	    echo "#"
	fi
    fi
elif [ $build_target = "modules" ]
then
     if [ $action = "make" ]
     then
	 # command to be executed
	 command_build="$file_buildsh $build_options -j $ncore modules"
	 # executing command
	 $command_build
	 # printing information
	 if [ $verbosity -gt 0 ]
	 then
	    echo "#"
	    echo "# executed command"
	    echo "#"
	    echo "# $command_build"
	    echo "#"
	 fi
     else
	 # command to be executed
	 command_install="$file_buildsh $build_options -j $ncore installmodules=/"
	 # executing command
	 $command_install
	 # printing information
	 if [ $verbosity -gt 0 ]
	 then
	    echo "#"
	    echo "# executed command"
	    echo "#"
	    echo "# $command_install"
	    echo "#"
	 fi
     fi
elif [ $build_target = "distribution" ]
then
     if [ $action = "make" ]
     then
	 # command to be executed
	 command_build="$file_buildsh $build_options -j $ncore distribution"
	 # executing command
	 $command_build
	 
	 echo "$command_build"
     else
	 # command to be executed
	 command_install="$file_buildsh $build_options -j $ncore install=/"
	 # executing command
	 $command_install
	 # printing information
	 if [ $verbosity -gt 0 ]
	 then
	    echo "#"
	    echo "# executed command"
	    echo "#"
	    echo "# $command_install"
	    echo "#"
	 fi
     fi
elif [ $build_target = "updatecfg" ]
then
    # commands to be executed
    command_update1="/usr/sbin/postinstall -s $dir_src check"
    command_update2="/usr/sbin/postinstall -s $dir_src fix"
    command_update3="/usr/sbin/etcupdate -s $dir_src"
    # executing commands
    $command_update1
    $command_update2
    $command_update3
    # printing information
    if [ $verbosity -gt 0 ]
    then
	echo "#"
	echo "# executed command"
	echo "#"
	echo "# $command_update1"
	echo "# $command_update2"
	echo "# $command_update3"
	echo "#"
    fi
fi

# priting parameters
if [ $verbosity -gt 0 ]
then
    echo "#"
    echo "# parameters given"
    echo "#"
    echo "#  dir_base     = $dir_base"
    echo "#  ncore        = $ncore"
    echo "#  file_cfg     = $file_cfg"
    echo "#  build_target = $build_target"
    echo "#  action       = $action"
    echo "#  verbosity    = $verbosity"
    echo "#"
fi

###########################################################################
