#!/bin/bash


if [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ] || [ "$1" == "--h" ]   ; then
  echo "
Usage: HMMetaRibo.sh {path_to_genome}/genome.fasta {path_to_bamfile}/bam.bam {path_to_output} {path_to_HMMetaRibo_toolfolder}
"
  echo "This tool will predict all possible start and stop codons in a genome.
  "
 echo "On a gene by gene basis, this tool decides how to assign reads to maximize periodicity of the position                                                                      "
  echo "It will calculate the probability of Ribo-Seq signal enrichment at these boundaries.
  "
  echo "These probabilities will be used in a two state Hidden Markov model to predict genes.
  "
   echo "Please remove spaces from fasta headers used as input.
  "
   echo "Please sort and remove unmapped reads from bam files used as input.
  "
  echo "Run install.sh to install seqtk or replace the path to a different version
  "
  echo "Make sure to add a path to R with riboSeqR, Rsamtools, GenomicAlignments, and depmixS4
  "
  echo "Make sure the genome is indexed
"


  exit 0
fi

#Three paths are required
#load seqtk, HMMetaRibo, and R - path to R must be manually added either here or when the script is called
export PATH=$4":$PATH"
export PATH=$4'/seqtk'":$PATH"
module load r/3.3.1

#make output directory
mkdir -p $3; cd $3

#copy genomes to directory
cat $1 > forward.fasta
seqtk seq -r forward.fasta > reverse.fasta

#Run CDS predictions and HMM on both directions in parallel 
Rscript $4/HMMetaRibo.R forward.fasta $2 forward $1 &
Rscript $4/HMMetaRibo.R reverse.fasta $2 reverse $1 & 
wait

#create a file of all Ribo predicted genes and correct reverse reads to be relative to the forward
#head -n1 forward_Ribopredictedgenes.bed | awk '{print $0 "\t" "strand"}' > AllRibopredictedgenes.bed
#join -1 1 -2 1 -o 0,2.2,2.3,2.4,2.5,2.6,1.2 <(cat $1.fai | cut -f1,2 | sort -k1,1) <(sort -k1,1 reverse_Ribopredictedgenes.bed) > reverse_Ribopredictedgenes_contiglength.bed
#tail -n+2 forward_Ribopredictedgenes.bed | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" "+"}' >> AllRibopredictedgenes.bed
#cat reverse_Ribopredictedgenes_contiglength.bed | awk '{print $1 "\t" $7+1-$2 "\t" $7+1-$3 "\t" $4 "\t" $5 "\t" $6 "\t"  "-"}' >> AllRibopredictedgenes.bed


