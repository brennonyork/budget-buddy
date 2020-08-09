#!/usr/bin/env python3

# Arg1 - ruleset file that contains all rulesets, could be empty
# Arg2 - cleaned, sorted single file with all transactions
# Arg3 - output file to write new rules to
#
# Reads in all current rulesets then creates an interactive prompt
# for the user to state the category for any transaction where no
# ruleset applies. Then creates the rule for that exact transaction
# and adds it to the ruleset.

import os
import re
import sys

if len(sys.argv) < 3:
    print("ERROR: need to supply a ruleset file and transaction file")
    exit()

ruleset_file = sys.argv[1]
merge_file   = sys.argv[2]
output_file  = sys.argv[3]
categories_file = None

# if extra arg passed then we override the default categories presented
if len(sys.argv) == 5:
    categories_file = sys.argv[4]

rule_map = []

# we create a new list of rules to add to the existing ruleset file so that
# if we received an existing ruleset file we can preserve comments
# and newlines rather than overwriting when we write out
new_rules = []

categories = []

# based on this blog:
# - https://www.madfientist.com/financial-independence-spreadsheet/
# overridden if categories_file != None
default_categories = [
    "Mortgage",
    "Internet",
    "Cell Phone",
    "Utilities",
    "Groceries",
    "Car Insurance",
    "Home Insurance",
    "Property Tax",
    "Gasoline",
    "Car",
    "House",
    "Health Insurance",
    "Misc",
    "Restaurants",
    "Entertainment",
    "Shopping",
    "Travel",
    "Gifts"]

# from: https://stackoverflow.com/a/684344
def cls():
    os.system('cls' if os.name=='nt' else 'clear')

if categories_file:
    with open(categories_file, 'r') as cf:
        for c in cf:
            # if its only a newline we skip it or if the line starts with a '#' character then skip the line
            if c == "\n" or c[0] == '#':
                continue
            else:
                # else split by a '#' if it exists and take everything before it
                categories.append(c.split('#')[0])
else:
    categories = default_categories;

with open(ruleset_file, 'r') as rules:
    for rule in rules:
        # if its only a newline we skip it or if the line starts with a '#' character then skip the line
        if rule == "\n" or rule[0] == '#':
            continue
        else:
            # else split by a '#' if it exists and take everything before it
            category, regex = map(lambda x: x.strip(), rule.split('#')[0].split(','))
            rule_map.append([category, regex])
        
with open(merge_file, 'r') as transactions:
    for transaction in transactions:
        d, m, c, p = map(lambda x: x.strip(), transaction.split(',', 4))
        regex_matches = list(map(lambda x: re.search(x, m),
                                 list(map(lambda y: y[1],
                                     rule_map)) +
                                 list(map(lambda z: z[1],
                                     new_rules))))
        if any(regex_matches):
            continue
        else:
            # we've found a new transaction that doesn't match anything in
            # our ruleset so present an interactive prompt and read the category
            # from user input
            cls()
            sys.stdout.write("Merchant: "+m+"\n\n")
            for i in range(0,len(categories)):
                sys.stdout.write(" "+str(i+1)+".\t"+categories[i]+"\n")
            sys.stdout.write("\n")
            val = input("Choose the category: ")
            new_rules.append(["interactive","^"+re.escape(m)+"$"])

# finally write out only the new rulesets we've found
with open(output_file, 'w') as out:
    for category, regex in new_rules:
        out.write(category+", "+regex+" # added interactively\n")
