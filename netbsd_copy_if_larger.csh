#!/bin/csh

#
# Time-stamp: <2022/03/19 21:02:43 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to copy file if larger in size
#
#  author: Kinoshita Daisuke
#
#  version 1.0: 19/Mar/2022
#

#
# usage:
#
#   % netbsd_copy_if_larger.csh /some/where/in/the/disk/*
#

# commands
set cat  = /bin/cat
set cp   = /bin/cp
set pwd  = /bin/pwd
set rm   = /bin/rm
set stat = /usr/bin/stat

# files and directories
set dir_tmp    = /tmp
set file_usage = ${dir_tmp}/netbsd_copy_if_larger.$$

# initial values of parameters
set verbosity    = 0
set list_files   = ( )
set list_copied  = ( )

# usage message
$cat <<EOF > $file_usage
netbsd_copy_if_larger.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -h : print usage

 Examples:

  copying files /some/where/in/the/disk/* to currently working directory
  if source files are larger than destination files in size
    % netbsd_copy_if_larger.csh /some/where/in/the/disk/*

  printing help
    % netbsd_copy_if_larger.csh -h

EOF

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
	case "-v":
	    set verbosity = 1
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
            set list_files = ($list_files $argv[1])
     endsw
     shift
end

# currently working directory
set dir_cwd = `$pwd`

# processing each file one-by-one
foreach path_src ($list_files)
    # file name
    set filename = $path_src:t
    # path name of destination file
    set path_dst = ${dir_cwd}/$filename

    # file size of src
    if ( (-e $path_src) && (-f $path_src) ) then
	set size_src = `$stat -f %z $path_src`
    else
	set dize_src = 0
    endif
    # file size of dst
    if ( (-e $path_dst) && (-f $path_dst) ) then
	set size_dst = `$stat -f %z $path_dst`
    else
	set size_dst = 0
    endif

    echo "# ${filename}:"
    
    if ($verbosity) then
	echo "#   src file = $path_src"
	echo "#   dst file = $path_dst"
	echo "#   size of src file : $size_src byte"
	echo "#   size of dst file : $size_dst byte"
    endif

    if ( (-e $path_dst) && ($size_dst >= $size_src) ) then
	echo "#   $path_src is not copied!"
    else
	echo "#   $path_src is being copied..."
	echo "#     $path_src ==> $path_dst"
	$cp -pf $path_src $path_dst
	set list_copied = ( $list_copied $filename )
    endif
end

echo "#"
echo "# summary:"
echo "#"
echo "#  number of copied files = $#list_copied"
echo "#"
echo "#  list of copied files"
foreach filename ($list_copied)
    echo "#    $filename"
end
echo "#"
