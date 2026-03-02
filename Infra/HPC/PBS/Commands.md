1. HPC PBS Commands
 
  #PBS -l walltime=01:00:00
  #PBS -l nodes=1:ppn=1
  #PBS -A PAS1532

  cd $PBS_O_WORKDIR
  ./bowtie2/bowtie2 -x ref/lambda_virus -U reads_1.fq -S out_1.sam
