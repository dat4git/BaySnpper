APPS_PATH=/bsnp/apps
# REFERENCE='/bsnp/db/gatk/hg19/ucsc.hg19.fasta' 

BAM_FILE=$1
REGION=$2
GENE=$3
GENOME=$4

#echo $BAM_FILE
#echo $REGION
#echo $GENE
#echo $GENOME

HG19='hg19'
MM10='mm10'
if   [ $GENOME == $HG19 ] 
	then REFERENCE='/bsnp/db/gatk/hg19/ucsc.hg19.fasta'
elif [ $GENOME == $MM10 ] 
	then REFERENCE='/bsnp/db/genomes/mouse/build38/mm10.fa'
else echo "No genome selected!"; exit 1;
fi

BAM_BASE=$GENE.$(basename $BAM_FILE | sed -e 's/\.bam//' -e 's/\.sorted//' -e 's/\.aligned//' )
LOG=run_freebayes.$BAM_BASE.$REGION.log

# date > $LOG

$APPS_PATH/freebayes/bin/freebayes \
  --fasta-reference $REFERENCE \
  --region $REGION \
  --no-snps \
  --use-duplicate-reads \
  $BAM_FILE \
> $BAM_BASE.vcf 2>>$LOG

# date >> $LOG
