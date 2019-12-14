#!/usr/bin/env python3

import re
import sys

ruleset_file = sys.argv[1]
merge_file   = sys.argv[2]

rule_map = []

with open(ruleset_file, 'r') as rules:
    for rule in rules:
        category, regex = map(lambda x: x.strip(), rule.split(','))
        rule_map.append([category, regex])

with open(merge_file, 'r') as transactions:
    for transaction in transactions:
        d, m, c, p = transaction.split(',', 4)
        regex_matches = list(map(lambda x: re.match(x, m),
                                 map(lambda y: y[1],
                                     rule_map)))
        match_indices = [i for i, j in enumerate(regex_matches) if j]

        # right now first match wins
        # TODO: make it so *longest* match wins
        if any(match_indices):
            sys.stdout.write(d+','+m+','+rule_map[match_indices[0]][0]+','+p)
        else:
            sys.stdout.write(d+','+m+','+c+','+p)
