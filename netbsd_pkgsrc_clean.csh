#!/bin/csh

#
# Time-stamp: <2022/03/19 11:47:26 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to clean work directories of pkgsrc
#
#  author: Kinoshita Daisuke
#
#  version 1.0: 12/Mar/2022
#  version 1.1: 13/Mar/2022
#

#
# usage:
#
#   % netbsd_pkgsrc_clean.csh
#

# command
set hostname = /bin/hostname
set rm       = /bin/rm
set make     = /usr/bin/make
set uname    = /usr/bin/uname

set arch = `${uname} -m`
set host = `${hostname} -s`

# directories and files
set dir_tmp            = /tmp
set file_usage         = ${dir_tmp}/netbsd_pkgsrc_clean.$$
set dir_pkgsrc_default = /usr/pkgsrc
set list_dir_pkgsrc    = ( )

# usage message
cat <<EOF > $file_usage
netbsd_pkgsrc_clean.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -h : print usage

 Examples:

  cleaning pkgsrc work directories under /usr/pkgsrc
    % netbsd_pkgsrc_clean.csh

  printing help
    % netbsd_pkgsrc_clean.csh -h

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
	    set list_dir_pkgsrc = ($list_dir_pkgsrc $argv[1])
     endsw
     shift
end

# if no directory is given, then use default value "/usr/pkgsrc"
if ($#list_dir_pkgsrc == 0) then
    set list_dir_pkgsrc = ( $dir_pkgsrc_default )
endif

# printing status
echo "#"
echo "# list of pkgsrc directories to be cleaned"
echo "#"
foreach dir_pkgsrc ($list_dir_pkgsrc)
    echo "#   $dir_pkgsrc"
end
echo "#"

# making an empty list for cleaned packages
set list_packages = ( )

# printing status
echo "#"
echo "# now, counting number of work directories to be cleaned..."
echo "#"

# finding work directories and counting number of work directories
foreach dir_pkgsrc ($list_dir_pkgsrc)
    foreach dir_package (${dir_pkgsrc}/*/*)
	if (-d ${dir_package}/work) then
	    set dir_work      = ${dir_package}/work
	    set list_packages = ( ${list_packages} ${dir_work} )
	endif
	if (-d ${dir_package}/work.$arch) then
	    set dir_work      = ${dir_package}/work.$arch
	    set list_packages = ( ${list_packages} ${dir_work} )
	endif
	if (-d ${dir_package}/work.$host) then
	    set dir_work      = ${dir_package}/work.$host
	    set list_packages = ( ${list_packages} ${dir_work} )
	endif
    end
end

# printing status
echo "# finished counting number of work directories to be cleaned!"
echo "#   there are $#list_packages work directories to be cleaned"
echo "#"

if ($#list_packages == 0) then
    echo "#"
    echo "# no work directory is found!"
    echo "# no need of cleaning, and stopping the script."
    echo "#"
endif

# printing status
echo "# now, cleaning pkgsrc work directories..."
echo "#"

# for each work directory under pkgsrc
foreach dir_work ($list_packages)
    # package directory (e.g. /usr/pkgsrc/*/*)
    set dir_package = $dir_work:h
    # moving to package directory
    cd ${dir_package}
    # cleaning directory
    ${make} clean
end

# printing status
echo "#"
echo "# finished cleaning pkgsrc work directories!"
echo "#"

# printing list of deleted packages
echo "# list of cleaned work directories"
echo "#"
foreach dir (${list_packages})
    echo "#   ${dir}"
end
echo "#"
