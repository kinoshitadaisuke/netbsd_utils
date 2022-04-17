#!/bin/sh

# Time-stamp: <2022/04/17 14:28:35 (CST) daisuke>

# function to print usage information
print_usage () {
    echo "USAGE:"
    echo ""
    echo "  test_args_01.sh -a AAA -b BBB -v file file file ..."
    echo ""
}

# command-line argument analysis
args=`getopt a:b:hv $*` || exit
set -- $args
while [ $1 ]
do
    case "$1" in
        -a)
            opt_a=$2
            shift
	    shift
            continue
            ;;
        -b)
            opt_b=$2
            shift
	    shift
            continue
            ;;
        -v)
            opt_v=1
	    shift
            continue
            ;;
	-h)
	    print_usage
	    exit 1
	    ;;
        --)
            shift
            break
            ;;
    esac
done

# optinal arguments
echo "optional arguments:"
echo "  opt_a = $opt_a"
echo "  opt_b = $opt_b"
echo "  opt_v = $opt_v"

# positional arguments
echo "positional arguments:"
for arg in $*
do
    echo "  $arg"
done
