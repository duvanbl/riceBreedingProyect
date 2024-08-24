mkdir allMotifs
for i in *; do
	if [ -d $i ]; then
		cp $i/xstreme.txt allMotifs/$i.txt 
	fi
done
