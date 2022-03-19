#!/bin/csh

#
# Time-stamp: <2022/03/19 11:57:18 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to install custom kernel
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
#
# examples:
#
#   installing kernel to /netbsd.XXXXXXXXX.GENERIC
#     % netbsd_build_kernel_install.csh /usr/src/src/sys/arch/amd64/conf/GENERIC
#
#   installing kernel to /netbsd.XXXXXXXXX.ABC_GEN_YYYYMMDD and /netbsd
#     % netbsd_build_kernel_install.csh /usr/src/src/sys/arch/amd64/conf/ABC_GEN_YYYYMMDD
#
#   installing kernel to /netbsd.XXXXXXXXX.ABC_XEN_YYYYMMDD and /netbsd_xen
#     % netbsd_build_kernel_install.csh /usr/src/src/sys/arch/amd64/conf/ABC_XEN_YYYYMMDD
#

# locations of commands
set cp    = /bin/cp
set ls    = /bin/ls
set mkdir = /bin/mkdir
set mv    = /bin/mv
set rm    = /bin/rm
set egrep = /usr/bin/egrep
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
netbsd_build_kernel_install.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -h : printing help message
  -d : base directory (default: /usr)

 Examples:
   installing kernel to /netbsd.XXXXXXXXX.GENERIC
     % netbsd_build_kernel_install.csh /usr/src/src/sys/arch/amd64/conf/GENERIC

   installing kernel to /netbsd.XXXXXXXXX.ABC_GEN_YYYYMMDD and /netbsd
     % netbsd_build_kernel_install.csh /usr/src/src/sys/arch/amd64/conf/ABC_GEN_YYYYMMDD

   installing kernel to /netbsd.XXXXXXXXX.ABC_XEN_YYYYMMDD and /netbsd_xen
     % netbsd_build_kernel_install.csh /usr/src/src/sys/arch/amd64/conf/ABC_XEN_YYYYMMDD

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
        # -d option
        case "-d":
            # base directory
            set dir_base = $argv[2]
	    shift
            breaksw
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
	    set list_cfg = ($list_cfg $argv[1])
     endsw
     shift
end

# files and directories
set dir_obj    = "${dir_base}/obj"
set dir_objold = "${dir_base}/obj.old"
set dir_src    = "${dir_base}/src"
set file_param = "${dir_src}/sys/sys/param.h"

# if dir_src does not exist, then stop the script
if (! -d $dir_src) then
    # printing message
    echo "# directory '$dir_src' does not exist!"
    echo "# stopping the script!"
    # stopping the script
    exit
endif

# existence check of param.h
if (! -f $file_param) then
    # printing message
    echo "# file '$file_param' does not exist!"
    echo "# something is wrong!"
    # exit
    exit
endif

# acquiring kernel version number
set line_version = `$egrep '^#define' $file_param | $egrep '__NetBSD_Version__'`
set version      = `echo $line_version | awk '{print $3}'`

echo "#"
echo "# param.h file = $file_param"
echo "#   kernel version = $version"
echo "#"

# printing message
echo "# list of kernel configuration files:"
echo "#"
foreach path_cfg ($list_cfg)
    echo "#   $path_cfg"
end
echo "#"

# copying kernel(s) to root directory
echo "# copying kernel to root directory:"
echo "#"
foreach path_cfg ($list_cfg)
    # kernel directory
    set dir_kernel = `echo $path_cfg | $sed s%conf%compile/obj%`
    # kernel file (src)
    set path_kernel_src = "${dir_kernel}/netbsd"
    # kernel file (dst)
    set path_kernel_dst = "/netbsd.${version}.${path_cfg:t}"
    # if kernel does not exist, then skip to next
    if (! -f $path_kernel_src) then
	# printing message
	echo "# kernel file '$path_kernel_src' does not exist!"
	echo "# compile kernel before installation!"
	# skipping to next
	continue
    endif
    # printing information
    echo "#  kernel file = $path_kernel_src"
    echo "#   src : $path_kernel_src"
    echo "#   dst : $path_kernel_dst"
    # copying and installing kernel
    $cp -pf $path_kernel_src $path_kernel_dst
    if (${path_cfg:t} =~ *_GEN_*) then
	# printing information
	echo "#  kernel file = $path_kernel_src"
	echo "#   src : $path_kernel_src"
	echo "#   dst : /netbsd"
	# copying and installing kernel
	$cp -pf $path_kernel_src /netbsd
    endif
    if (${path_cfg:t} =~ *_XEN_*) then
	# printing information
	echo "#  kernel file = $path_kernel_src"
	echo "#   src : $path_kernel_src"
	echo "#   dst : /netbsd_xen"
	# copying and installing kernel
	$cp -pf $path_kernel_src /netbsd_xen
    endif
end
echo "#"

