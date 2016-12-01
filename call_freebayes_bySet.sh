METHODS_DIR='/ifs/labs/cccb/projects/cccb/aholman/methods_CRISPR_amplicons/'

GENOME=$1
SEQ_SET=$2
GENE=$3
REGION=$4

#echo $GENOME
#echo $SEQ_SET
echo $GENE
#echo $REGION
#echo "---------"

mkdir -p $GENE
cd $GENE

xargs -a ../$SEQ_SET.bams.list -n1 -P20 -I{} sh $METHODS_DIR/run_freebayes.sh ../{} $REGION $GENE $GENOME
find . -maxdepth 1 -name "*.vcf" | grep -v snpEff | sort | xargs -n1 -I{} sh $METHODS_DIR/run_snpEff.sh {} $GENOME

cd ..
sh $METHODS_DIR/run_CombineVariants_VariantsToTable.sh $GENE $GENOME

find $GENE -name "*.snpEff.vcf*" | grep -v combined_variants | xargs zip CRIPSR_pipeline_results.zip
find $GENE -name "combined_variants_*.tsv" | xargs zip CRIPSR_pipeline_results.zip

find $GENE -name "combined_variants_*.vcf*" | xargs -n1 rm