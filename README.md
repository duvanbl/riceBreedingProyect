# riceBreedingProyect (Finding cisRegulatory Modules in regulatory gene sequences)
## 1) Extracting gene promoter regions in fasta file
Use extractPromoterRegions.R (Parameters: Assembly genome in fasta and gff3 file with annotation; by deafult for rice genome, both parameters are available [here](https://data.jgi.doe.gov/refine-download/phytozome?organism=Osativa&expanded=323)), this script can also create a random promoters file to be used as a control in subsequent processes.

## 2) Finding the known broad spectrum defense response (BSDR) genes list
Obtained as a list (Table S9) in the [supplementary material of Tonensen *et al.*](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6367480/). 
## 3) Obtaining the BSDR gene promoter region 
On Linux terminal, for filter the promoter regions of interest use:
```
sed ':a;N;/^>/M!s/\n//;ta;P;D' < annotatedPromoters.fa > annotatedPromoters1.fa
grep -f 'BSDRGlist.txt' -A 1 annotatedPromoters1.fa | grep '\-\-' -v > BSDRPromoters.fa
```
When BSDRGlist.txt is the text file with the IDs of the genes of interest enter separated.
Here, the first command transform each promoter sequence in the FASTA file in a single line, the second line filter the FASTA to obtain only the promoters mencioned in the .txt file 

## 4) Finding motifs in the BSDR genes promoter regions
The motifs associated to the imput sequences (BSDRPromoters.fa in this case) was obtained running [XSTREME](https://meme-suite.org/meme/tools/xstreme), a tool from MEME Suite who performs motif discovery and motif enrichment analysis with known databases of transcriptional factors binding sites (TFBS). If XTREME is running on terminal the databases are available [here](https://meme-suite.org/meme/db/motifs), and the latest version of MEME could be download [here](https://meme-suite.org/meme/doc/download.html).  
For example, to use XSTREME on Linux terminal with a TFBSshape database (UniPROBE and JASPAR databases combined), you can use the following command:
```
./xstreme --oc ../../Documents/riceProyect/results/resultsMeme/xstremeResults2.0/2k/CIS-BP2+TFBSshape+DAP/allPromotersControl/ --time 240 --streme-totallength 4000000 --meme-searchsize 100000 --dna --evt 0.05 --minw 4 --maxw 15 --meme-mod anr --sea-noseqs --m ../../Documents/riceProyect/genomeData/workFiles/databases/motif_databases.12.23/motif_databases/TFBSshape/TFBSshape_UniPROBE.meme --m ../../Documents/riceProyect/genomeData/workFiles/databases/motif_databases.12.23/motif_databases/TFBSshape/TFBSshape_JASPAR.meme  --p ../../Documents/riceProyect/genomeData/workFiles/wF2.0/BSDRPromoters2K.fa -n ../../Documents/riceProyect/Rscripts/controlPromoterRegionsR2K.fa
```
When --meme-mod is the motif distribution expected (any number of repetitions in this case), --m is the TFBS database to compare, --p are the imput sequences, and -n are the control sequences.
## 5) Finding motif clusters from the BSDR promoters and an alphabet with defined motifs (XSTREME output)
...
