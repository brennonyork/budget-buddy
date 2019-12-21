#!/usr/bin/env python3

# Arg1 - ruleset file that contains all rulesets
# Arg2 - cleaned, sorted single file with all transactions
#
# Transforms a given file - Arg2 - into the column set form below
# with the rulesets written and applied for the given financial
# source - Arg1

import re
import sys

if len(sys.argv) < 3:
    print("ERROR: need to supply a ruleset file and transaction file")
    exit()

ruleset_file = sys.argv[1]
merge_file   = sys.argv[2]
incl_history = None

# if extra arg passed then we include the historical transaction before
# we change it w the ruleset regexs
if len(sys.argv) == 4:
    incl_history = sys.argv[3]

rule_map = []

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
                                 map(lambda y: y[1],
                                     rule_map)))
        
        if any(regex_matches):
            # find longest match by taking the second element from the
            # `span` regex method thus returning the length of the match as
            # well as the index
            longest_match = max([[i, j.span()[1]-j.span()[0]] for i, j in enumerate(regex_matches) if j],
                                key=lambda x: x[1])
            
            # pull the new category by taking the index from the longest
            # match, looking up that index in the rule_map, and then taking
            # the first element from that list (ie the category, not the
            # regex assigned to that category label)
            new_category = rule_map[longest_match[0]][0]

            if incl_history:
                if not(c): c = "Empty"
                sys.stdout.write(d+','+m+','+new_category+','+p+','+c+'\n')
            else:
                sys.stdout.write(d+','+m+','+new_category+','+p+'\n')
        else:
            sys.stdout.write(d+','+m+','+c+','+p+'\n')
