#Verify if the argument is present
if [ "$#" -ne 1 ]; then
    echo "Error: One argument required. Usage: ./PromoterFinder.sh <genomeCoordinates.txt>"
    exit 1
fi

#Iterate for all the varieties, keep information of the gene promoter and create the sequence based on the variants reported
for k in *.vcf.gz; do
	j=$(echo "$k"| cut -f 1 -d '.')
	rm fail_$j.txt
	rm $j.fa
	rm fail2_$j.txt
	tabix $k
	echo "$j"
	while read p; do
		rm tmpseq.fa
		rm tmpseq_rev.fa
		COORD=$(echo "$p" |cut -f 1)
		echo $COORD
		NAME="${j}_$(echo "$p" |cut -f 3)"
		echo $NAME
		STRAND=$(echo "$p" |cut -f 2)
		echo $STRAND
		###Note 1: If u are working with a different assembly u should change here +Osativa_204_v7.0.fa+
		samtools faidx Osativa_204_v7.0.fa "$COORD" | vcf-consensus "$k" | sed "s/>/>$NAME /" >tmpseq.fa
		if [ -f tmpseq.fa ]
		then
			LINES=$(cat tmpseq.fa | wc -l)
			echo $LINES
			if [ $LINES -gt 1 ]
			then
				if [ $STRAND == '-' ]
				then
					revseq -sequence tmpseq.fa -outseq tmpseq_rev.fa -reverse T -complement T
					cat tmpseq_rev.fa >>"$j.fa"
				else
					cat tmpseq.fa >>"$j.fa"
				fi
			else
				echo "$p" >> fail_$j.txt
			fi
		fi
	done < "$1"
#Read fails, change coordinates +/- 50 and run again
	while read h; do
		COORD=$(echo "$h" | cut -f 1)
		STRAND=$(echo "$h" | cut -f 2)
		NAME="${j}_$(echo "$h" | cut -f 3)"
		CHROMOSOME=$(echo "$COORD" | cut -f 1 -d ':')
		NUMBERS=$(echo "$COORD" | cut -f 2 -d ':')
		START=$(echo "$NUMBERS" | cut -f 1 -d '-')
		END=$(echo "$NUMBERS" | cut -f 2 -d '-')
		newStart=$((START - 50))
		newEnd=$((END + 50))
		newCoord=$(echo "${CHROMOSOME}:${newStart}-${newEnd}")
		echo "La nueva coordenada: $newCoord"
		samtools faidx Osativa_204_v7.0.fa "$newCoord" | vcf-consensus "$k" | sed "s/>/>$NAME /" >tmpseq.fa
		if [ -f tmpseq.fa ]
		then
        		LINES=$(cat tmpseq.fa | wc -l)
        		echo $LINES
        		if [ $LINES -gt 1 ]
        		then
                		if [ $STRAND == '-' ]
                		then
                    			revseq -sequence tmpseq.fa -outseq tmpseq_rev.fa -reverse T -complement T
                        		cat tmpseq_rev.fa >>"$j.fa"
                		else
                        		cat tmpseq.fa >>"$j.fa"
                		fi
        		else
                		echo "$h" >> fail2_$j.txt
        		fi
		fi
	done < fail_$j.txt
done
