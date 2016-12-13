APPS_PATH=/bsnp/apps # folder containing dependencies
DB_PATH=/bsnp/db/
REFERENCE='/bsnp/db/gatk/hg19/ucsc.hg19.fasta'

#VCF_LIST=$1
FOLDER=$1
GENOME=$2

HG19='hg19'
MM10='mm10'
if   [ $GENOME == $HG19 ] 
	then REFERENCE='/bsnp/db/gatk/hg19/ucsc.hg19.fasta/ucsc.hg19.fasta'
elif [ $GENOME == $MM10 ] 
	then REFERENCE='/bsnp/db/genomes/mouse/build38/mm10.fa'
else echo "No genome selected!"; exit 1;
fi

LOG=run_CombineVariants_VariantsToTable_$FOLDER.log

date > $LOG

find $FOLDER -name "*.snpEff.vcf" | sort > $FOLDER/vcf_files.list

java -Xms4g -Xmx8g -jar $APPS_PATH/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar \
  -T CombineVariants \
  -R $REFERENCE \
  --variant $FOLDER/vcf_files.list \
  --filteredrecordsmergetype KEEP_IF_ANY_UNFILTERED \
  --genotypemergeoption UNSORTED \
  --mergeInfoWithMaxAC \
  --out $FOLDER/combined_variants_$FOLDER.vcf \
>> $LOG 2>&1


java -Xms1g -Xmx4g -jar $APPS_PATH/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar \
	-T VariantsToTable \
	-R $REFERENCE \
	-V $FOLDER/combined_variants_$FOLDER.vcf \
	-F CHROM \
	-F POS \
	-F REF \
	-F ALT \
	-F EFF \
	-GF GT \
	-GF DP \
	-GF RO \
	-GF AO \
	--allowMissingData \
	-o $FOLDER/combined_variants_$FOLDER.tsv \
>> $LOG 2>&1


#  -L $RANGE_LIST \


echo "===============" >> $LOG
date >> $LOG
