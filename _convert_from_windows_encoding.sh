#!/bin/bash

[ $# -eq 0 ] && { echo "Usage: $0 input_file output_file"; exit 1; }

iconv -f WINDOWS-1252 -t UTF-8 -c $1 > $2
