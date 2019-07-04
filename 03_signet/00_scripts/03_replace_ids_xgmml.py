#!/usr/bin/env python

# You might want to replace genes ID in your signet output files, particularly for plotting the subnetworks (in Cytoscape).
# Here it's a possible way to achieve that. Getting the Gene symbol insted of GeneID (number) in the xgmml generated previously.


"""Replace IDs in xgmml file

Usage:
    ./replace_ids_xgmml.py input_file replacements output_file

Where:
    input_file has not organised by columns and contains string that we want to replace
    replacements has two columns, FROM and TO
    output_file is like input_file but with some columns replaced
"""

# Modules
import sys
import os
import re

# Parse user input
try:
    input_file = sys.argv[1]
    replacements = sys.argv[2]
    output_file = sys.argv[3]
except:
    print __doc__
    sys.exit(1)

# Read replacement file
replacement_dict = dict()
with open(replacements) as rfile:
    for line in rfile:
        l = line.strip().split()
        replacement_dict[l[0]] = l[1]

# Replace columns in input_file
with open(output_file, "w") as outfile:
    with open(input_file) as infile:
        for text in infile:
            if "name=\"NODE_LABEL\"" in text:
                value = re.findall("value=\"\d+\"", text)[0]
                if value in replacement_dict:
                    replacement = replacement_dict[value]
                    outfile.write(text.replace(value, replacement))
                else:
                    print "CRASH"
                    sys.exit(1)
            else:
                outfile.write(text)
