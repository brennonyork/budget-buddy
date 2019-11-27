#!/usr/bin/env sh

###
# If you want to add a new financial source you'll need to add
# new rules to the following functions in this file:
# - FINANCE_SOURCES -> add the short form name
# - detect_source_files() -> add a way to detect the source files
#                            (if you want) to automatically process
# - column_transform() -> add way to update the files into the
#                         proper format
###

# Unique set of short form financial sources that the program
# will execute over for (1) column transforms and (2) ruleset
# application
FINANCE_SOURCES=("c1" "boa" "chase" "usaa")

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
#   XXX Transaction Date: date the transaction happened w the merchant
#   --> Update - Can't have transaction date  because multiple
#   -->          institutions don't provide this
#   Posted Date: date the transaction posted to the account
#   Description: merchant string detailing what the purchase was
#   Category: the category this transaction should be tagged as
#   Amount: amount of the transaction where positive values denote
#           credits to the account, negatives denote sales or debits
column_transform() {
    case "${1}" in
	"c1")
	    # Transaction Date,Posted Date,Card No.,Description,Category,Debit,Credit
	    cut -d, -f2,4-7 "${2}" | \
		awk -F',' '{
			    printf $1","$2","$3","; 
       			    if ( $5 == "" ) { print -$4 } else { print $5 }
			   }' > "${3}"
	    ;;
	"chase")
	    # Transaction Date,Post Date,Description,Category,Type,Amount
	    cut -d, -f2-4,6 "${2}" > "${3}"
	    ;;
	"boa")
	    # Posted Date,Reference Number,Payee,Address,Amount
	    cut -d, -f1,3,5 "${2}" | \
		awk -F',' '{ print $1","$2",,"$3 }' > "${3}"
	    ;;
	"usaa")
	    # Columns not defined
	    cut -d, -f3,5-7 "${2}" | \
		awk -F',' '{
                            printf $1","$2","$3",";
                            if ( substr($4, 1, 2) == "--" ) { 
                              print substr($4,3) 
                            } else { print $4 }
                           }' > "${3}"
	    ;;
	*)
	    echo "unrecognized"
	    ;;
    esac
}

# Arg1 - file to remove first line from
remove_first_line_in_file() {
    tail -n +2 "${1}" > "${1}.clean"
}

# Arg1 - column-normalized file to read date from
# Ret  - return max posted date from the file
determine_date_from_file() {
    echo $(cut -d, -f1 "${1}" |  head -1 | xargs | sed 's/\//-/g')
}

# Arg1 - short form abbreviation for the finance source we wish
#        to transform
# TODO: determine extension X
# Checks for a file with extension X in the local directory of
# this script which should contain the rulesets for that financial
# source - Arg1 - and, if not present, exit the program in error
_check_for_ruleset_file() {
    if [ ! -f "$1" ]; then
	echo "ERROR: No ruleset file for $1"
	exit 3
    fi
}

# Arg1 - short form abbreviation for the finance source we wish
#        to transform
# Arg2 - file to apply the transforms to
# Arg3 - output file name to place results into
# Arg4 - ruleset directory that contains all rulesets
#
# Transforms a given file - Arg2 - into the column set form below
# with the rulesets written and applied for the given financial
# source - Arg1
ruleset_transform() {
    while read line; do 
	echo $line
    done < "${4}/${1}.txt"
}

# Arg1 - temporary directory
# Arg2 - output directory
# Arg3 - ruleset directory
# Arg4 - full path of the input file to operate on
# Arg5 - determined financial source 
#
# Operates all necessary functions on a single file after it's been
# determined what financial source it came from
handle_single_file() {
    filename="$(basename ${4})"
    tmp_file="${1}/${filename}"
    
    column_transform "${5}" "${4}" "${tmp_file}"
    remove_first_line_in_file "${tmp_file}"
    date_file=$(determine_date_from_file "${tmp_file}.clean")
    mv "${tmp_file}" "${1}/${date_file}.txt"
    ruleset_transform "${5}" "${tmp_file}" "${2}" "${3}"
}
