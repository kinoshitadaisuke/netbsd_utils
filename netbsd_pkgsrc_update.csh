#!/bin/csh

#
# Time-stamp: <2022/03/19 11:54:36 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to update pkgsrc
#
#  author: Kinoshita Daisuke
#
#  version 1: 13/Mar/2022
#

#
# examples:
#
#  updating /usr/pkgsrc
#    % netbsd_pkgsrc_update.csh /usr/pkgsrc
#

# locations of commands
set rm  = /bin/rm
set cvs = /usr/bin/cvs

# initial value
# an empty list for storing target directories
set list_target = ()

# directories and files
set dir_tmp    = /tmp
set file_usage = ${dir_tmp}/netbsd_pkgsrc_fetch.$$

# usage message
cat <<EOF > $file_usage
netbsd_pkgsrc_update.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -h : printing help message

 Examples:
  updating /usr/pkgsrc
    % netbsd_pkgsrc_update.csh /usr/pkgsrc
  updating /usr/pkgsrc and /work/netbsd/pkgsrc
    % netbsd_pkgsrc_update.csh /usr/pkgsrc /work/netbsd/pkgsrc

EOF

# number of command-line arguments must be 1 or greater
if ($#argv == 0) then
    # printing usage
    cat $file_usage
    # deleting usage file
    $rm -f $file_usage
    # stop the script
    exit
endif

# command-line argument analysis
while ($#argv != 0)
    switch ($argv[1])
	# -h option
	case "-h":
	    # printing usage
	    cat $file_usage
	    # deleting usage file
	    $rm -f $file_usage
	    # stop the script
	    exit
	case -*:
	    # printing message
	    echo ""
	    echo "ERROR: '$argv[1]' is an invalid option!"
	    echo ""
	    # printing usage
	    cat $file_usage
	    # deleting usage file
	    $rm -f $file_usage
	    # stop the script
	    exit
	default:
	    set list_target = ($list_target $argv[1])
     endsw
     shift
end

# processing for each target directories
foreach dir_target ($list_target)
    # if path name ends with '/', then remove trailing '/'
    if ($dir_target:t == "") then
	set dir_target = "$dir_target:h"
    endif

    # if target directory is not pkgsrc directory, then skip to next
    if ($dir_target:t != "pkgsrc") then
	echo "# target directory '$dir_target' is not pkgsrc directory!"
	echo "# skipping '$dir_target' and moving to next!"
	# skipping to next
	continue
    endif

    # if target directory does not exist, then skip to next
    if (! -d $dir_target) then
	# printing message
	echo "# target directory '$dir_target' does not exist!"
	echo "# skipping '$dir_target' and moving to next!"
	# skipping to next
	continue
    endif

    # printing status
    echo "# now, moving to target directory '$dir_target'..."
    
    # change to target directory
    cd $dir_target

    # printing status
    echo "# finished moving to target directory '$dir_target'!"

    # printing status
    echo "# now, updating pkgsrc directory '$dir_target'..."
    echo "#  command to be executed = $cvs -q update -dP"

    # updating pkgsrc
    $cvs -q update -dP

    # printing status
    echo "# finished updating pkgsrc directory '$dir_target'!"
    echo "#  executed command = $cvs -q update -dP"
end
