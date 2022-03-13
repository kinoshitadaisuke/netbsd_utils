#!/bin/csh

#
# Time-stamp: <2022/03/13 17:40:53 (CST) daisuke>
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
set rm   = /bin/rm
set make = /usr/bin/make

# directories and files
set dir_tmp    = /tmp
set file_usage = ${dir_tmp}/netbsd_pkgsrc_clean.$$

# usage message
cat <<EOF > $file_usage
netbsd_pkgsrc_clean.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -h : print usage

 Examples:

  cleaning pkgsrc work directories
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
     endsw
     shift
end

# making an empty list for cleaned packages
set list_packages = ( )

# printing status
echo "#"
echo "# now, counting number of work directories to be cleaned..."
echo "#"

# finding work directories and counting number of work directories
foreach dir_work (/usr/pkgsrc/*/*/work*)
    # appending package directory name to the list
    set list_packages = ( ${list_packages} ${dir_work} )
end

# printing status
echo "# finished counting number of work directories to be cleaned!"
echo "#   there are $#list_packages work directories to be cleaned"
echo "#"

# printing status
echo "# now, cleaning pkgsrc work directories..."
echo "#"

# for each work directory under pkgsrc
foreach dir_work ($list_packages)
    # package directory (/usr/pkgsrc/*/*)
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
