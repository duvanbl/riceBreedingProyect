#Libraries
library("stringr")
library("rtracklayer")
library("GenomicRanges")
library("Biostrings")
library("BSgenome")
library("dplyr")

#Promoter distance
promoterDistance <- 2000

#Load genome assembly (.fa) and annotation (.gff3) 
#(Replace pathways with those of your genome)
Osgff <- import.gff("/home/duvanbonilla/Documents/riceProyect/genomeData/workFiles/Osativa_204_v7.0.gene_exons.gff3")
Osfa <- readDNAStringSet("/home/duvanbonilla/Documents/riceProyect/genomeData/workFiles/Osativa_204_v7.0.fa")

#Generate data frame
Osseqs <- getSeq(Osfa, Osgff)
O1 <- as.data.frame(Osgff)

#Filtering by coding sequences (CDS)
O1CDS <- O1[O1$type=="CDS",]

#Take the gene information by dividing the Parent column by dot (.) in two and taking the first one
O1CDS$gene <- str_split_fixed(O1CDS$Parent,"\\.",2)[,1]

#Filtering out genes that are on defined chromosomes
O2CDS <- O1CDS[grep("LOC",O1CDS$gene),]
duplicated(O2CDS$gene)
O3CDS <- O2CDS[!duplicated(O2CDS$gene),]

#New targets for gene promoters in positive and negative stranded genes
O3CDSplus <- O3CDS[O3CDS$strand=="+",]
O3CDSminus <- O3CDS[O3CDS$strand=="-",]

#Promoter range when the gene is on the positive strand
O3CDSplus$newStart <- O3CDSplus$start - promoterDistance
O3CDSplus$newEnd <- O3CDSplus$start - 1

#Promoter range when the gene is on the negative strand
O3CDSminus$newStart <- O3CDSminus$end + 1
O3CDSminus$newEnd <- O3CDSminus$end + promoterDistance

#Merge the previous objects
O4CDS <- rbind(O3CDSplus,O3CDSminus)

#Correct promoters that extend beyond the FASTA limit
chrLenghts <- as.data.frame(seqlengths(Osfa))
chrLenghts$seqnames <- row.names(chrLenghts)
O5CDS <- left_join(O4CDS,chrLenghts) 
O5CDS$newEnd[O5CDS$newEnd>O5CDS$`seqlengths(Osfa)`]
O5CDS$newEnd[O5CDS$newEnd>O5CDS$`seqlengths(Osfa)`] <- O5CDS$`seqlengths(Osfa)`[O5CDS$newEnd>O5CDS$`seqlengths(Osfa)`]

#Creation of the GenomicRanges object with the information and location of the promoters
gRange <- GRanges(seqnames=O5CDS$seqnames,strand=O5CDS$strand,IRanges(start=O5CDS$newStart,end=O5CDS$newEnd),name=O5CDS$gene)
gRange

#Generates object with the sequences of the promoters according to the new locations
Osprom <- getSeq(Osfa, gRange)
Osprom

#Generates headers for each promoter
names(Osprom) <- paste(gRange$name,"_",seqnames(gRange),":",start(gRange),"-",end(gRange),"_",strand(gRange),sep = "") 

#Generate new FASTA file with promoter regions
writeXStringSet(Osprom,"promoterRegionsR2000.fa")

###Optional
#Take a random sample of promoters 
randomNames <- sample(names(Osprom),size = 385,replace = F)
Osprom[randomNames]
writeXStringSet(Osprom[randomNames],"controlPromoterRegionsR2K385.fa")

#Generates i number of promoter controls
for (i in 1:10) {
randomNames <- sample(names(Osprom),size = 1000,replace = F)
Osprom[randomNames]
writeXStringSet(Osprom[randomNames],paste("Control2K",i,".fa",sep = ""))}
