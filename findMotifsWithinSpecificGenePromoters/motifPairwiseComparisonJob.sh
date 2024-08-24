#TOMTOM threshold
thresh=0.05

#Create results folder
mkdir -p resultsTomtomPairwise

#Create CSV file with the information
echo "Variety1,Variety2,MotifsVar1,MotifsVar2,SharedMotifs" > summaryMotifsPairwiseAlignment.csv

#Iterate amoung file pairs with the motifs of each variety
for file1 in *.txt; do
	for file2 in *.txt; do

		#Name varieties
		Variedad1=$(basename "$file1" .txt)
		Variedad2=$(basename "$file2" .txt)

		#Motifs in file1
		motifs1=$(grep -c 'MOTIF' $file1)

		#Motifs in file2
		motifs2=$(grep -c 'MOTIF' $file2)

		#Run TOMTOM
		###NOTE 1: Change the first part by the path where the XSTREME executable is located (previously downloaded +.../meme/bin/xstreme+)
		/home/duvanbonilla/meme/bin/tomtom -oc resultsTomtomPairwise/$file1$file2 -no-ssc -verbosity 1 -evalue -thresh $thresh -dist pearson -min-overlap 4 $file1 $file2

      		#Calculate number of lines in TSV file
      		lines=$(cut -f 1 resultsTomtomPairwise/$file1$file2/tomtom.tsv | sort | uniq | wc -l)

      		#Rest 5 lines of headers and comments 
      		sharedMotifs=$((lines - 5))

    		#Add info to CSV file
      		echo "$Variedad1,$Variedad2,$motifs1,$motifs2,$sharedMotifs" >> summaryMotifsPairwiseAlignment.csv
 	done
done

#If you don´t need the information of each alignment uncomment the next line
#rm -r resultsTomtomPairwise


