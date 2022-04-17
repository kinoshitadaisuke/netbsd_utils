#!/bin/sh

# Time-stamp: <2022/04/17 14:17:06 (CST) daisuke>

# function to print usage information
print_usage () {
    echo "USAGE:"
    echo ""
    echo "  test_args_00.sh -a AAA -b BBB -v file file file ..."
    echo ""
}

# making an empty variable for positional arguments
args=""

# command-line argument analysis
while [ $1 ]
do
    case $1 in
	-a)
	    opt_a=$2
	    shift
	    ;;
	-b)
	    opt_b=$2
	    shift
	    ;;
	-h)
	    print_usage
	    exit 1
	    ;;
	-v)
	    opt_v=1
	    ;;
	-*)
	    echo "invalid option!"
	    echo "option $1 is not supported."
	    print_usage
	    exit 1
	    ;;
	*)
	    args="$args $1"
	    ;;
    esac
    shift
done

# optinal arguments
echo "optional arguments:"
echo "  opt_a = $opt_a"
echo "  opt_b = $opt_b"
echo "  opt_v = $opt_v"

# positional arguments
echo "positional arguments:"
for arg in $args
do
    echo "  $arg"
done
