#!/bin/csh

#
# Time-stamp: <2022/03/12 19:22:08 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to clean work directories of pkgsrc
#
#  author: Kinoshita Daisuke
#
#  version 1: 12/Mar/2022
#

#
# usage:
#
#   % netbsd_pkgsrc_clean.csh
#

# command
set make = /usr/bin/make

# making an empty list for cleaned packages
set list_packages = ( )

# printing status
echo "#"
echo "# now, cleaning pkgsrc work directories..."
echo "#"

# for each work directory under pkgsrc
foreach dir_work (/usr/pkgsrc/*/*/work*)
    # appending package directory name to the list
    set list_packages = ( ${list_packages} ${dir_work} )
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
echo "#"
echo "# list of cleaned work directories"
echo "#"
foreach dir (${list_packages})
    echo "#   ${dir}"
end
echo "#"
