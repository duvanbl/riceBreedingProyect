for i in *; do
	if [ -d $i ]; then
		cd $i
		echo "$i" 
		grep -c MOTIF xstreme.txt
		cd .. 
	fi
done
