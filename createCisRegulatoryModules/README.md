# 3) Evaluating cis-Regulatory Modules
## Create codification for motif instances
Use `createModules.R` to create cis Regulatory Modules (CRMs) based on motif instances within the promoter regions, where the input is the directory containing all results of the FIMO software (previously obtained by running `findMotifInstancesJob.sh`) and the motifs used in the search for instances (*superCombined.meme* obtained from the `alignMotifsJob.sh` script).

**Note:** While running `createModules.R`, you should change the paths of the input and output locations (see the comments within for specific details).

Once that you can codify the motifs instances, a new FASTA will be generated with the promoters represented as pseaudoalphabets of the motifs instances founded, here two strategies can be followed to analyze the modules: 

### 1) Block module frequency count
In the same script `createModules.R` you can create blocks between 2 and 7 neighboring motifs and evaluate their frequency among varieties and against a control of random promoters to highlight blocks of modules that could be present only under certain conditions.

### 2) Pseudoalphabet align
Use `moduleAlignFinal.sh` to align the pseudoaphabets product of the codification of motifs performed in the previous steps. This script use MsAlign2.0 in the FASTA with the modifications, the binarie can be downloaded [here](http://www.atgc-montpellier.fr/ms_align/usersguide.php). Also, is neccesary to have a triangular matrix which represents the mutation ratio against the motifs and the list of gene promoters to evaluate. On linux terminal use:

```
./moduleAlignFinal.sh HSRList.txt codificationMotifsHSR.fa HSRTriangularMatrix.tsv Moroberekan
```

The first argument is the list of gene promoters (*HSRList.txt* for this case), the second one is the FASTA with the codifications, the third one is the triangular matrix (also obtained from the `createModules.R` script) and finally the fourth one is the string with the variety in which we want to perform the alignment (all varieties will be aligned to this one).
