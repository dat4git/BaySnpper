APPS_PATH=/bsnp/apps
REFERENCE='/bsnp/db/gatk/hg19/ucsc.hg19.fasta'

BARCODE_1=$1
BARCODE_2=$2
LIBRARY_NAME=$3
LOG=run_bwamem_from_barcodes_$BARCODE_1.$BARCODE_2.$LIBRARY_NAME.log

FASTQ_1=$(find . -maxdepth 1 -name "*"$BARCODE_1"_"$BARCODE_2".unmapped.1.fastq")
FASTQ_2=$(find . -maxdepth 1 -name "*"$BARCODE_1"_"$BARCODE_2".unmapped.2.fastq")
#echo $FASTQ_1
#echo $FASTQ_2

PARAMS_FILE=$(find . -maxdepth 1 -name "*"$LIBRARY_NAME"_params.txt")
if [ -f $PARAMS_FILE ] 
then
#	echo $PARAMS_FILE
	FLOWCELL_BARCODE=_$(grep "FLOWCELL_BARCODE=" $PARAMS_FILE | sed -e 's/FLOWCELL_BARCODE=//')
#	echo $FLOWCELL_BARCODE
fi

BAMFILE=$LIBRARY_NAME$FLOWCELL_BARCODE.bam
#echo $BAMFILE

RG_LINE="@RG\tID:$LIBRARY_NAME$FLOWCELL_BARCODE\tPL:illumina\tPU:$LIBRARY_NAME_$BARCODE_1-$BARCODE_2\tLB:$LIBRARY_NAME\tSM:$LIBRARY_NAME"
#echo -e $RG_LINE

mkdir -p bwa_align
$APPS_PATH/bwa_current/bwa mem -t 20 -R $RG_LINE $REFERENCE $FASTQ_1 $FASTQ_2 \
  | samtools view -Shb - \
> bwa_align/$BAMFILE 2>> $LOG

BAM_SORTED=$(echo $BAMFILE | sed -e 's/.bam//').sorted.bam
#echo $BAM_SORTED

samtools sort bwa_align/$BAMFILE $(echo bwa_align/$BAM_SORTED | sed -e 's/.bam//')
samtools index bwa_align/$BAM_SORTED


