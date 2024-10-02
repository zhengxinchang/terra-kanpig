# Given a sample name, sex (Male | Female), and bam, genotype with kanpig
# Before running, fill in some hard-coded paths below.
# Expects bcftools and tabix to be in PATH
set -e 
sample=$1
sex=$2
bam=$3

# Fill these in
threads=8
# Input Variants
variants=/users/u233287/fritz/english/AoUh/svs/AoU_2113samps.vcf.gz
# Where to write output VCF
out_dir=/users/u233287/fritz/english/AoUh/svs/kanpig_results
# Reference used to align the reads
reference=/stornext/snfs0/next-gen/pacbio/sequel/references/GRCh38-2.1.0/sequence/GRCh38-2.1.0_genome_mainchrs.fa
# Path to kanpig ploidy beds
male_bed=/users/u233287/scratch/code/kanpig/ploidy_beds/grch38_male.bed
female_bed=/users/u233287/scratch/code/kanpig/ploidy_beds/grch38_female.bed
# Kanpig executable 
kanpig=/users/u233287/scratch/code/kanpig/target/release/kanpig

validate_file() {
    local file="$1"

    # Check if the file exists
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' does not exist."
        exit 1
    fi
}

validate_program() {
    local program="$1"

    # Check if the program is available in the environment
    if ! command -v "$program" &> /dev/null; then
        echo "Error: Program '$program' is not installed or not in the PATH."
        exit 1
    fi
}

if [ "$sex" == "Male" ]; then
    pbed=$male_bed
elif [ "$sex" == "Female" ]; then
    pbed=$female_bed
else
    echo "Invalid sex. Expected Male or Female"
fi

files=("$variants" "$bam" "$reference" "$pbed" "$kanpig")

# Loop to validate all files
for file in "${files[@]}"; do
    validate_file "$file"
done

if [[ ! -d "$out_dir" ]]; then
    echo "Error: Output directory '$out_dir' does not exist."
    exit 1
fi

validate_program bcftools
validate_program tabix

output=${out_dir}/${sample}.vcf.gz

# Actually run kanpig
$kanpig --input $variants \
    --bam ${bam} \
    --reference ${reference} \
    --sample ${sample} \
    --ploidy-bed $pbed \
    --hapsim 0.97 \
    --chunksize 500 \
    --maxpaths 1000 \
    --gpenalty 0.04 \
    --threads ${threads} \
    | bcftools sort -T $TMPDIR -O z -o ${output}

tabix ${output}
