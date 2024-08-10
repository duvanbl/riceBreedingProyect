# 1) Extracting gene promoter regions in FASTA file
## Based on complete genomes
Use extractPromoterRegions.R (Parameters: Genome assembly in FASTA format and GFF3 file with annotation), this script use GenomicRanges library to create a FASTA file with the promoter sequences, the range of these sequences can be determined by the user. For Nipponbare rice reference both parameters are available [here](https://data.jgi.doe.gov/refine-download/phytozome?organism=Osativa&expanded=323), but you can use this script with any variety as long as you have the assembly and genome annotation properly tabulated. This script can also create a random promoters files to be used as a control in subsequent processes.
## Based on variants against reference genome 
Run PromoterFinder.sh (Parameters: File with the promoter coordinates in the genome (for more details the file genomePromoterCoordinates2k.txt can be downloaded and used)) in a directory that contains the compressed VCF files of each rice variety (as an example the file Moroberekan.vcf.gz can be tested), this script will use VCFconsensous and Samtools to obtain the promoter sequences in the specific regions used as imput.
On Linux terminal use:
```
./PromoterFinder genomePromoterCoordinates2k.txt
```
The same directory should also contain the genome assembly of the VCFs based reference in FASTA format (in this case Nipponbare, previously downloaded).
