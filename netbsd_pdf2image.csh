#!/bin/csh

#
# Time-stamp: <2022/03/23 21:00:15 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to convert a PDF file into multiple image files
#
#  author: Kinoshita Daisuke
#
#  version 1.0: 20/Mar/2022
#

#
# usage:
#
#   % netbsd_pdf2image.csh foo.pdf
#

# commands
set cat  = /bin/cat
set ls   = /bin/ls
set rm   = /bin/rm
set stat = /usr/bin/stat
set gs   = /usr/pkg/bin/gs

# options for commands
set opt_gs = "-dBATCH -dNOPAUSE -q"

# files and directories
set dir_tmp    = /tmp
set file_usage = ${dir_tmp}/netbsd_dolatex_usage.$$

# available image formats
set list_image_format = ( "bmp" "jpg" "png" "ppm" "tiff")

# initial values of parameters
set image_format = "png"
set resolution   = 600
set list_files   = ( )
set verbosity    = 0

# usage message
$cat <<EOF > $file_usage
netbsd_pdf2image.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -h : print usage

 Examples:

  converting PDF file into PNG files
    % netbsd_pdf2image.csh foo.pdf

  printing help
    % netbsd_pdf2image.csh -h

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
        case "-f":
            set image_format = $argv[2]
	    shift
            breaksw
        case "-r":
            set resolution = $argv[2]
	    shift
            breaksw
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

# check of output image format
set compatibility = 0
foreach format ($list_image_format)
    if ($image_format == $format) then
	set compatibility = 1
    endif
end

# if specified image format is not available, then stop the script
if (! $compatibility) then
    echo "ERROR: invalid image format!"
    echo "ERROR: specified image format '$image_format' is not available!"
    echo "ERROR: exiting..."
    exit
endif

# if no PDF file is given, then stop the script
if (! $#list_files) then
    echo "ERROR: no PDF file is given!"
    echo "ERROR: exiting..."
    exit
endif

foreach file_pdf ($list_files)
    # file name without extension
    set basename = $file_pdf:r
    # gs option for resolution
    set opt_res = "-r$resolution"
    # gs option for device
    if ($image_format == "bmp") then
	set opt_dev = "-sDEVICE=bmp256"
    else if ($image_format == "jpg") then
	set opt_dev = "-sDEVICE=jpeg"
    else if ($image_format == "png") then
	set opt_dev = "-sDEVICE=png256"
    else if ($image_format == "ppm") then
	set opt_dev = "-sDEVICE=ppm"
    else if ($image_format == "tiff") then
	set opt_dev = "-sDEVICE=tiff24nc"
    else
	set $opt_dev = "-sDEVICE=png256"
    endif
    # command for conversion
    set command_gs = "$gs $opt_gs $opt_res $opt_dev -sOutputFile=${basename}_%04d.$image_format $file_pdf"

    # printing input parameters
    if ($verbosity) then
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
    endif

    # printing status
    if ($verbosity) then
	echo "# now, converting PDF file into multiple images..."
    endif
    
    # executing command
    $command_gs

    # printing status
    if ($verbosity) then
	echo "# finished converting PDF file into multiple images!"
    endif

    # showing summary
    if ($verbosity) then
	echo "#"
	echo "# Summary"
	echo "#"
	echo "#  Command used for conversion from PDF into images"
	echo "#   $command_gs"
	echo "#"
	echo "#  List of files created:"
	foreach file_image (${basename}_*.$image_format)
	    # file size in kilo-byte
	    set size_kb = `$stat -f %Lz $file_image`
	    printf "#   %-32s (%5d KB)\n" $file_image $size_kb
	end
	echo "#"
    endif
end
