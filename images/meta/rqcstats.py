#!/usr/bin/python

import sys
import json

metadata = dict()
with open(sys.argv[1],'r') as f:
    for line in f:
        if 'inputReads' in line:
            key, value = line.rstrip().split("=")
            metadata['input_read_count'] = int(value)
        if 'inputBases' in line:
            key, value = line.rstrip().split("=")
            metadata['input_read_bases'] = int(value)
        if 'outputReads' in line:
            key, value = line.rstrip().split("=")
            metadata['output_read_count'] = int(value)
        if 'outputBases' in line:
            key, value = line.rstrip().split("=")
            metadata['output_read_bases'] = int(value)

print(json.dumps(metadata, indent=2))
