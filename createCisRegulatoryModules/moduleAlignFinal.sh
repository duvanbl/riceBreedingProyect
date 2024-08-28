#!/bin/bash

# ###### Zona de Parámetros de solicitud de recursos a SLURM ############################
#
#SBATCH --job-name=moduleAlignJob	#Nombre del job
#SBATCH -p medium			#Cola a usar, Default=short (Ver colas y límites en /hpcfs/shared/README/partitions.txt)
#SBATCH -N 1				#Nodos requeridos, Default=1
#SBATCH -n 1				#Tasks paralelos, recomendado para MPI, Default=1
#SBATCH --cpus-per-task=4		#Cores requeridos por task, recomendado para multi-thread, Default=1
#SBATCH --mem=50G			#Memoria en Mb por CPU, Default=2048
#SBATCH --time=3-00:00:00			#Tiempo máximo de corrida, Default=2 horas
#SBATCH --mail-user=d.bonillal@uniandes.edu.co
#SBATCH --mail-type=ALL			
#SBATCH -o moduleAlignJOB.o%j			#Nombre de archivo de salida
#
########################################################################################

# ################## Zona Carga de Módulos ############################################

########################################################################################


# ###### Zona de Ejecución de código y comandos a ejecutar secuencialmente #############
mkdir alignResults$4
c=1
while read h; do
	grep -A 1 $h $2 | grep '\-\-' -v > codesOnlyGenes.fa
	./msalignv2-linux64 codesOnlyGenes.fa $3 1 1 20 20 -o alignResults$4/try${h} -d
	if [[ $c -eq 1 ]]; then
		grep 'LOC' alignResults$4/try${h} | tr '\n' '\t' >> alignResults$4/only$4Align.txt
		echo $'\n' >> alignResults$4/only$4Align.txt 
	fi
	grep -A 1 $4 alignResults$4/try${h} | grep '\-\-' -v | tr '\n' '\t' >> alignResults$4/only$4Align.txt 
	echo $'\n' >> alignResults$4/only$4Align.txt
	c=$c+1
done < $1
mv codesOnlyGenes.fa alignResults$4
########################################################################################


