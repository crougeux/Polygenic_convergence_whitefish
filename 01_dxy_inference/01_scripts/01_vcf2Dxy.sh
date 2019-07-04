#!/bin/bash

# 1 CPU
# 5 Go

# Script to format original VCF files into a vcf Genotype Format & to lauch DXY estimations based on sliding windows.
# Dependencies: Dxy_WGS.pl & Dxy.pl

cd "${PBS_O_WORKDIR}"

# keep some info
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
echo "$SCRIPT"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"


# Define options
TEMP="99_tmp/"
VCF="path/to/your/filtered/VCFfile"
POP="00_info_files"
SCRPT="./01_scripts"
IN="02_input_files"
OUT="04_output_files"
WNDW="1000"

# Prepare input file(s)
ls -1 $VCF/*.vcf |			# Adjust file names to correspond with you POP file
    while read i
    do
        echo $i
        vcftools --vcf $(basename $i .vcf).vcf --keep $POP/$(basename $i .vcf).txt --extract-FORMAT-info GT --out $IN/$(basename $i .vcf)
done

# Estimate pairwise Dxy per lake
$SCRPT/Dxy_WGS.pl -012 $GT/cliff.GT.FORMAT -pop ../99_info_files/cliff.txt -w 1000 -out ../09_dxy_analysis/03_output_files/cliff_dxy
ls -1 $IN/*.GT.FORMAT |			
    while read i
    do
        echo $i
$SCRPT/Dxy_WGS.pl -012 $(basename $i .GT.FORMAT).GT.FORMAT -pop $POP/$(basename $i .GT.FORMAT).txt -w $WNDW -out $OUT/$(basename $i .GT.FORMAT)_dxy
done
