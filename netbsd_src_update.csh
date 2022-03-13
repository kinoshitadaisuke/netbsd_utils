#!/bin/csh

#
# Time-stamp: <2022/03/13 17:56:33 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to update src and xsrc
#
#  author: Kinoshita Daisuke
#
#  version 1: 13/Mar/2022
#

#
# examples:
#
#  updating /usr/src and /usr/xsrc
#    % netbsd_src_update.csh /usr/src /usr/xsrc
#

# locations of commands
set rm  = /bin/rm
set cvs = /usr/bin/cvs

# initial value
set list_target = ()

# directories and files
set dir_tmp    = /tmp
set file_usage = ${dir_tmp}/netbsd_pkgsrc_fetch.$$

# usage message
cat <<EOF > $file_usage
netbsd_src_update.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -h : printing help message

 Examples:
  updating /usr/src and /usr/xsrc
    % netbsd_src_update.csh /usr/src /usr/xsrc
  updating /work/netbsd/src and /work/netbsd/xsrc
    % netbsd_src_update.csh /work/netbsd/src /work/netbsd/xsrc

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
     endsw
     set list_target = ($list_target $argv[1])
     shift
end

# processing for each target directories
foreach dir_target ($list_target)
    # if path name ends with '/', then remove trailing '/'
    if ($dir_target:t == "") then
	set dir_target = "$dir_target:h"
    endif

    # if target directory is not src or xsrc directory, then skip to next
    if ( ($dir_target:t != "src") && ($dir_target:t != "xsrc") ) then
	echo "# target directory '$dir_target' is not src or xsrc directory!"
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
    echo "# now, updating src directory '$dir_target'..."
    echo "#  command to be executed = $cvs -q update -dP"

    # updating src
    $cvs -q update -dP

    # printing status
    echo "# finished updating src directory '$dir_target'!"
    echo "#  executed command = $cvs -q update -dP"
end
