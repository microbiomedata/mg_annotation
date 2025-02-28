#!/usr/bin/env python
# Chienchi Lo 20240208

import os
import sys
import argparse
import plotly
import plotly.express as px

# Argument parsing
parser = argparse.ArgumentParser()
parser.add_argument('--input', '-i', type=str, help='Input file', required=True)
parser.add_argument('--output', '-o', type=str, help='Output file name', default='protein_size.html')

args = parser.parse_args()

# Setting default values
output = args.output

stats = {}
q_feat = "CDS"  # for prokka gff
ctg_num = 0  # total number of contigs
all_aa_len = [] 

with open(args.input, 'r') as gff3:
    for line in gff3:
        line = line.strip()
        temp = line.split('\t')
        if len(temp) != 9:
            continue
        
        # Counting GENE attributes
        if temp[2] == q_feat:
            CDS_len = int(temp[4])-int(temp[3]) + 1
            aa_len = int(CDS_len/3)
            all_aa_len.append(aa_len)
            a_temp = temp[8].split(';')
            for attr in a_temp:
                tag, val = attr.split('=')
                tag = tag.upper()

fig = px.histogram(all_aa_len,title='Distribution of Protein size')
fig.update_traces(xbins_size=50)
fig.update_layout(showlegend=False,xaxis_title="Protein size(aa)",yaxis_title="Count",)
fig.write_html(output)
        