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
	    cut -d, -f2,4-7 "${2}" | \
		sed '/^[[:space:]]*$/d' | \
		awk -F',' '{
			    printf $1","$2","$3","; 
       			    if ( $5 == "" ) { print -$4 } else { print $5 }
			   }' > "${3}"
	    ;;
	"chase")
	    cut -d, -f2-4,6 "${2}" | \
		sed '/^[[:space:]]*$/d' > "${3}"
	    ;;
	"boa")
	    cut -d, -f1,3,5 "${2}" | \
		sed '/^[[:space:]]*$/d' | \
		sed 's/,"/,/g' | \
		sed 's/",/,/g' | \
		awk -F',' '{ print $1","$2",,"$3 }' > "${3}"
	    ;;
	"usaa")
	    cut -d, -f3,5-7 "${2}" | \
		sed '/^[[:space:]]*$/d' | \
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
# Ret  - absolute path to 'cleaned' file name
remove_first_line_in_file() {
    clean_file="${1}.clean"
    tail -n +2 "${1}" > "${clean_file}"
    rm "${1}"
    echo "${clean_file}"
}

# Arg1 - column-normalized file to read date from
# Ret  - return max posted date from the file
max_date_from_file() {
    echo $(cut -d, -f1 "${1}" | head -1 | xargs)
}

# Arg1 - column-normalized file to read date from
# Ret  - return minimum posted date from the file
min_date_from_file() {
    echo $(cut -d, -f1 "${1}" | tail -1 | xargs)
}

# Arg1 - column-normalized file to read date from
# Arg2 - parse string for the input date format
normalize_date() {
    awk -F',' -v date_fmt="${2}" \
	'{
          cmd="date -j -f "date_fmt" "$1" +%Y-%M-%d";
          cmd | getline mydate;
          print mydate","$2","$3","$4;
          close(cmd);
         }' "${1}" > "${1}.awk"
    mv "${1}.awk" "${1}"
}

# Arg1 - ruleset file that contains all rulesets
# Arg2 - directory where all monthly, clean files are located
#
# Transforms a given file - Arg2 - into the column set form below
# with the rulesets written and applied for the given financial
# source - Arg1
ruleset_transform() {
    while read ruleset_line; do
	for file in $(find "${2}" -type f); do
	    echo $ruleset_line >&2
	    category="$(echo "${ruleset_line}" | cut -d',' -f1 | xargs)"
	    pattern="$(echo "${ruleset_line}" | cut -d',' -f2- | xargs)"
	    awk -F',' \
		-v pattern="${pattern}" \
		-v category="${category}" \
		'{
  		      if ( $2 ~ pattern ) {
                        print "got coffee";
              	      } else {
                        print $1","$2","$3","$4
                      }
                 }' "${file}" > "${file}.awk"
	done
    done < "${1}"
}

# Arg1 - temporary directory
# Arg2 - output directory
# Arg3 - full path of the input file to operate on
# Arg4 - determined financial source
# Arg5 - boolean "true" or "false" to determine if we remove the
#        first line (header) or not
# Arg6 - input parse string for the posted transaction date format
#
# Operates all necessary functions on a single file after it's been
# determined what financial source it came from.
#
# Handles operations in this order:
# 1. 'transform' the columns to be in the correct order and only
#    containing the columns needed
# 2. remove the header from the file (if it exists)
# 3. determine the maximum date from the file
# 4. use the maximum date to rename the file so we can avoid
#    naming conflicts after we've processed, useful given statements
#    all start at different dates. this program *does not* dedupe
#    individual transactions therefore needs to ensure we process each
#    record exactly once and max date matches each statement
handle_single_file() {
    filename="$(basename ${3})"
    tmp_file="${1}/${filename}"
    clean_file=""
    
    column_transform "${4}" "${3}" "${tmp_file}"
    if [ "${5}" = "true" ]; then
	clean_file=$(remove_first_line_in_file "${tmp_file}")
    else
	clean_file="${tmp_file}"
    fi
    normalize_date "${clean_file}" "${6}"
    max_date=$(max_date_from_file "${clean_file}")
    mv "${clean_file}" "${1}/${max_date}.csv"
}

# Arg1 - the fully merged and sorted set of transactions
# Arg2 - output directory to put monthly files into
split_file_by_month() {
    max_date=$(max_date_from_file "${1}")
    max_year=$(echo "${max_date}" | cut -d- -f1)
    max_month=$(echo "${max_date}" | cut -d- -f2)
    
    min_date=$(min_date_from_file "${1}")
    min_year=$(echo "${min_date}" | cut -d- -f1)
    min_month=$(echo "${min_date}" | cut -d- -f2)

    for month in $(seq -f"%02g" "${min_month}" "${max_month}"); do
	for year in $(seq "${min_year}" "${max_year}"); do
	    grep "^${year}-${month}" "${1}" >/dev/null
	    if [ "$?" = "0" ]; then
		grep "^${year}-${month}" "${1}" > "${2}/${year}-${month}.csv"
	    fi
	done
    done
}
