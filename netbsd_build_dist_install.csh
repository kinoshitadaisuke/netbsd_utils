#!/bin/csh

#
# Time-stamp: <2022/03/16 10:55:03 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to install distribution
#
#  author: Kinoshita Daisuke
#
#  version 1: 13/Mar/2022
#

#
# options:
#
#  -h : print help message
#  -d : base directory (default: /usr)
#  -j : number of CPU cores to be used (default: 1)
#
# examples:
#
#   installing distribution
#     % netbsd_build_dist_install.csh
#
#   installing distribution using 8 CPU cores
#     % netbsd_build_dist_install.csh -j 8
#

# locations of commands
set ls    = /bin/ls
set mkdir = /bin/mkdir
set mv    = /bin/mv
set rm    = /bin/rm
set sed   = /usr/bin/sed

# initial value
set ncore    = 1
set list_cfg = ()

# directories and files
set dir_base   = /usr
set dir_tmp    = /tmp
set file_usage = ${dir_tmp}/netbsd_build_kernel_make.$$

# usage message
cat <<EOF > $file_usage
netbsd_build_dist_install.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -h : printing help message
  -d : base directory (default: /usr)
  -j : number of CPU cores to be used for building

 Examples:
   installing distribution
     % netbsd_build_dist_install.csh

   installing distribution using 8 CPU cores
     % netbsd_build_dist_install.csh -j 8

EOF

# number of command-line arguments must be 0 or 2 or 4 or greater
if ( ($#argv != 0) && ($#argv != 2) && ($#argv != 4) ) then
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
        # -d option
        case "-d":
            # base directory
            set dir_base = $argv[2]
            shift
            breaksw
        # -j option
        case "-j":
            # number of CPU cores to be used
            set ncore = $argv[2]
            shift
            breaksw
     endsw
     shift
end

# directories
set dir_obj    = "${dir_base}/obj"
set dir_objold = "${dir_base}/obj.old"
set dir_src    = "${dir_base}/src"

# if dir_src does not exist, then stop the script
if (! -d $dir_src) then
    # printing message
    echo "# directory '$dir_src' does not exist!"
    echo "# stopping the script!"
    # stopping the script
    exit
endif

# printing message
echo "# now, changing to directory '$dir_src'..."
# moving to directory dir_src
cd $dir_src
# printing message
echo "# finished changing to directory '$dir_src'!"

echo "# now, installing distribution..."
echo "#   ${dir_src}/build.sh -U -j $ncore install=/"
# building kernel modules
${dir_src}/build.sh -U -j $ncore -x -U install=/
# printing message
echo "# finished installing distribution!"
