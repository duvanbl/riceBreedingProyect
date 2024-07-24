# 1) Extracting gene promoter regions in FASTA file
## Using complete genomes
Use extractPromoterRegions.R (Parameters: Assembly genome in FASTA format and GFF3 file with annotation), this script use GenomicRanges library to create a 
FASTA file with the promoter sequences, the range of these sequences can be determined by the user. For Nipponbare rice reference both parameters are available 
[here](https://data.jgi.doe.gov/refine-download/phytozome?organism=Osativa&expanded=323), but you can use this script with any variety as long as you have the 
assembly and genome annotation. This script can also create a random promoters files to be used as a control in subsequent processes.
## Using variants against reference genome 
