#!/usr/bin/env sh

# Unique set of short form financial sources that the program
# will execute over for (1) column transforms and (2) ruleset
# application
FINANCE_SOURCES=("c1" "boa" "chase")

# Arg1 - short form abbreviation for the finance source we wish
#        to transform
# TODO: determine extension X
# Checks for a file with extension X in the local directory of
# this script which should contain the rulesets for that financial
# source - Arg1 - and, if not present, exit the program in error
check_for_ruleset_file() {
    if [ ! -f "$1" ]; then
	echo "ERROR: No ruleset file for $1"
	exit 3
    fi
}

# Arg1 - short form abbreviation for the finance source we wish
#        to transform
# Arg2 - file to apply the transforms to
# Arg3 - temporary file name to place results into
#
# Transforms a given file - Arg2 - into the column set form below
# with the rulesets written and applied for the given financial
# source - Arg1
#
# Column Set - columns should be comma separated in this order:
#   Transaction Date: date the transaction happened w the merchant
#   Posted Date: date the transaction posted to the account
#   Description: merchant string detailing what the purchase was
#   Category: the category this transaction should be tagged as
#   Amount: amount of the transaction where positive values denote
#           credits to the account, negatives denote sales or debits
column_transform() {
    case "${1}" in
	"c1")
	    cut -d, -f1-2,4-7 "${2}" | \
		awk -F',' '{
			    printf $1","$2","$3","$4","; 
       			    if ( $6 == "" ) { print -$5 } else { print $6 }
			   }' > "${3}"
	    ;;
	"chase")
	    cut -d, -f1-4,6 "${2}" > "${3}"
	    ;;
	"boa")
	    echo "bank of america"
	    ;;
	*)
	    echo "unrecognized"
	    ;;
    esac
}
