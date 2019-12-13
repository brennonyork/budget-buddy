#!/usr/bin/env python3

import re
import sys

ruleset_file = sys.argv[1]
merge_file   = sys.argv[2]

rule_map = {}

with open(ruleset_file, 'r') as rules:
    for rule in rules:
        category, regex = map(lambda x: x.strip(), rule.split(','))

        rule_map[category] = rule_map.get(category, [])
        rule_map[category].append(regex)

print(rule_map)

with open(merge_file, 'r') as transactions:
    for transaction in transactions:
        d, m, c, p = transaction.split(',', 4)
        for k, v in rule_map.items():
            print(k, v)
            matches = list(map(lambda x: re.match(x, c), v))
            print("matches are: ", matches, any(matches))
            if any(matches):
                sys.stdout.write(d+','+m+','+k+','+p)
            else:
                sys.stdout.write(d+','+m+','+c+','+p)
