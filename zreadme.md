
# checking genotypes on sex chr

```
bcftools query -f "[%GT\n]" -r chrX data/concat_annotated.sens_07.vcf.gz  | sort | uniq -c
28811404 ./.
   5536 0/0
 257073 0/1
 300961 1/1
```


