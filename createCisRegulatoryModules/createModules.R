#Number of gene promoters studied
PROMOTERS <- 1710

#Module creation from FIMO results
library(stringr)
library(dplyr)

##Motif codification
###Note 1: Specify in the complete path to the motifs file with all the motifs in MEME format
motifsFile <- readLines("/run/user/1000/gvfs/sftp:host=hypatia.uniandes.edu.co///hpcfs/home/ing_sistemas/d.bonillal/newRiceProyect/superResults/HSR/allMotifs/promotersHSR/superCombined.meme")
motifsLines <- grep("MOTIF", motifsFile, value = TRUE, ignore.case = TRUE)
motifs <- sapply(strsplit(motifsLines, "MOTIF"), function(x) trimws(x[2]))
motifs <- motifs[!is.na(motifs)]
motifs <- str_split_fixed(motifs,pattern = " ",n=2)[,1]
numbers <- as.character(c(0:9))
characters <- c("!", "@", "#", "$", "%", "&", "*", "(", ")", "_",
                "+", "=", "{", "}", "[", "]", ":", ";", ".", "<", 
                "?", "/")
codes <- c(LETTERS, letters, numbers, characters)
numberMotifs <- length(motifs)
codes <- codes[1:numberMotifs]
dict <- setNames(codes, motifs)
print(dict)
print(motifs)

#Export FIMO results for each variety
###Note 2: Specify the complete path to the results directory product of run FIMO to
###find motifs instances in all the varieties (findMotifInstancesJob.sh)
Varieties <- list.dirs("/run/user/1000/gvfs/sftp:host=hypatia.uniandes.edu.co////hpcfs/home/ing_sistemas/d.bonillal/newRiceProyect/superResults/completeGenomes/FADRonBoth/allMotifs/promotersFADRonBoth/fimoFinding",recursive = F)
#Varieties <- list.dirs("/home/duvanbonilla/Documents/newRiceProject/modules/FIMOresultsForR/FADR/fimoFinding", recursive = F)
varieties <- NULL
for (i in Varieties){
  setwd(i)
  variety <- basename(i)
  ###Note 3: Specify the suffix of all the FASTA files with the promoters of interest 
  name <- gsub("\\PromotersFADRonBoth.fa","",variety)  
  tsvFile <- read.delim("fimo.tsv",comment.char = "#") 
  if (grepl("Nipponbare",name)){
    tsvFile$sequence_name <- paste(str_split_fixed(tsvFile$sequence_name, pattern = "_",n=4)[,1],
                                   str_split_fixed(tsvFile$sequence_name, pattern = "_",n=4)[,2],sep = "_")
    tsvFile$sequence_name <- paste("Nipponbare",tsvFile$sequence_name, sep = "_")
  }
  if (grepl("controlNip",name)){
    tsvFile$sequence_name <- paste(str_split_fixed(tsvFile$sequence_name, pattern = "_",n=4)[,1],
                                   str_split_fixed(tsvFile$sequence_name, pattern = "_",n=4)[,2],sep = "_")
    tsvFile$sequence_name <- paste("controlNip",tsvFile$sequence_name, sep = "_")
  }
  tsvFile$sequence_name[(grepl("^LOC",tsvFile$sequence_name))]<-paste(name,tsvFile$sequence_name[(grepl("^LOC",tsvFile$sequence_name))], sep = "_")
  assign(x = name, tsvFile)
  varieties <- c(varieties,name)
  remove(tsvFile)
}
#assign(x= "controlNip",controlNipPromoters.fa)

#Codification for each variety
codesList <- NULL
for (j in varieties){
  variety <- get(j)
  promoters <- unique(variety$sequence_name)
  for (k in promoters){
    codification <- ""
    parcial <- variety[variety$sequence_name == k,]
    parcial <- parcial[order(parcial$start),]
    if (nrow(parcial) > 1){
      for (h in 1:(nrow(parcial)-1)){
        if ((parcial$motif_id[h] == parcial$motif_id[h+1]) && (parcial$start[h]+2 >= parcial$start[h+1])){}
        else {
          value <- dict[parcial$motif_id[h]]
          codification <- paste(codification, value, sep = "")
        }
      }
    }
    value <- dict[parcial$motif_id[nrow(parcial)]]
    codification <- paste(codification, value, sep = "")
    print(codification)
    codesList <- rbind(codesList, c(k, codification))
  }
}

#Create module frequencies
###Note 3: Change the next line for the complete path where you want to keep the
###frequencies for each module among the varieties
setwd("/home/duvanbonilla/Documents/riceProyect/fullModuleCreation/completeGenomes/FADRonBoth/")
onlyVarieties <- unique(str_split_fixed(codesList[,1], pattern = "_", n=3)[,1])
for (z in onlyVarieties){
  vcodesList <- codesList[grepl(z,codesList[,1]),]
  freqDf <- NULL
  freqDf <- data.frame(matrix(ncol = 4, nrow = 0))
  colnames(freqDf) <- c("Variety","Module","Frequency","NoFreq")
  for (a in 2:7){
    for (b in 1:nrow(vcodesList)){
      promoter <- vcodesList[b,1]
      code <- vcodesList[b,2]
      actualVar <- str_split_fixed(promoter, pattern = "_",n=3)[,1]
      for (c in 1:(nchar(code)-a+1)){
        word <- substring(code,c,(c+a-1))
        freqDf$Frequency[freqDf$Module==word] <- freqDf$Frequency[freqDf$Module==word] + 1
        print(word)
        if(!any(freqDf$Module==word)){
          newRow <- data.frame(Variety = actualVar, Module = word, Frequency = 1, NoFreq = 0)
          freqDf <- rbind(freqDf, newRow)
        }
      }
    }
  }
  assign(paste(z,"Frequencies",sep = ""), freqDf)
  write.csv(freqDf, paste(z,"Frequencies",".csv", sep = ""), col.names = T)
}
freqDf <- NULL
freqDf <- do.call("rbind",mget(ls(pattern = "Frequencies")))


#Statistics to find meaningful CRM
controlFreqDf <- freqDf[freqDf$Variety == "controlNip",]
newFreq <- left_join(freqDf,controlFreqDf,by = c("Module" = "Module"))
newFreq[is.na(newFreq)] <- 0
newFreq <- subset(newFreq, select = -Variety.y)
colnames(newFreq) <- c("Variety","Module","Frequency","NoFreq","FreqControl",
                        "NoFreqC")
for (r in 1:nrow(newFreq)){
  actualVar <- newFreq[r,1]
  instancesControlNip <- nrow(controlNip) - nchar(newFreq[r,2]) + 1 - PROMOTERS
  instancesActualVar <- nrow(get(actualVar)) - nchar(newFreq[r,2]) + 1 - PROMOTERS
  newFreq[r,4] <- instancesActualVar - newFreq[r,3] 
  newFreq[r,6] <- instancesControlNip - newFreq[r,5]
  contingencyTable <- matrix(c(newFreq[r,3],newFreq[r,4],
      newFreq[r,5],newFreq[r,6]),nrow = 2,)
  fisherResult <- fisher.test(contingencyTable, alternative = "greater")
  p_value <- fisherResult$p.value
  newFreq$pValue[r] <- p_value
}
newFreq$pAdjust <- p.adjust(newFreq$pValue,method = "bonferroni")
###Note 4: Rename here your file with all the modules frequencies
write.csv(newFreq, "completeModuleBlocksFADRonBoth.csv", col.names = T)

#Create FASTA with the coded modules to align later
FASTAfile <- NULL
forFAcodesList <- codesList[!grepl("controlNip", codesList[,1]),]
for (l in 1:nrow(forFAcodesList)){
  name <- paste(">",forFAcodesList[l,1], sep = "")
  code <- forFAcodesList[l,2]
  FASTAfile <- rbind(FASTAfile, name)
  FASTAfile <- rbind(FASTAfile, code)
}
###Note 5: Specify the path and name of your FASTA file to create it
setwd("/home/duvanbonilla/Documents/riceProyect/fullModuleCreation/completeGenomes/HSRonBoth/")
write.table(FASTAfile, "codificationMotifsFADRonBoth.fa", col.names = FALSE, quote = FALSE, row.names = FALSE)

#Create triangular matrix (Input for MsAlign2.0)
###Note 6: Specify the path and name of your matrix file to create it
setwd("/home/duvanbonilla/Documents/riceProyect/fullModuleCreation/completeGenomes/HSRonBoth/")
scoreList <- list()
numberCodes <- length(codes)
for (y in 1:length(codes)){
  symbol <- codes[y]
  scoreList[[symbol]] <- paste(c(rep(1, y-1), 0), sep = "\t")
}
###Note 6
write(as.character(numberCodes), "FADRonBothTriangularMatrix.tsv", append = FALSE)  
for (z in names(scoreList)){
  ###Note 6
  write(z, "FADRonBothTriangularMatrix.tsv", append = TRUE)  
  write(paste(scoreList[[z]], collapse = "\t"), "FADRonBothTriangularMatrix.tsv", append = TRUE) 
}

#Create motifs dictionary (important to track your motifs in the codifications)
##Note 7: Specify the path and name of your TXT dictionary to create it
setwd("/home/duvanbonilla/Documents/riceProyect/fullModuleCreation/completeGenomes/FADRonBoth/")
dictMotifs <- NULL
for (z in 1:length(dict)){
  ###Note 7
  write(dict[z], "dictionaryMotifsFADRonBoth.txt", append = TRUE)
  write(names(dict[z]), "dictionaryMotifsFADRonBoth.txt", append = TRUE)
}

