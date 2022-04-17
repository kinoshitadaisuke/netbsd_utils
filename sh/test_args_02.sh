#!/bin/sh

# Time-stamp: <2022/04/17 14:34:01 (CST) daisuke>

# function to print usage information
print_usage () {
    echo "USAGE:"
    echo ""
    echo "  test_args_02.sh -a AAA -b BBB -v file file file ..."
    echo ""
}

# command-line argument analysis
while getopts "a:b:hv" args
do
    case "$args" in
        a)
            opt_a=$OPTARG
            ;;
        b)
            opt_b=$OPTARG
            ;;
        h)
            print_usage
            exit 1
            ;;
        v)
            opt_v=1
            ;;
        \?)
            print_usage
            exit 1
    esac
done
shift $((OPTIND - 1))

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
