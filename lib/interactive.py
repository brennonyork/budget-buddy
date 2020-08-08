#!/usr/bin/env python3

# Arg1 - ruleset file that contains all rulesets, could be empty
# Arg2 - cleaned, sorted single file with all transactions
#
# Reads in all current rulesets then creates an interactive prompt
# for the user to state the category for any transaction where no
# ruleset applies. Then creates the rule for that exact transaction
# and adds it to the ruleset.

import re
import sys

if len(sys.argv) < 3:
    print("ERROR: need to supply a ruleset file and transaction file")
    exit()

ruleset_file = sys.argv[1]
merge_file   = sys.argv[2]

rule_map = []

# we create a new list of rules to add to the existing ruleset file so that
# if we received an existing ruleset file we can preserve comments comments
# and newlines rather than overwriting
new_rules = []

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
            new_rules.append(["interactive","^"+re.escape(m)+"$"])

# finally write out only the new rulesets we've found
for category, regex in new_rules:
    sys.stdout.write(category+", "+regex+" # added interactively\n")
