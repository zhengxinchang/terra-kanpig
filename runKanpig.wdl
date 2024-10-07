version 1.0

workflow KanpigWorkflow {
    input {
        File variants
        File variants_tbi
        File bam
        File bai
        File reference
        File fai
        String sample
        Int threads = 8
    }

    call RunKanpig {
        input:
            variants = variants,
            variants_tbi = variants_tbi,
            bam = bam,
            bai = bai,
            reference = reference,
            fai = fai,
            sample = sample,
            threads = threads,
    }

    output {
        File sorted_output = RunKanpig.sorted_output
        File sorted_output_idx = RunKanpig.sorted_output_idx
    }
}

task RunKanpig {
    input {
        File variants
        File variants_tbi
        File reference
        File bam
        File bai
        File reference
         File fai
        String sample
        Int threads
    }
    String outputs = "~{sample}.kanpig.vcf.gz"
    200 + ceil(size(reference_fa,"GB")) + 100*ceil(size(input_vcf_gz,"GB")) + 2*ceil(size(alignments_bam,"GB"))
    command <<<


        /software/kanpig --input ~{variants} \
            --bam ~{bam} \
            --reference ~{reference} \
            --sample ~{sample} \
            --hapsim 0.97 \
            --chunksize 500 \
            --maxpaths 1000 \
            --gpenalty 0.04 \
            --threads ~{threads} \
        | bcftools sort -T $TMPDIR -O z -o ~{outputs}
    
    tabix -p vcf  ~{outputs}
    
    >>>

    output {
        File sorted_output = "~{outputs}"
        File sorted_output_idx = "~{outputs}.tbi"
    }

    runtime {
        docker: "quay.io/zhengxc93/terra-kanpig:latest"  
        cpu: threads
        memory: "50 GB"  
        disks: "local-disk " + disk_size_gb + " SSD"  
    }
}
