APPS_PATH=/bsnp/apps
DB_PATH=/bsnp/db
#REFERENCE='/bsnp/db/gatk/hg19/ucsc.hg19.fasta'
#REFERENCE_NAME='hg19'

#mkdir -p snpEff_logs
mkdir -p effStats

VCF_FILE=$1
GENOME=$2

HG19='hg19'
MM10='mm10'
if   [ $GENOME == $HG19 ] 
	then SNPEFF_GENOME='hg19'
elif [ $GENOME == $MM10 ] 
	then SNPEFF_GENOME='GRCm38.78'
else echo "No genome selected!"; exit 1;
fi

LOG=run_snpEff.$(basename $VCF_FILE).log
OUT_VCF=$(echo $VCF_FILE | sed -e 's/.vcf//').snpEff.vcf
BASENAME=$(basename $VCF_FILE | sed -e's/.vcf//')


date > $LOG
echo '----------------------------' >> $LOG
echo "  running snpEff -> $BASENAME"

java -Xmx4G -jar $APPS_PATH/snpEff/snpEff.jar eff \
  -t \
  -c $APPS_PATH/snpEff/snpEff.config \
  -stats effStats/$BASENAME.html \
  -v \
  -i vcf \
  -o gatk \
  $SNPEFF_GENOME \
  $VCF_FILE > $OUT_VCF 2>>$LOG

#EFFSTATS=effStats/$(basename $VCF_FILE | sed -e 's/.vcf//').effStats.genes.txt 
#mv effStats.genes.txt $EFFSTATS
#EFFSTATS=effStats/$(basename $VCF_FILE | sed -e 's/.vcf//').effStats.html
#mv effStats.html $EFFSTATS

echo '----------------------------' >> $LOG
date >> $LOG
