#!/usr/bin/env sh

print_help() {
    echo "Budget Buddy!"
    echo
    echo "Budget Buddy was created as an alternate financial tracking platform"
    echo "made specifically to be molded, customized, or changed to help people"
    echo "track their finances across all their finance providers."
    echo
    echo "Usage:"
    echo " $ budget-buddy [ -h | --help ]"
    echo " $ budget-buddy [ opts ] -d <directory>"
    echo
    echo "-h | --help:"
    echo "  Display this help screen"
    echo "-d <directory> | --directory <directory>"
    echo "  (required) The directory that budget-buddy will scan for files to"
    echo "  process. Currently supports USAA, Chase, Bank of America, and Capital"
    echo "  One."
    echo "-r <file> | --ruleset <file>"
    echo "  A .csv file containing (category, regex) pairs which will be applied"
    echo "  across all transactions matching against the merchant name and, if"
    echo "  found, updates the category for that transaction. See ruleset.defaults"
    echo "  for a sane set of examples."
    echo "-s | --split"
    echo "  Splits the financial record into monthly files after the transactions"
    echo "  have been merged from all financial sources."
    echo "-h | --history"
    echo "  If enabled budget-buddy will add a 5th column to the output stating"
    echo "  the original category found *before* applying ruleset file."
}
