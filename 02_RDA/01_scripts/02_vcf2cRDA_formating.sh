# Code to prepare input files for partialRDA from 012 matrice from VCF.
#UNIX
# Create 012 matrix from vcftools
for i in *.vcf ; do vcftools --vcf $i --012 --out "$i" ; done

# Extract loci information and transpose to get loci as column 
for i in *.pos ; do perl -p -e 's/\t/_/' $i | perl -p -e 's/\n/\t/' | awk '{print "\t"$0}' | perl -p -e 's/\n//' | perl -pe 's/\t$/\n/g' > "$i"_transpose.txt ; done

# Add ID for each individual for line informations
for i in *.012 ; do paste "$i".indv $i > "$i"_indv.txt ; done

# delete the second column of 012 matrice (number = individuals), with new IDs
for i in *_indv.txt ; do awk '!($2="")' $i > "$i".temp ; done

# Add loci IDs to the matrice
for i in *.012 ; do cat "$i".pos_transpose.txt "$i"_indv.txt.temp | perl -p -e 's/  //g' | perl -pe 's/ /\t/g' > "$i"_rda.txt  ; done && 
rm *_indv.* &&
rm *.pos_* &&
rm *.012 &&
rm *.indv &&
rm *.pos *.log               

# delete the first column of 012 matrice to remove IDs #and change space/tab sep
for i in *_rda.txt ; do awk '!($1="")' $i  | perl -pe 's/ /\t/g' | perl -pe 's/^\t|//' > "$i".temp  ; done
rm *.txt && 
for i in *.temp ; do mv $i $(echo $i | sed 's/.temp//g') ; done