#!/bin/sh

#
# Time-stamp: <2022/04/24 09:56:59 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to convert multiple image files into a single PDF file
#
#  author: Kinoshita Daisuke
#
#  version 1.0: 22/Apr/2022
#  version 1.1: 24/Apr/2022
#

#
# usage:
#
#   % netbsd_image2pdf.sh -o foo.pdf foo*.png
#

# environmental variables
export MAGICK_TEMPORARY_PATH=.
export MAGICK_AREA_LIMIT=1.0GP
export MAGICK_DISK_LIMIT=8192MiB
export MAGICK_FILE_LIMIT=1024
export MAGICK_MEMORY_LIMIT=512MiB
export MAGICK_MAP_LIMIT=512MiB
export MAGICK_THREAD_LIMIT=8

# commands
expr="/bin/expr"
mkdir="/bin/mkdir"
rm="/bin/rm"
stat="/usr/bin/stat"
convert="/usr/pkg/bin/convert"
gs="/usr/pkg/bin/gs"
list_commands="$expr $mkdir $rm $stat $convert $gs"

# existence check of commands
for command in $list_commands
do
    if [ ! -e $command ]
    then
	# printing message
        echo "ERROR: command '$command' does not exist!"
        echo "ERROR: install command '$command'!"
	# exit
        exit 1
    fi
done

# files and directories
dir_tmp="/tmp/i2p_$$"
file_output=""

# available image formats
list_image_format="bmp gif jpg jpeg png ppm tiff tif"

# available paper sizes
list_paper_size_a="a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10"
list_paper_size_b="b0 b1 b2 b3 b4 b5"
list_paper_size_others="hagaki legal letter"
list_paper_size="$list_paper_size_a $list_paper_size_b $list_paper_size_others"

# initial values of parameters
list_files_image=""
list_files_pdf=""
paper_size="a4"
verbosity=0

# check of existence of temporary directory
if [ ! -d $dir_tmp ]
then
    $mkdir $dir_tmp
fi

# usage message
print_usage () {
    # printing message
    echo "netbsd_image2pdf.sh"
    echo ""
    echo " Author: Kinoshita Daisuke (c) 2022"
    echo ""
    echo " Usage:"
    echo "  -h : print usage"
    echo "  -o : output PDF file name"
    echo "  -p : paper size (default: a4)"
    echo "  -v : verbose mode (default: 0)"
    echo ""
    echo " Examples:"
    echo "  converting PNG files into a single PDF file"
    echo "   % netbsd_image2pdf.sh -o foo.pdf foo*.png"
    echo "  converting JPEG files into a single PDF file of A3 paper size"
    echo "   % netbsd_image2pdf.sh -p a3 -o bar.pdf bar*.png"
    echo "  printing help"
    echo "   % netbsd_image2pdf.sh -h"
    echo ""
}

# command-line argument analysis
while getopts "ho:p:v" args
do
    case "$args" in
	h)
	    # printing usage
	    print_usage
	    # exit
	    exit 1
	    ;;
	o)
	    # output file name
	    file_output=$OPTARG
	    ;;
	p)
	    # paper size
	    paper_size=$OPTARG
	    ;;
	v)
	    # verbosity level
	    verbosity=`$expr $verbosity + 1`
	    ;;
	\?)
	    # printing usage
	    print_usage
	    # exit
	    exit 1
    esac
done
shift $((OPTIND - 1))

# check of number of image files
n_files=0
for file_image in $*
do
    n_files=`$expr $n_files + 1`
done
if [ $n_files -lt 1 ]
then
    # printing message
    echo "ERROR: no image file is given!"
    echo "ERROR: specify image files for conversion!"
    # exit
    exit 1
fi

# check of paper size
compatibility=0
for size in $list_paper_size
do
    if [ $size = $paper_size ]
    then
	compatibility=`$expr $compatibility + 1`
    fi
done
if [ $compatibility -lt 1 ]
then
    # printing message
    echo "ERROR: unsupported paper size!"
    echo "ERROR: paper size '$paper_size' is not supported."
    # exit
    exit 1
fi

# check of format of specified image files
for file_each in $*
do
    extension=${file_each##*.}
    compatibility=0
    for format in $list_image_format
    do
	if [ $extension = $format ]
	then
            compatibility=`$expr $compatibility + 1`
	fi
    done
    if [ $compatibility -lt 1 ]
    then
	# printing message
	echo "ERROR: file '$file_each' cannot be processed!"
	echo "ERROR: image format '$extension' is not supported!"
	# exit
	exit 1
    fi
done

# check of format of output file
if [ ${file_output##*.} != 'pdf' ]
then
    # printing message
    echo "ERROR: output file format must be PDF!"
    echo "ERROR: specified output file name = '$file_output'."
    echo "ERROR: extension of output file must be '.pdf'."
    # exit
    exit 1
fi

# options for ghostscript
opt_gs="-dNOPAUSE -dBATCH -q -sDEVICE=pdfwrite"
opt_c="-sColorConversionStrategy=UseDeviceIndependentColor"
opt_p="-sPAPERSIZE=$paper_size"
opt_output="-sOutputFile=$file_output"

# converting image files into PDF files
for path_each_image in $*
do
    file_each_image=${path_each_image##*/}
    file_each_image_base=${file_each_image%%.*}
    file_each_pdf="${dir_tmp}/${file_each_image_base}.pdf"
    list_files_pdf="$list_files_pdf $file_each_pdf"
    if [ $verbosity -gt 0 ]
    then
	# printing message
        echo "#"
        echo "# now, converting image '$file_each_image' to PDF..."
        echo "#  $file_each_image ==> $file_each_pdf"
    fi
    command_makepdf="$convert $path_each_image $file_each_pdf"
    $command_makepdf
    if [ $verbosity -gt 0 ]
    then
	# printing message
        echo "# finished converting image to PDF!"
        echo "#  file '$file_each_pdf' is successfully created! "
    fi
done

# combining multiple PDF files into a single PDF file
command_combinepdf="$gs $opt_gs $opt_c $opt_p $opt_output $list_files_pdf"
if [ $verbosity -gt 0 ]
then
    # printing message
    echo "#"
    echo "# now, combining multiple PDF files into single PDF file..."
    echo "# $command_combinepdf"
fi
$command_combinepdf
if [ $verbosity -gt 0 ]
then
    # printing message
    echo "# finished combining multiple PDF files into single PDF file!"
    echo "# successfully produced file '$file_output'!"
    echo "#"
fi

# removing temporary files
for file_each_pdf in $list_files_pdf
do
    command_removepdf="$rm $file_each_pdf"
    if [ $verbosity -gt 0 ]
    then
	# printing message
        echo "# now, removing file '$file_each_pdf'..."
        echo "# $command_removepdf"
    fi
    $command_removepdf
    if [ $verbosity -gt 0 ]
    then
	# printing message
	echo "# finished removing file '$file_each_pdf'!"
	echo "#"
    fi
done

# printing summary information
if [ $verbosity -gt 0 ]
then
    # printing message
    echo "#"
    echo "# Summary"
    echo "#"
    echo "#  list of input images"
    echo "#"
    for file_each_image in $list_files_image
    do
	size_each_image=`$stat -f %Lz $file_each_image`
	# printing message
        echo "#   $file_each_image ($size_each_image KB)"
    done
    # size of PDF file
    size_mb_combinedpdf=`$stat -f %Mz $file_output`
    size_kb_combinedpdf=`$stat -f %Lz $file_output`
    # printing message
    echo "#"
    echo "#  output PDF file"
    echo "#"
    if [ $size_mb_combinedpdf -lt 10 ]
    then
	# printing message
        echo "#   $file_output ($size_kb_combinedpdf KB)"
    else
	# printing message
        echo "#   $file_output ($size_mb_combinedpdf MB)"
    fi
    echo "#"
fi
