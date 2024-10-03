version 1.0

workflow KanpigWorkflow {
    input {
        File variants
        File bam
        File reference
        String sample
        Int threads = 8
    }

    call RunKanpig {
        input:
            variants = variants,
            bam = bam,
            reference = reference,
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
        File bam
        File reference
        String sample
        Int threads
    }

    command <<<
	
	output="~{sample}.kanpig.vcf.gz"	

        /software/kanpig --input ~{variants} \
            --bam ~{bam} \
            --reference ~{reference} \
            --sample ~{sample} \
            --hapsim 0.97 \
            --chunksize 500 \
            --maxpaths 1000 \
            --gpenalty 0.04 \
            --threads ~{threads} \
        | bcftools sort -T $TMPDIR -O z -o ~{output}
	
	tabix -p vcf  ~{output}
	
    >>>

    output {
        File sorted_output = "~{output}"
        File sorted_output_idx = "~{output}.tbi"
    }

    runtime {
        docker: "quay.io/zhengxc93/terra-kanpig:latest"  
        cpu: threads
        memory: "30 GB"  
        disks: "local-disk 100 SSD"  
    }
}
