# BaySnpper (BSNP)

Detection of CRISPR targeted indels across a panel of clones

## <i> <b> Data Summary
Bulk cells were targeted with CRISPR-Cas9 to generate indels. Individual cells were then sorted into clonal populations. PCR amplicons were produced from primers flanking the target region. The resulting amplicons were analyzed using paired end (140bp or 150bp), multiplexed sequencing with approximately 10 unique amplicons per sequencing lane. Data input for the BSNP pipeline includes:

1. FASTQ files for sequencing read 1 and read 2
2. Barcode information connecting barcodes to sample names.
3. Amplicon regions providing gene name and amplicon coordinates

## <i> <b> Analysis Workflow </i> </b>

### 1. Alignment
FASTQ files are translated from barcodes to sample names, aligned with the BWAmem package with default settings, sorted and indexed.

Prerequisites: 
library_params.txt (This file contains the 2 barcodes used and the sample name)
Target Genome: hg19

Script File: run_bwamem_from_barcodes.sh
sed -e '1,2d' library_params.txt | cut -f1,2,5 | xargs -n3 sh ~/methods_CRISPR_amplicons/run_bwamem_from_barcodes.sh

Output: Aligned BAM files and indexes

### 2. Indel prediction with FreeBayes
For each amplicon region the package FreeBayes is used to identify putative insertions and deletions within the sequencing reads, then determine the most likely genotype given the observed reads. Variants are annotated with genotype and likelihood as well as total depth of sequencing and number of reads contributing to each allele. 

<i> "[FreeBayes](https://github.com/ekg/freebayes) is a Bayesian genetic variant detector designed to find small polymorphisms, specifically SNPs (single-nucleotide polymorphisms), indels (insertions and deletions), MNPs (multi-nucleotide polymorphisms), and complex events (composite insertion and substitution events) smaller than the length of a short-read sequencing alignment. It uses short-read alignments (BAM files with Phred+33 encoded quality scores) for any number of individuals from a population and a reference genome to determine the most-likely combination of genotypes for the population at each position in a reference genome (FASTA). It reports positions which it finds to be more likely polymorphic than monomorphic in a standard variant interchange format (VCF)"  <i>

Prerequisites: 
Amplicon file with Flowcell name, Gene name, Gene region 
Example: AEC64   BCL11B_27SCC    chr14:99723822-99723983

Script File: call_freebayes_bySet.sh (calls run_freebayes.sh, run_snpEff.sh and run_CombineVariants_VariantsToTable.sh)

For each flowcell, there needs to be a list (1 per line) of each BAM file from the flowcell.
xargs -a Amplicons.tsv -n3 sh ~/methods_CRISPR_amplicons/call_freebayes_bySet.sh hg19

Output: None, VCF files produced are intermediate

### 3. Effect prediction annotation of VCF files
Indels from step 2 will be annotated for predicted variant effect using the snpEff package. Annotations will include a basic classification of level of variant effect (Low, Moderate, High), location (splice site, coding region), and effect (silent, frameshift).

Takes vcf output in Step 2 and performs annotation (using run_snpEff.sh). Stores stats info in effstats folder (snpEff_summary.html)

Output: Annotated VCF files (named: *.snpEff.vcf), one per clone and gene region. Open with IGV or similar genome browser.

### 4. Combine data and export to tabular format
Individual VCFs for each gene region are combined and exported in tab-separated format for exploration within Excel.

Uses output from Step 2-3 to generate table (using run_CombineVariants_VariantsToTable.sh)

Output: One tabular file for each gene region containing annotated variant information for all clones. 

WHEN OPENING IN EXCEL, ENSURE THAT YOU PROCEED TO STEP 3 OF 3 IN THE TEXT IMPORT WIZARD AND CLASSIFY ALL COLUMNS AS TEXT. OTHERWISE EXCEL WILL BREAK THE COMMA SEPARATED ALLELE FREQUENCY DATA.




