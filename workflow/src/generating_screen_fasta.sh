#!/bin/bash

cd ../int

## downloading the file from AddGene
## located under depositor data (Brunello Library Target Genes link) 
## if you save the link it will be called the following and ready for download: broadgpp-brunello-library-contents.txt
wget https://media.addgene.org/cms/filer_public/8b/4c/8b4c89d9-eac1-44b2-bb2f-8fea95672705/broadgpp-brunello-library-contents.txt

## note since AddGene had this file in dos, ^M is the line break so need to replace with unix line break 
## In sed the ^M should not be literally written but typing ctrl+v followed by ctrl+M will generate the dos line break character
sed -e 's/^M/\n/g' broadgpp-brunello-library-contents.txt > broadgpp-brunello-library-contents_unix.txt

## NOTE: there's something funky going on with finding/filtering out the non-targeting controls and I can't figure it out
## remove non-targeting controls since they follow different format than file column names
grep -v "Non-Targeting Control" broadgpp-brunello-library-contents_unix.txt > human_crispr_knockout_pooled_library_brunello_from_addgene.txt

## extract just the non-targeting controls to add to the fasta file
grep "Non-Targeting Control" broadgpp-brunello-library-contents_unix.txt > human_crispr_knockout_pooled_library_brunello_from_addgene_non_targeting_controls_only.txt 



cd ..
## generate CRISPR sgRNA target fasta
tail -n+2 int/human_crispr_knockout_pooled_library_brunello_from_addgene.txt | awk -F"\t" '{print ">"$2"_"$7"_"$6"_exon"$10"\n"$7}' > human_crispr_knockout_pooled_library_brunello.fasta

## add the non-targeting control sequences
sed -i 's/Non-Targeting Control/NonTargetingControl/g' int/human_crispr_knockout_pooled_library_brunello_from_addgene_non_targeting_controls_only.txt
awk -F"\t" '{print ">"$2"_"$7"\n"$7}' int/human_crispr_knockout_pooled_library_brunello_from_addgene_non_targeting_controls_only.txt >> human_crispr_knockout_pooled_library_brunello.fasta


