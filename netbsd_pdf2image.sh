#!/bin/sh

#
# Time-stamp: <2022/04/22 22:19:20 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to convert a PDF file into multiple image files
#
#  author: Kinoshita Daisuke
#
#  version 1.0: 22/Apr/2022
#

#
# usage:
#
#   % netbsd_pdf2image.sh foo.pdf
#

# commands
expr="/bin/expr"
stat="/usr/bin/stat"
gs="/usr/pkg/bin/gs"
list_commands="$expr $stat $gs"

# existence check of commands
for command in $list_commands
do
    if [ ! -e $command ]
    then
        echo "ERROR: command '$command' does not exist!"
        echo "ERROR: install command '$command'!"
        exit 1
    fi
done

# options for commands
opt_gs="-dBATCH -dNOPAUSE -q"

# available image formats
list_image_format="bmp jpg png ppm tiff"

# initial values of parameters
image_format="png"
resolution="600"
list_files=""
verbosity=0

# usage message
print_usage () {
    echo "netbsd_pdf2image.sh"
    echo ""
    echo " Author: Kinoshita Daisuke (c) 2022"
    echo ""
    echo " Usage:"
    echo "  -f : output image file format (default: png)"
    echo "       available image format: bmp jpg png ppm tiff"
    echo "  -h : print usage"
    echo "  -r : resolution in DPI (default: 600)"
    echo "  -v : verbose mode (default: 0)"
    echo ""
    echo " Examples:"
    echo "  converting PDF file into PNG files"
    echo "   % netbsd_pdf2image.sh foo.pdf"
    echo "  converting PDF file into JPEG files of 300 DPI"
    echo "   % netbsd_pdf2image.sh -f jpg -r 300 foo.pdf"
    echo "  printing help"
    echo "   % netbsd_pdf2image.sh -h"
    echo ""
}

# command-line argument analysis
while getopts "f:hr:v" args
do
    case "$args" in
	f)
	    image_format=$OPTARG
	    ;;
	h)
	    print_usage
	    exit 1
	    ;;
	r)
	    resolution=$OPTARG
	    ;;
	v)
	    verbosity=`$expr $verbosity + 1`
	    ;;
	\?)
	    print_usage
	    exit 1
    esac
done
shift $((OPTIND - 1))

# check of output image format
compatibility=0
for format in $list_image_format
do
    if [ $image_format = $format ]
    then
	compatibility=`$expr $compatibility + 1`
    fi
done

# if specified image format is not available, then stop the script
if [ $compatibility -lt 1 ]
then
    echo "ERROR: invalid image format!"
    echo "ERROR: specified image format '$image_format' is not available!"
    echo "ERROR: exiting..."
    exit 1
fi

# if no PDF file is given, then stop the script
if [ "$*" = "" ]
then
    echo "ERROR: no PDF file is given!"
    echo "ERROR: exiting..."
    exit 1
fi

# processing each PDF file
for file_pdf in $*
do
    # file name without extension
    basename=${file_pdf%%.*}

    # gs option for resolution
    opt_res="-r$resolution"

    # gs option for device
    if [ $image_format = "bmp" ]
    then
        opt_dev="-sDEVICE=bmp256"
    elif [ $image_format = "jpg" ]
    then
        opt_dev="-sDEVICE=jpeg"
    elif [ $image_format = "png" ]
    then
        opt_dev="-sDEVICE=png256"
    elif [ $image_format = "ppm" ]
    then
        opt_dev="-sDEVICE=ppm"
    elif [ $image_format = "tiff" ]
    then
        opt_dev="-sDEVICE=tiff24nc"
    else
        opt_dev="-sDEVICE=png256"
    fi

    # gs option for output file
    opt_output="-sOutputFile=${basename}_%04d.$image_format"

    # command for conversion
    command_gs="$gs $opt_gs $opt_res $opt_dev $opt_output $file_pdf"

    # printing input parameters
    if [ $verbosity -gt 0 ]
    then
        echo "#"
        echo "# Input parameters"
        echo "#"
        echo "#  PDF file                = $file_pdf"
        echo "#  output image format     = $image_format"
        echo "#  output image resolution = $resolution"
        echo "#"
        echo "# Command for conversion from PDF to images"
        echo "#"
        echo "#  $command_gs"
        echo "#"
    fi

    # printing status
    if [ $verbosity -gt 0 ]
    then
        echo "# now, converting PDF file into multiple images..."
    fi
    
    # executing command
    $command_gs

    # printing status
    if [ $verbosity -gt 0 ]
    then
        echo "# finished converting PDF file into multiple images!"
    fi

    # showing summary
    if [ $verbosity -gt 0 ]
    then
        echo "#"
        echo "# Summary"
        echo "#"
        echo "#  Command used for conversion from PDF into images"
        echo "#   $command_gs"
        echo "#"
        echo "#  List of files created:"
        for file_image in ${basename}_*.$image_format
	do
            # file size in kilo-byte
	    size_kb=`$stat -f %Lz $file_image`
            printf "#   %48s %5d KB\n" $file_image $size_kb
	done
        echo "#"
    fi
done
