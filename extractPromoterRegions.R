#Librerías necesarias
library("stringr")
library("rtracklayer")
library("GenomicRanges")
library("Biostrings")
library("BSgenome")
library("dplyr")
#Distancia del promotor
promoterDistance <- 2000
#Cargar assembly (.fa) y anotación del genoma (.gff3) 
Osgff <- import.gff("/home/duvanbonilla/Documents/riceProyect/genomeData/workFiles/Osativa_204_v7.0.gene_exons.gff3")
Osfa <- readDNAStringSet("/home/duvanbonilla/Documents/riceProyect/genomeData/workFiles/Osativa_204_v7.0.fa")
#Generar un data frame con los archivos cargados
Osseqs <- getSeq(Osfa, Osgff)
O1 <- as.data.frame(Osgff)
#Filtrar por secuencias codificantes (CDS) 
O1CDS <- O1[O1$type=="CDS",]
#Toma la informacion del gen dividiendo la columna Parent por punto, en dos y tomando la primera
O1CDS$gene <- str_split_fixed(O1CDS$Parent,"\\.",2)[,1]
#Filtrar los genes que estan en cromosomas definidos
O2CDS <- O1CDS[grep("LOC",O1CDS$gene),]
duplicated(O2CDS$gene)
O3CDS <- O2CDS[!duplicated(O2CDS$gene),]
#Nuevos objetos para los promotores de genes en cadenas positivas y negativa
O3CDSplus <- O3CDS[O3CDS$strand=="+",]
O3CDSminus <- O3CDS[O3CDS$strand=="-",]
#Definición del rango del promotor cuando el gen está en la cadena positiva
O3CDSplus$newStart <- O3CDSplus$start - promoterDistance
O3CDSplus$newEnd <- O3CDSplus$start - 1
#Definición del rango del promotor cuando el gen está en la cadena negativa
O3CDSminus$newStart <- O3CDSminus$end + 1
O3CDSminus$newEnd <- O3CDSminus$end + promoterDistance
#Fusiona los objetos anteriores
O4CDS <- rbind(O3CDSplus,O3CDSminus)
#Las siguientes 5 líneas se utilizan para corregir promotores que se extiendan más allá del límite del fasta
chrLenghts <- as.data.frame(seqlengths(Osfa))
chrLenghts$seqnames <- row.names(chrLenghts)
O5CDS <- left_join(O4CDS,chrLenghts) 
O5CDS$newEnd[O5CDS$newEnd>O5CDS$`seqlengths(Osfa)`]
O5CDS$newEnd[O5CDS$newEnd>O5CDS$`seqlengths(Osfa)`] <- O5CDS$`seqlengths(Osfa)`[O5CDS$newEnd>O5CDS$`seqlengths(Osfa)`]
#Objeto Genomic Ranges con la información y ubicación de los promotores
gRange <- GRanges(seqnames=O5CDS$seqnames,strand=O5CDS$strand,IRanges(start=O5CDS$newStart,end=O5CDS$newEnd),name=O5CDS$gene)
gRange
#Genera objeto con las secuencias de los promotores según las nuevas ubicaciones
Osprom <- getSeq(Osfa, gRange)
Osprom
#Genera encabezado para cada ṕromotor
names(Osprom) <- paste(gRange$name,"_",seqnames(gRange),":",start(gRange),"-",end(gRange),"_",strand(gRange),sep = "") 
#Genera archivo 
writeXStringSet(Osprom,"promoterRegionsR.fa")
#Tomar muestra aleatoria de promotores 
randomNames <- sample(names(Osprom),size = 1000,replace = F)
Osprom[randomNames]
writeXStringSet(Osprom[randomNames],"controlPromoterRegionsR2K.fa")
#Aun no puedo hacer el aleatorio :( )
ThermoGeneList <- read.csv("/home/duvanbonilla/Documents/riceProyect/genomeData/workFiles/thermotoleranceGenes.csv")
RandomThermoNames <- sample(ThermoGeneList,size = 1000, replace = F)
ThermoGeneList[4,]
