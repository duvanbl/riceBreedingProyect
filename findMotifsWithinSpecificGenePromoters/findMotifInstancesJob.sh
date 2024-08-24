#FIMO finding threshold
thresh=0.0001

#Create folder with the results
mkdir fimoFinding

#Iterate for each FASTA with the promoter sequences
for i in *.fa; do
	echo "$i"

	#Run FIMO
	###NOTE 1: Change the first part by the path where the XSTREME executable is located (previously downloaded +.../meme/bin/xstreme+)
	/home/duvanbonilla/meme/bin/fimo -oc fimoFinding/$i --verbosity 1 --thresh $thresh superCombined.meme $i
done
