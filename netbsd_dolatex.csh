#!/bin/csh

#
# Time-stamp: <2022/03/20 07:36:28 (CST) daisuke>
#

#
# NetBSD utils
#
#  utility to carry out LaTeX commands and produce PS and PDF files
#
#  author: Kinoshita Daisuke
#
#  version 1.0: 19/Mar/2022
#

#
# usage:
#
#   % netbsd_dolatex.csh foo.tex
#

# commands
set cat      = /bin/cat
set rm       = /bin/rm
set stat     = /usr/bin/stat
set touch    = /usr/bin/touch
set bibtex   = /usr/pkg/bin/bibtex
set dvipdfmx = /usr/pkg/bin/dvipdfmx
set dvips    = /usr/pkg/bin/dvips
set gs       = /usr/pkg/bin/gs
set latex    = /usr/pkg/bin/latex
set ps2pdfwr = /usr/pkg/bin/ps2pdfwr

# list of commands
set list_commands = ( $latex $bibtex $dvips $dvipdfmx $gs $ps2pdfwr )

# existence check of LaTeX and related commands
foreach command ($list_commands)
    if (! -e $command) then
	echo "ERROR: command '$command' is not found!"
	echo "ERROR: install the command '$command' on your computer!"
	exit
    endif
end

# files and directories
set dir_tmp       = /tmp
set file_usage    = ${dir_tmp}/netbsd_dolatex_usage.$$
set file_commands = ${dir_tmp}/netbsd_dolatex_commands.$$

# initial values of parameters
set verbosity     = 0
set do_bibtex     = 0
set do_dvipdfmx   = 0
set paper_size    = "a4"
set list_files    = ( )
set list_executed = ( )
set list_products = ( )

# usage message
$cat <<EOF > $file_usage
netbsd_dolatex.csh

 Author: Kinoshita Daisuke (c) 2022

 Usage:
  -h : print usage

 Examples:

  execute latex and make a PDF file
    % netbsd_dolatex.csh foo.tex

  printing help
    % netbsd_dolatex.csh -h

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
	case "-b":
	    set do_bibtex = 1
	    breaksw
	case "-d":
	    set do_dvipdfmx = 1
	    breaksw
	case "-p":
	    set paper_size = $argv[2]
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

if !( ($paper_size == "a4") || ($paper_size == "letter") ) then
    echo "ERROR: wrong value for paper size!"
    echo "ERROR: value specified for paper size = $paper_size"
    exit
endif

# option for ps2pdfwr
set opt_ps2pdfwr = "-sPAPERSIZE=$paper_size -dALLOWPSTRANSPARENCY"

# removing file_command if exists
if (-e $file_commands) then
    $rm -f $file_commands
endif

# making an empty file
$touch $file_commands

# processing files one-by-one
foreach file_tex ($list_files)
    # if the file is not TeX file, the skip
    if ($file_tex:e != 'tex') then
	echo "ERROR: the file '$file_tex' is not a LaTeX source file!"
	echo "ERROR: skipping the file '$file_tex'..."
	continue
    endif

    # DVI, PS, and PDF file names
    set file_aux = ${file_tex:r}.aux
    set file_bbl = ${file_tex:r}.bbl
    set file_blg = ${file_tex:r}.blg
    set file_dvi = ${file_tex:r}.dvi
    set file_log = ${file_tex:r}.log
    set file_out = ${file_tex:r}.out
    set file_ps  = ${file_tex:r}.ps
    set file_pdf = ${file_tex:r}.pdf

    # intermediate files
    set list_intermediate = ( $file_aux $file_bbl $file_blg \
				$file_dvi $file_log $file_out )

    # all files
    set list_all_files = ( $list_intermediate $file_ps $file_pdf )
    
    # printing information
    if ($verbosity) then
	echo "#  file names"
	echo "#   aux file = $file_aux"
	echo "#   bbl file = $file_bbl"
	echo "#   blg file = $file_blg"
	echo "#   dvi file = $file_dvi"
	echo "#   log file = $file_log"
	echo "#   out file = $file_out"
	echo "#   ps  file = $file_ps"
	echo "#   pdf file = $file_pdf"
    endif

    # removing intermediate files
    foreach file_intermediate ($list_intermediate)
	if ($verbosity) then
	    echo "#  deleting file '$file_intermediate'..."
	endif
	$rm -f $file_intermediate
    end
    
    # latex commands
    set command_latex    = "$latex $file_tex"
    set command_bibtex   = "$bibtex $file_tex"
    set command_dvips    = "$dvips -o $file_ps $file_dvi"
    set command_dvipdfmx = "$dvipdfmx $file_dvi"
    set command_ps2pdfwr = "$ps2pdfwr $opt_ps2pdfwr $file_ps"

    # bibtex
    if ($do_bibtex) then
	echo "#"
	echo "# executing '$command_latex'"
	echo "#"
	$command_latex
	$cat <<EOF >> $file_commands
#   $command_latex
EOF
	echo "#"
	echo "# executing '$command_bibtex'"
	echo "#"
	$command_bibtex
	$cat <<EOF >> $file_commands
#   $command_bibtex
EOF
    endif

    # making PS file
    echo "#"
    echo "# executing '$command_latex'"
    echo "#"
    $command_latex
    $cat <<EOF >> $file_commands
#   $command_latex
EOF
    echo "#"
    echo "# executing '$command_latex'"
    echo "#"
    $command_latex
    $cat <<EOF >> $file_commands
#   $command_latex
EOF
    echo "#"
    echo "# executing '$command_dvips'"
    echo "#"
    $command_dvips
    $cat <<EOF >> $file_commands
#   $command_dvips
EOF

    # making PDF file
    if ($do_dvipdfmx) then
	echo "#"
	echo "# executing '$command_dvipdfmx'"
	echo "#"
	$command_dvipdfmx
	$cat <<EOF >> $file_commands
#   $command_dvipdfmx
EOF
    else
	echo "#"
	echo "# executing '$command_ps2pdfwr'"
	echo "#"
	$command_ps2pdfwr
	$cat <<EOF >> $file_commands
#   $command_ps2pdfwr
EOF
    endif

    # products
    foreach file ($list_all_files)
	if (-e $file) then
	    set list_products = ( $list_products $file )
	endif
    end
end

echo "#"
echo "# Summary"
echo "#"
echo "#  Executed commands"
echo "#"
$cat $file_commands
echo "#"
echo "#  Created files"
echo "#"
foreach file ($list_products)
    set size_byte = `$stat -f %z $file`
    set mtime     = `$stat -f %Sm $file`
    printf "#   %-32s  %12d byte    $mtime\n" $file $size_byte
end
echo "#"

# removing temporary files
if (-e $file_commands) then
    $rm -f $file_commands
endif
if (-e $file_usage) then
    $rm -f $file_usage
endif
