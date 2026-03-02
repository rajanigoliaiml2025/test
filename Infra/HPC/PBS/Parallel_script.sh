for i in {1..5}

do 
(

echo '#PBS -l walltime=01:00:00'
echo '#PBS -l nodes=1:ppn=1'
echo '#PBS -A PAS1532'
echo 'cd $PBS_O_WORKDIR'
echo '  ./bowtie2/bowtie2 -x ref/lambda_virus -U reads_'{i}'.fq -S out_'{i}'.sam'
) > alignment_job{i}.sh

qsub alignment_job{i}.sh

done