#!/bin/bash

# 1 CPU
# 2 Go

# Here is an example of formating step to process output files obtained from the RDA into input files for signet.
# signet input file should be composed by two tab-separated columns (differentiation score\tgeneID)

cd $SLURM_SUBMIT_DIR

TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"


# Formating RDA output to signet input
echo "$SCRIPT"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"# Add the transcript ID information to the scores from the RDA
TRANSID="transcript_id.txt" 								#list of transcripts sorted
RDASCORE="../03_outputs_RDA/score_RDA1_cond_lucerne.txt"	#sorted RDA scores
SCOREDTRANS="transcript_score_rda_lucerne.txt" 				#output should be transcript associated RDA scores 
paste -d "\t" $TRANSID $RDASCORE > $SCOREDTRANS &&

# Compare file SCOREDID to the file with GeneID information per transcript "gene_ID_ensembl_sorted.txt"
GENEID="gene_ID_ensembl_sorted.txt"  &&						#GeneID ensembl sorted
SCOREDTRANS="transcript_score_rda_lucerne.txt"  &&
TRANSGENEID="transcript_geneID_lucerne.txt" &&
awk 'BEGIN{i=0} FNR==NR { a[i++]=$1; next } { for(j=0;j<i;j++) if(index($0,a[j])) {print $0;break} }' $SCOREDTRANS $GENEID > $TRANSGENEID &&

# Extract transcript list sorted and associated with GeneID score
TRANSGENEID="transcript_geneID_lucerne.txt"  &&				#output of step 2 -> Transcript_id and Gene_id
SORTTRANS="sortedTrans_lucerne.txt" && 						#first column of the sorted transcript with geneID
SORTSCORE="transcript_score_lucerne.txt"  &&				# Transcripts with score sorted by geneID
awk '{print$1}' $TRANSGENEID > $SORTTRANS && awk 'BEGIN{i=0} FNR==NR { a[i++]=$1; next } { for(j=0;j<i;j++) if(index($0,a[j])) {print $0;break} }' $SORTTRANS $SCOREDTRANS > $SORTSCORE && rm $SORTTRANS  &&

# Extract sorted geneID (i.e column 2 of TRANSGENEID) AND  add this column to the sorted transcripts and GeneID informations in SORTSCORE
COL2="sortedGeneID_lucerne.txt"  &&
SIGNETIN="transcript_scoreRDA_geneID_lucerne.txt"  &&
awk '{print$2}' $TRANSGENEID > $COL2 && paste -d "\t" $SORTSCORE $COL2 > $SIGNETIN && rm $COL2 

# Signet input formatted
for i in *.txt do ; awk '{print$2"\t"$3}' $i > scoreRDA_geneID_"$i" ; done
