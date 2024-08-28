# 2) Discovering and analazing DNA motifs 
## Find motifs
Use `motifDiscoveryJob.sh` to find motifs in DNA sequences (in this case in specific gene promoter sequences from different rice varieties), this script should be run in the same folder that contains all the FASTA files with the sequences to be analyzed. The motifs are discovered by running [XSTREME](https://meme-suite.org/meme/tools/xstreme), a tool from the MEME suite that performs motif discovery and enrichment analysis using known databases of transcription factor binding sites (TFBS). The databases are available [here](https://meme-suite.org/meme/db/motifs), and the latest version of MEME should be downloaded [here](https://meme-suite.org/meme/doc/download.html).
On Linux terminal use:
```
./motifDiscoveryJob.sh FADRList.txt 162
```
Two parameters are required: The first one is a TXT file with the specific sequences within the FASTA files in whitch motifs would be discovered, this file should end with *List.txt* (FADRList.txt for this case). The second one is the number of aleatory sequences within the FASTA used as control, use the same number of imput seqwuences or all sequences deppending on the resources (162 promoters for this case). 

**Note:** Before running `motifDiscoveryJob.sh`, it should be modified to change the path to the MEME Suite binary and the associated databases (see the comments within for specific details).

## Analyze motifs 
Simple scripts can be used to extract information from the XSTREME results: For example, `getMotifOutputs.sh` extracts the TXT files with the positional weight matrices (a quantitative representation of the motifs) found in all varieties, which will be used in future analyses; also, `countMotifs.sh` prints the number of motifs found for each variety.

Other scripts present in this section can be useful comparing and searching the motifs obtained in the promoter sequences:
### 1) Align motifs
Use `alignMotifsJob.sh` to compare all the motifs founded in different varieties. First you should run `getMotifOutputs.sh` and inside the directory with all the TXT you should run this binary that uses TOMTOM alignment to create a list with the consensous motifs that represent the core motifs present for several varieties in MEME format and it's called *superCombined.meme*. Also, two directories are created to keep track of the motifs that are repeated between varieties and those that are unique and present in the final list.  

To evaluate for each variety motif pair the number of motifs that are shared between them use `motifPairwiseComparisonJob.sh`, this script implements TOMTOM to know if two motifs from different varieties are the same. FInally a TXT called *summaryMotifsPairwiseAlignment.csv* is created with all the information of the alignments that can be easily ploted.

**Note:** Before running these two scripts, they should be modified to change the path to the MEME Suite binary (see the comments within for specific details).

### 2) Search motif instances
Use `findMotifInstancesJob.sh` to find each motif instance present in the promoter sequences or any DNA sequences. This script should be run in the same directory as the motifs in MEME format (the file *superCombined.meme* can also be used) and the sequences in which the motifs are to be found, these sequences should be in FASTA format. If you want to create cis-regulatory modules, it is recommended that you also search for motifs in control promoter sequences in this part for further analysis.

**Note:** Before running `findMotifInstancesJob.sh`, it should be modified to change the path to the MEME Suite binary (see the comments within for specific details).
