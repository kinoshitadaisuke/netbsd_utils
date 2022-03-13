#!/bin/csh

#
# Time-stamp: <2022/03/13 17:55:00 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to fetch src and xsrc
#
#  author: Kinoshita Daisuke
#
#  version 1: 13/Mar/2022
#

#
# options
#  -r : revision (e.g. current, netbsd-8, netbsd-9)
#  -s : CVS_ROOT (e.g. :pserver:anoncvs@anoncvs.NetBSD.org:/cvsroot)
#
# examples:
#  downloding src-current to /usr/src and xsrc-current to /usr/xsrc
#    % netbsd_src_fetch.csh /usr
#  downloding netbsd-9 src to /usr/src and xsrc to /usr/xsrc
#    % netbsd_src_fetch.csh -r netbsd-9 /usr
#  downloding netbsd-8 src to /work/netbsd/src and xsrc to /work/netbsd/xsrc
#    % netbsd_src_fetch.csh -r netbsd-8 /work/netbsd
#

# default parameters
set cvs_revision = current
#set cvs_server   = :pserver:anoncvs@anoncvs.NetBSD.org:/cvsroot
set cvs_server   = :pserver:anoncvs@anoncvs.fr.NetBSD.org:/pub/NetBSD-CVS

# locations of commands
set mkdir = /bin/mkdir
set rm    = /bin/rm
set cvs   = /usr/bin/cvs

# directories and files
set dir_tmp    = /tmp
set file_usage = ${dir_tmp}/netbsd_src_fetch.$$

# usage message
cat <<EOF > $file_usage
netbsd_src_fetch.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -r : revision (e.g. current, netbsd-8, netbsd-9)
  -s : CVS_ROOT (e.g. :pserver:anoncvs@anoncvs.NetBSD.org:/cvsroot)

 Examples:
  downloding src-current to /usr/src and xsrc-current to /usr/xsrc
    % netbsd_src_fetch.csh /usr

  downloding netbsd-9 src to /usr/src and xsrc to /usr/xsrc
    % netbsd_src_fetch.csh -r netbsd-9 /usr

  downloding netbsd-8 src to /work/netbsd/src and xsrc to /work/netbsd/xsrc
    % netbsd_src_fetch.csh -r netbsd-8 /work/netbsd

  downloding src-current to /usr/src and /usr/xsrc from specified mirror
    % netbsd_src_fetch.csh -s :pserver:anoncvs@anoncvs.NetBSD.org:/cvsroot

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
	    breaksw
	# -s option
	case "-s":
	    # CVS server
	    set cvs_server = $argv[2]
	    shift
	    breaksw
     endsw
     set dir_target = $argv[1]
     shift
end

# make directory if "dir_target" does not exist
if (! -d $dir_target) then
    # printing status
    echo "# now, making target directory '$dir_target'..."
    # executing mkdir command
    mkdir -p $dir_target
    # printing status
    echo "# finished making target directory '$dir_target'!"
endif

# printing status
echo "# now, moving to target directory '$dir_target'..."
# change to directory "dir_target"
cd $dir_target
# printing status
echo "# finished moving to target directory '$dir_target'!"

# fetching pkgsrc using cvs command
if ($cvs_revision == "current") then
    # printing status
    echo "# now, fetching src-current..."
    echo "#  command = $cvs -d $cvs_server -q checkout -P src"
    # fetching src-current
    $cvs -d $cvs_server -q checkout -P src
    # printing status
    echo "# finished fetching src-current!"

    # printing status
    echo "# now, fetching xsrc-current..."
    echo "#  command = $cvs -d $cvs_server -q checkout -P xsrc"
    # fetching xsrc-current
    $cvs -d $cvs_server -q checkout -P xsrc
    # printing status
    echo "# finished fetching xsrc-current!"
else
    # printing status
    echo "# now, fetching src of ${cvs_revision}..."
    echo "#  command = $cvs -d $cvs_server -q checkout -r $cvs_revision -P src"
    # fetching src of specified revision
    $cvs -d $cvs_server -q checkout -r $cvs_revision -P src
    # printing status
    echo "# finished fetching src of ${cvs_revision}!"

    # printing status
    echo "# now, fetching xsrc of ${cvs_revision}..."
    echo "#  command = $cvs -d $cvs_server -q checkout -r $cvs_revision -P xsrc"
    # fetching xsrc of specified revision
    $cvs -d $cvs_server -q checkout -r $cvs_revision -P xsrc
    # printing status
    echo "# finished fetching xsrc of ${cvs_revision}!"
endif

# printing status
echo "# now, deleting usage file '$file_usage'..."
# deleting usage file
$rm -f $file_usage
# printing status
echo "# finished deleting usage file '$file_usage'!"
