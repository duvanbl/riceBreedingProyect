#Create folders to track repeated and unique motifs
mkdir repeatedMotifs
mkdir addedMotifs

#TOMTOM alignment threshold
thresh=0.05

#Counter to know the number of files with XSTREME motifs for each strain
c=0
for k in *.txt; do

#If the counter is equal to 1, it does nothing, it just creates superCombined.meme, if it is not equal to one, it makes the partitions and compares with TOMTOM
	c=$c+1
	if [[ $c -eq 1 ]]; then
		cat $k > "superCombined.txt"
	else

		#Read the file line by line
		echo $k
		filename=$(echo "Empty")
		while read line; do

			#Keep line with MEME version (Required for MEME format)
			if [[ $line == *version* ]]; then
				version=$(echo "$line")
			fi

			#Verify if the line starts with +MOTIF+
    			if [[ $line == MOTIF* ]]; then
				d=$d+1

				#Extracts the name of the subfile from the line after MOTIF, which should be the consensus sequence
        			filename=$(echo "$line" | awk '{print $2}')

				#Initializes a variable to store the contents of the subfile
        			content="MOTIF $filename"
				echo -e "$content" > "${filename}.meme"

				#If the found line does not begin with MOTIF, add its contents to the subfile
    			else
       				content="$line"
       				echo -e "$content" >> "${filename}.meme"
     			fi
		done < $k
	mkdir results

	#Cycle to go through each of the subfiles with the motifs and compare with TOMTOM if it is already in superCombined.meme or needs to be added.
	rm Empty.meme
	ls *.meme
	for j in *.meme; do
		echo $j

		#Include in a new file the MEME version to be read as a MEME file
		sed "1i\\$version\n" $j > 1$j

		#Run TOMTOM
		###NOTE 1: Change the first part by the path where the XSTREME executable is located (previously downloaded +.../meme/bin/xstreme+)
		/home/duvanbonilla/meme/bin/tomtom -oc results/$j -no-ssc -verbosity 1 -evalue -thresh $thresh -dist pearson -min-overlap 4 1$j superCombined.txt
		rm 1$j

		#Extracts the number of lines in the TOMTOM result and compare them to know if any match exists
		tomtomLines=$(cut -f 1 results/$j/tomtom.tsv | sort | uniq | wc -l)
		echo $tomtomLines
		if [[ $tomtomLines -gt 5 ]]; then
			mv $j repeatedMotifs/$j
			echo $j." is repeated"
		else
			cat $j >> superCombined.txt
			mv $j addedMotifs/$j
			echo $j." is new"
		fi
	done
		ls *.meme
	fi
done
mv superCombined.txt superCombined.meme
mv results TOMTOMaligns
