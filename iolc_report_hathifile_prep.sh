#!/usr/bin/env bash

# Usage example:
#   ./iolc_report_hathifile_prep.sh "../IA-to-HT-ingest-prep/hathi_full_20181001.txt"
awk -F'\t' '{print $8}' "$1" |
tr "," "\n" |
sort |
uniq > hathi_oclcnums.txt
