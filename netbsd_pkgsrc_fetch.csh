#!/bin/csh

#
# Time-stamp: <2022/03/13 17:51:00 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to fetch pkgsrc
#
#  author: Kinoshita Daisuke
#
#  version 1: 13/Mar/2022
#

#
# options
#  -r : revision (e.g. current, pkgsrc-2021Q4, pkgsrc-2022Q1)
#  -s : CVS_ROOT (e.g. :pserver:anoncvs@anoncvs.NetBSD.org:/cvsroot)
#
# examples:
#  downloding pkgsrc-current to /usr/pkgsrc
#    % netbsd_pkgsrc_fetch.csh /usr
#  downloding pkgsrc-2021Q4 to /usr/pkgsrc
#    % netbsd_pkgsrc_fetch.csh -r pkgsrc-2021Q4 /usr
#

# default parameters
set cvs_revision = current
set cvs_server   = :pserver:anoncvs@anoncvs.NetBSD.org:/cvsroot

# locations of commands
set mkdir = /bin/mkdir
set rm    = /bin/rm
set cvs   = /usr/bin/cvs

# directories and files
set dir_tmp    = /tmp
set file_usage = ${dir_tmp}/netbsd_pkgsrc_fetch.$$

# usage message
cat <<EOF > $file_usage
netbsd_pkgsrc_fetch.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -r : revision (e.g. current, pkgsrc-2021Q4, pkgsrc-2022Q1)
  -s : CVS_ROOT (e.g. :pserver:anoncvs@anoncvs.NetBSD.org:/cvsroot)

 Examples:
  downloding pkgsrc-current to /usr/pkgsrc
    % netbsd_pkgsrc_fetch.csh /usr

  downloding pkgsrc-current to /usr/pkgsrc
    % netbsd_pkgsrc_fetch.csh -r current /usr

  downloding pkgsrc-2021Q4 to /usr/pkgsrc
    % netbsd_pkgsrc_fetch.csh -r pkgsrc-2021Q4 /usr

  downloding pkgsrc-2022Q1 to /work/netbsd/pkgsrc
    % netbsd_pkgsrc_fetch.csh -r pkgsrc-2022Q1 /work/netbsd

  downloding pkgsrc-current to /usr/pkgsrc from specified mirror
    % netbsd_pkgsrc_fetch.csh -s :pserver:anoncvs@anoncvs.NetBSD.org:/cvsroot

EOF

# number of command-line arguments must be 1 or 3 or 5
if ( ($#argv != 1) && ($#argv != 3) && ($#argv != 5) ) then
    # printing message
    echo "#"
    echo "# number of command-line arguments must be 1 or 3 or 5!"
    echo "#"
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
	# -r option
	case "-r":
	    # CVS revision
	    set cvs_revision = $argv[2]
	    shift
	    shift
	    breaksw
	# -s option
	case "-s":
	    # CVS server
	    set cvs_server = $argv[2]
	    shift
	    shift
	    breaksw
     endsw
     set dir_target = $argv[1]
     shift
end

# make directory if "dir_target" does not exist
if (! -d $dir_target) then
    # printing status
    echo "#"
    echo "# now, making target directory '$dir_target'..."
    echo "#"
    # executing mkdir command
    mkdir -p $dir_target
    # printing status
    echo "# finished making target directory '$dir_target'!"
    echo "#"
endif

# printing status
echo "# now, moving to target directory '$dir_target'..."
echo "#"
# change to directory "dir_target"
cd $dir_target
# printing status
echo "# finished moving to target directory '$dir_target'!"
echo "#"

# fetching pkgsrc using cvs command
if ($cvs_revision == "current") then
    # printing status
    echo "# now, fetching pkgsrc-current..."
    echo "#  command = $cvs -d $cvs_server -q checkout -P pkgsrc"
    # fetching pkgsrc-current
    $cvs -d $cvs_server -q checkout -P pkgsrc
    # printing status
    echo "# finished fetching pkgsrc-current!"
    echo "#"
else
    # printing status
    echo "# now, fetching pkgsrc..."
    echo "#  command = $cvs -d $cvs_server -q checkout -r $cvs_revision -P pkgsrc"
    # fetching specified revision of pkgsrc
    $cvs -d $cvs_server -q checkout -r $cvs_revision -P pkgsrc
    # printing status
    echo "# finished fetching pkgsrc!"
    echo "#"
endif

# printing status
echo "# now, deleting usage file '$file_usage'..."
echo "#"
# deleting usage file
$rm -f $file_usage
# printing status
echo "# finished deleting usage file '$file_usage'!"
echo "#"
