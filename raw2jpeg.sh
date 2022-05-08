#!/bin/sh

#
# Time-stamp: <2022/05/08 11:10:44 (CST) daisuke>
#

###########################################################################

#
# about this script
#
#  a shell script to convert raw image taken by digital camera into jpeg files
#
#  author : Kinoshita Daisuke
#
#  version 1.0 : 07/May/2022
#

###########################################################################

#
# parameters
#

# locations of standard commands
expr='/bin/expr'
mv='/bin/mv'
rm='/bin/rm'
awk='/usr/bin/awk'
file='/usr/bin/file'

# list of commands
list_command="$expr $mv $rm $awk $file"

# existence check of commands
for command in $list_command
do
    if ! [ -e $command ]
    then
	echo "ERROR:"
	echo "ERROR: command '$command' does not exist!"
	echo "ERROR:"
	exit 1
    fi
done

# locations of third-party commands
convert='/usr/pkg/bin/convert'
dcraw='/usr/pkg/bin/dcraw'

# default values of parameters
colourspace='1'
quality='3'
verbosity='0'
whitebalance='camera'
size_m=1536
size_s=1024
size_t=768

###########################################################################

#
# functions
#

# function to print usage information
print_usage () {
    echo "$0"
    echo ""
    echo "Converting raw image from digital camera into JPEG file using dcraw"
    echo ""
    echo " (c) Kinoshita Daisuke, 2022"
    echo ""
    echo "USAGE:"
    echo ""
    echo "  $0 [options] files"
    echo ""
    echo "OPTIONS:"
    echo ""
    echo "  -c : location of 'convert' command of ImageMagick"
    echo "  -d : location of 'dcraw' command"
    echo "  -q : choice of interpolation (default: ADH)"
    echo "        0 : bilinear interporation (high speed, low quality)"
    echo "        1 : VNG (Variable Number of Gradients) interpolation"
    echo "        2 : PPG (Patterned Pixel Grouping) interpolation"
    echo "        3 : AHD (Adaptive Homogeneity-Directed) interpolation"
    echo "  -m : length of longer side of medium jpeg image (default: 1536)"
    echo "  -s : length of longer side of small jpeg image (default: 1024)"
    echo "  -t : length of longer side of tiny jpeg image (default: 768)"
    echo "  -o : choice of colour space (default: sRGB)"
    echo "        0 : raw colour space of the camera"
    echo "        1 : sRGB"
    echo "        2 : Adobe RGB"
    echo "        3 : Wide Gamut RGB"
    echo "        4 : Kodak ProPhoto RGB"
    echo "        5 : XYZ"
    echo "  -v : verbose output (default: off)"
    echo "  -w : white balance (default: camera)"
    echo "        camera : white balance chosen by the camera"
    echo "        auto   : white balance calculated from the image"
    echo ""
}

# function to generate ppm and jpeg file names
generate_filenames () {
    # file name of raw image
    local file_raw=$1

    # stem
    local stem=${file_raw%%.*}

    # ppm file name
    file_ppm="${stem}.ppm"

    # temporary ppm file name
    file_tmp="t$$.ppm"
    
    # large jpeg file
    file_jpg_l="${stem}l.jpg"
    # medium jpeg file
    file_jpg_m="${stem}m.jpg"
    # small jpeg file
    file_jpg_s="${stem}s.jpg"
    # tiny jpeg file
    file_jpg_t="${stem}t.jpg"

    return 1
}

###########################################################################

#
# command-line argument analysis
#

# command-line argument analysis
while getopts "c:d:hq:m:o:s:t:vw:" args
do
    case "$args" in
	c)
	    # -c option: location of "convert" command
	    convert=$OPTARG
	    ;;
	d)
	    # -d option: location of "dcraw" command
	    dcraw=$OPTARG
	    ;;
        h)
	    # -h option: printing usage
            print_usage
            exit 1
            ;;
	q)
	    # -q option: choice of image quality
	    #  -q 0 ==> bilinear interporation (high speed, low quality)
	    #  -q 1 ==> VNG (Variable Number of Gradients) interpolation
	    #  -q 2 ==> PPG (Patterned Pixel Grouping) interpolation
	    #  -q 3 ==> AHD (Adaptive Homogeneity-Directed) interpolation
	    quality=$OPTARG
	    ;;
	m)
	    # length of longer side of medium sized jpeg image
	    size_m=$OPTARG
	    ;;
	s)
	    # length of longer side of small sized jpeg image
	    size_s=$OPTARG
	    ;;
	t)
	    # length of longer side of tiny sized jpeg image
	    size_t=$OPTARG
	    ;;
	o)
	    # -o option: choice of colour space of output image
	    #  -o 0 ==> raw colour space of the camera
	    #  -o 1 ==> sRGB (default)
	    #  -o 2 ==> Adobe RGB
	    #  -o 3 ==> Wide Gamut RGB
	    #  -o 4 ==> Kodak ProPhoto RGB
	    #  -o 5 ==> XYZ
	    colourspace=$OPTARG
	    ;;
        v)
	    # -v option: verbose outputs
            verbosity=1
            ;;
        w)
	    # -w option: chice of white balance
	    #  -w camera ==> white balance chosen by the camera
	    #  -w auto   ==> white balance calculated from the image
            whitebalance=$OPTARG
            ;;
        \?)
            print_usage
            exit 1
    esac
done
shift $((OPTIND - 1))

###########################################################################

#
# check of options
#

# check of colour space option
if ( [ $colourspace != '0' ] && [ $colourspace != '1' ] \
	 && [ $colourspace != '2' ] && [ $colourspace != '3' ] \
	 && [ $colourspace != '4' ] && [ $colourspace != '5' ] )
then
    echo "ERROR:"
    echo "ERROR: choice of colour space: 0 or 1 or 2 or 3 or 4 or 5"
    echo "ERROR:  0 : raw colour space of the camera"
    echo "ERROR:  1 : sRGB (default)"
    echo "ERROR:  2 : Adobe RGB"
    echo "ERROR:  3 : Wide Gamut RGB"
    echo "ERROR:  4 : Kodak ProPhoto RGB"
    echo "ERROR:  5 : XYZ"
    echo "ERROR:"
    exit 1
fi

# check of location of 'convert' command
if ! [ -e $convert ]
then
    echo "ERROR:"
    echo "ERROR: command '$convert' does not exist!"
    echo "ERROR:"
fi

# check of location of 'convert' command
if ! [ -e $dcraw ]
then
    echo "ERROR:"
    echo "ERROR: command '$dcraw' does not exist!"
    echo "ERROR:"
fi

# check of colour space option
if ( [ $quality != '0' ] && [ $quality != '1' ] \
	 && [ $quality != '2' ] && [ $quality != '3' ] )
then
    echo "ERROR:"
    echo "ERROR: choice of interpolation quality: 0 or 1 or 2 or 3"
    echo "ERROR:  0 : bilinear interporation (high speed, low quality)"
    echo "ERROR:  1 : VNG (Variable Number of Gradients) interpolation"
    echo "ERROR:  2 : PPG (Patterned Pixel Grouping) interpolation"
    echo "ERROR:  3 : AHD (Adaptive Homogeneity-Directed) interpolation"
    echo "ERROR:"
    exit 1
fi

# check of white balance option
if ( [ $whitebalance != 'camera' ] && [ $whitebalance != 'auto' ] )
then
    echo "ERROR:"
    echo "ERROR: choice of white balance must be either 'camera' or 'auto'!"
    echo "ERROR:"
    exit 1
fi

# check of size of smaller jpeg image
$expr $size_m + 1 1>/dev/null 2>&1
if [ $? -eq 2 ]
then
    echo "ERROR:"
    echo "ERROR: invalid size for medium sized jpeg file"
    echo "ERROR:"
    exit 1
fi
$expr $size_s + 1 1>/dev/null 2>&1
if [ $? -eq 2 ]
then
    echo "ERROR:"
    echo "ERROR: invalid size for small sized jpeg file"
    echo "ERROR:"
    exit 1
fi
$expr $size_t + 1 1>/dev/null 2>&1
if [ $? -eq 2 ]
then
    echo "ERROR:"
    echo "ERROR: invalid size for tiny sized jpeg file"
    echo "ERROR:"
    exit 1
fi

###########################################################################

#
# processing each raw image
#
for file_raw in $*
do
    # printing status
    echo "#"
    echo "# now, processing the file '$file_raw'..."

    # suffix of raw image file
    suffix=${file_raw##*.}

    # check of file type of raw image
    # supported file types: Canon's CR2 and Fuji's RAF
    if ( [ $suffix != 'cr2' ] && [ $suffix != 'CR2' ] \
	     && [ $suffix != 'raf' ] && [ $suffix != 'RAF' ] )
    then
	echo "# '$file_raw' is neither Canon's CR2 nor Fuji's RAF, skipping..."
	continue
    fi

    # camera name
    vendor=`$dcraw -i $file_raw | $awk '{printf ("%s", $4);}'`
    if [ $vendor = 'Fujifilm' ]
    then
	camera=`$dcraw -i $file_raw | $awk '{printf ("%s", $5);}'`
    elif [ $vendor = 'Canon' ]
    then
	camera=`$dcraw -i $file_raw | $awk '{printf ("%s %s", $5, $6);}'`
    fi
    echo "#  it is an image taken by ${vendor} ${camera}!"
    
    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#"
	echo "#  given options"
	if [ $colourspace = '0' ]
	then
            echo "#   colour space  = raw colour space of the camera"
	elif [ $colourspace = '1' ]
	then
            echo "#   colour space  = sRGB"
	elif [ $colourspace = '2' ]
	then
            echo "#   colour space  = Adobe RGB"
	elif [ $colourspace = '3' ]
	then
            echo "#   colour space  = Wide Gamut RGB"
	elif [ $colourspace = '4' ]
	then
            echo "#   colour space  = Kodak ProPhoto RGB"
	elif [ $colourspace = '5' ]
	then
            echo "#   colour space  = XYZ"
	fi
	if [ $quality = '0' ]
	then
	    echo "#   interpolation = bilinear interpolation"
	elif [ $quality = '1' ]
	then
	    echo "#   interpolation = VNG (Variable Number of Gradients)"
	elif [ $quality = '2' ]
	then
	    echo "#   interpolation = PPG (Patterned Pixel Grouping)"
	elif [ $quality = '3' ]
	then
	    echo "#   interpolation = AHD (Adaptive Homogeneity-Directed)"
	fi
	echo "#   white balance = $whitebalance"
    fi

    # generating file names of ppm and jpeg files from raw image file name
    generate_filenames $file_raw
    
    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#"
	echo "#  file names"
	echo "#   raw file         = $file_raw"
	echo "#   ppm file         = $file_ppm"
	echo "#   large jpeg file  = $file_jpg_l"
	echo "#   medium jpeg file = $file_jpg_m"
	echo "#   small jpeg file  = $file_jpg_s"
	echo "#   tiny jpeg file   = $file_jpg_t"
    fi

    # command to convert raw image into ppm image
    command_make_ppm="$dcraw -o $colourspace -q $quality"
    if [ $whitebalance = 'camera' ]
    then
	command_make_ppm="$command_make_ppm -w"
    elif [ $whitebalance = 'auto' ]
    then
	command_make_ppm="$command_make_ppm -a"
    fi
    command_make_ppm="$command_make_ppm $file_raw"

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#"
	echo "#  now, converting raw image into ppm image..."
	echo "#   command = $command_make_ppm"
    fi

    # converting raw image into ppm image
    $command_make_ppm

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  finished converting raw image into ppm image!"
    fi

    # check of orientation of image
    size_x=`$file $file_ppm | $awk '{printf ("%d", $7);}'`
    size_y=`$file $file_ppm | $awk '{printf ("%d", $9);}'`
    if [ $size_x -ge $size_y ]
    then
	orientation='landscape'
    else
	orientation='portrait'
    fi

    # if image is taken by Fujifilm X-T30, crop image
    if [ $vendor = 'Fujifilm' ] && [ $camera = 'X-T30' ]
    then
	# size of overscan-like region in pixel
	offset=78
	# command to crop image
	command_crop="$convert $file_ppm"
	if [ $orientation = 'landscape' ]
	then
	    new_x=`$expr $size_x - $offset`
	    new_y=$size_y
	    x0=0
	    y0=0
	elif [ $orientation = 'portrait' ]
	then
	    new_x=$size_x
	    new_y=`$expr $size_y - $offset`
	    x0=0
	    y0=$offset
	fi
	command_crop="$command_crop -crop ${new_x}x${new_y}+${x0}+${y0}"
	command_crop="$command_crop $file_tmp"

	# printing status
	if [ $verbosity != '0' ]
	then
	    echo "#  now, cropping image..."
	    echo "#   command = $command_crop"
	fi

	# cropping image
	$command_crop
	
	# copying file_tmp to file_ppm
	if [ -e $file_tmp ]
	then
	    $mv -f $file_tmp $file_ppm
	    size_x=$new_x
	    size_y=$new_y
	fi

	# printing status
	if [ $verbosity != '0' ]
	then
	    echo "#  finished cropping image!"
	fi

    fi
    
    # calculation of sizes of smaller jpeg files
    if [ $orientation = 'landscape' ]
    then
	medium=$size_m
	small=$size_s
	tiny=$size_t
    elif [ $orientation = 'portrait' ]
    then
	medium=`$expr $size_m \* $size_x / $size_y`
	small=`$expr $size_s \* $size_x / $size_y`
	tiny=`$expr $size_t \* $size_x / $size_y`
    fi
    
    # command for making large jpeg image
    command_make_jpeg_large="$convert $file_ppm $file_jpg_l"

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  now, making large jpeg image..."
	echo "#   command = $command_make_jpeg_large"
    fi

    # converting ppm image into large jpeg file
    $command_make_jpeg_large

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  finished making large jpeg image!"
    fi

    # command for making medium jpeg image
    command_make_jpeg_medium="$convert $file_ppm -resize $medium $file_jpg_m"

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  now, making medium jpeg image..."
	echo "#   command = $command_make_jpeg_medium"
    fi

    # converting ppm image into medium jpeg file
    $command_make_jpeg_medium

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  finished making medium jpeg image!"
    fi
    
    # command for making small jpeg image
    command_make_jpeg_small="$convert $file_ppm -resize $small $file_jpg_s"

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  now, making small jpeg image..."
	echo "#   command = $command_make_jpeg_small"
    fi

    # converting ppm image into small jpeg file
    $command_make_jpeg_small

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  finished making small jpeg image!"
    fi

    # command for making tiny jpeg image
    command_make_jpeg_tiny="$convert $file_ppm -resize $tiny $file_jpg_t"

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  now, making tiny jpeg image..."
	echo "#   command = $command_make_jpeg_tiny"
    fi

    # converting ppm image into tiny jpeg file
    $command_make_jpeg_tiny

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  finished making tiny jpeg image!"
    fi

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  now, removing ppm image..."
    fi

    # removing ppm file
    $rm -f $file_ppm

    # printing status
    if [ $verbosity != '0' ]
    then
	echo "#  finished removing ppm image!"
    fi

    echo "# finished processing the file '$file_raw'!"
done

###########################################################################

#
# reporting summary
#

echo "#"
echo "# summary report"
for file_raw in $*
do
    # generating file names of ppm and jpeg files from raw image file name
    generate_filenames $file_raw

    echo "#"
    echo "#  $file_raw"
    if [ -e $file_jpg_l ]
    then
	if [ -f $file_jpg_l ]
	then
	    if [ -s $file_jpg_l ]
	    then
		echo "#   $file_jpg_l : [ OK ]"
	    else
		echo "#   $file_jpg_l : [ ZERO SIZE ]"
	    fi
	else
	    echo "#   $file_jpg_l : [ NOT A REGULAR FILE ]"
	fi
    else
	echo "#   $file_jpg_l : [ NOT FOUND ]"
    fi

    if [ -e $file_jpg_m ]
    then
	if [ -f $file_jpg_m ]
	then
	    if [ -s $file_jpg_m ]
	    then
		echo "#   $file_jpg_m : [ OK ]"
	    else
		echo "#   $file_jpg_m : [ ZERO SIZE ]"
	    fi
	else
	    echo "#   $file_jpg_m : [ NOT A REGULAR FILE ]"
	fi
    else
	echo "#   $file_jpg_m : [ NOT FOUND ]"
    fi

    if [ -e $file_jpg_s ]
    then
	if [ -f $file_jpg_s ]
	then
	    if [ -s $file_jpg_s ]
	    then
		echo "#   $file_jpg_s : [ OK ]"
	    else
		echo "#   $file_jpg_s : [ ZERO SIZE ]"
	    fi
	else
	    echo "#   $file_jpg_s : [ NOT A REGULAR FILE ]"
	fi
    else
	echo "#   $file_jpg_s : [ NOT FOUND ]"
    fi

    if [ -e $file_jpg_t ]
    then
	if [ -f $file_jpg_t ]
	then
	    if [ -s $file_jpg_t ]
	    then
		echo "#   $file_jpg_t : [ OK ]"
	    else
		echo "#   $file_jpg_t : [ ZERO SIZE ]"
	    fi
	else
	    echo "#   $file_jpg_t : [ NOT A REGULAR FILE ]"
	fi
    else
	echo "#   $file_jpg_t : [ NOT FOUND ]"
    fi

done
