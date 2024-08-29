#Verify if the 4 arguments are present
if [ "$#" -ne 4 ]; then
    echo "Error: Four arguments required. Usage: ./moduleAlignFinalJob.sh <geneList.txt> <codifications.fa> <triangularMatrix.csv> <nameOfTheVariety>"
    exit 1
fi

#Create folder with the results
mkdir alignResults$4
c=1

#Iterate for each gene obtaining the codifications of the varieties and align them
while read h; do
	grep -A 1 $h $2 | grep '\-\-' -v > codesOnlyGenes.fa
	###Note 1: Don´t forget to have the MsAlign binary present in the same directiory 
	./msalignv2-linux64 codesOnlyGenes.fa $3 1 1 20 20 -o alignResults$4/try${h} -d

	#Modifications to create the matrix of all the varieties against one of them
	if [[ $c -eq 1 ]]; then
		grep 'LOC' alignResults$4/try${h} | tr '\n' '\t' >> alignResults$4/only$4Align.txt
		echo $'\n' >> alignResults$4/only$4Align.txt 
	fi
	grep -A 1 $4 alignResults$4/try${h} | grep '\-\-' -v | tr '\n' '\t' >> alignResults$4/only$4Align.txt 
	echo $'\n' >> alignResults$4/only$4Align.txt
	c=$c+1
done < $1
mv codesOnlyGenes.fa alignResults$4

