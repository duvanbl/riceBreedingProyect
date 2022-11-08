# riceBreedingProyect (Finding cisRegulatory Modules in regulatory gene sequences)
## 1) Extracting gene promoter regions in fasta file
(Parameters: Assembly genome in fasta and gff3 file with annotation; by deafult, both parameters are available for rice genome on data/)

## 2) Finding the known broad spectrum defense response (BSDR) genes list
Obtained as a list (Table S9) in the [supplementary material of Tonensen *et al.*](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6367480/). 
## 3) Obtaining the BSDR gene promoter region 
On Linux terminal for filter the promoter regions of interest use:
```
grep ':a;N;/^>/M!s/\n//;ta;P;D' < annotatedPromoters.fa > annotatedPromoters1.fa
grep -f 'BSDRGlist.txt' -A 1 annotatedPromoters1.fa | grep '\-\-' -v > BSDRPromoters.fa
```
When BSDRGlist.txt is the text file with the IDs of the genes of interest enter separated.
## 4) Finding motifs in the BSDR genes promoter regions
The motifs associated to the imput sequences (BSDRPromoters.fa in this case) was obtained running [XSTREME](https://meme-suite.org/meme/tools/xstreme), a tool from MEME Suite who performs motif discovery and motif enrichment analysis with known databases of transcriptional factors binding sites (TFBS). If XTREME is running on terminal the databases are available [here](https://meme-suite.org/meme/db/motifs), and the latest version of MEME could be download [here](https://meme-suite.org/meme/doc/download.html).  
For use XSTREME on Linux terminal with a TFBSshape database:
```
./xtreme --oc ../../Documents/riceProyect/resultsMeme/xtremeResults/ --time 240 --streme-totallength 4000000 --meme-searchsize 100000 --dna --ent 0.05 --minw 4 --maxw 15 --meme-mod anr --sea-noseqs --m ../../Documents/riceProyect/genomeData/workFiles/motif_databases.12.23/motif_databases/TFBSshape/TFBSshape_JASPAR.meme --p ../../Documents/riceProyect/genomeData/workFiles/BSDRPromoters.fa -n ../../Documents/riceProyect/genomeData/workFiles/annotatedPromoters1.fa 
```
When --m is the TFBS database to compare, --p are the imput sequences, and -n are the background sequences considered as control sequences.
## 5) Finding motif clusters from the BSDR promoters and an alphabet with defined motifs (XSTREME output)
ClusterBuster algorithm was performed to find cis regulatory modules (CRMs) on the promoter sequences, using as alphabet a list of motifs previously discovered by XSTREME tool, giving it as an output called combined.meme 
The executable is available [here](https://zlab.umassmed.edu/bu/cluster-buster/download.html), an the code on Linux terminal is:
```
./cbust ../Downloads/motifsCB.txt ../Documents/riceProyect/genomeData/workFiles/BSDRPromoters.fa > ../Downloads/resultsClusterBuster
```
