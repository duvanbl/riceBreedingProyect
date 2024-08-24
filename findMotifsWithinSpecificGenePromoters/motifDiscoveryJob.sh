#Save the name assuming that the file containing the promoters of interest is called +typeOf+List.txt, where +typeOf+ is the name with which you want to sort
type=$(basename "$1" List.txt)

#Save the number of promoters used as control (May vary according to the number of total promoters and machine memory)
promControl="$2"

#Create folder to contain results
mkdir results

#Cicle for each FASTA file with promoter regions
for k in *.fa; do

	#Keep cultivar name
	name=$(basename "$k" .fa)

	#Convert the FASTA file into a separate file per line for the promoter information in one file and the entire DNA sequence in the next
	sed ':a;N;/^>/M!s/\n//;ta;P;D' < $k > ${name}1.fa

	#Create FASTA with control promoters
	grep '>' Nipponbare.fa | cut -f 1,2 -d "_" | sed s/'>'/''/ | shuf -n ${promControl} > promControlNames.txt
	grep -f promControlNames.txt -A 1 ${name}1.fa | grep '\-\-' -v > ${name}PromotersControl.fa
	rm promControlNames.txt

	#Filter only promoters of interest
	grep -f $1 -A 1 ${name}1.fa | grep '\-\-' -v > ${name}Promoters${type}.fa

	#Run XSTREME tool
	###NOTE 1: Change the first part by the path where the XSTREME executable is located (previously downloaded +.../meme/bin/xstreme+)
	###NOTE 2: On flag --m use the paths where databases are located in MEME format
	/home/duvanbonilla/meme/bin/xstreme --oc ./results/${type}/${name}/ --dna \
	--evt 0.05 --minw 4 --maxw 16 --meme-mod anr --fimo-skip \
	--m Databases/ArabidopsisDAPv1.meme \
	--m Databases/Oryza_sativa.meme \
	--m Databases/TFBSshape_UniPROBE.meme \
	--m Databases/TFBSshape_JASPAR.meme --p ${name}Promoters${type}.fa -n ${name}PromotersControl.fa

	#The argument is a text file with the promoters, separated by line, in which you want to search for motifs
done < $1

#Send temp files to other folder
mkdir subFASTAs
mv *1.fa *${type}.fa *PromotersControl.fa subFASTAs/
