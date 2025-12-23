conda activate gtdbtk
mkdir gtdbtk
gtdbtk classify_wf --pplacer_cpus 15 --cpus 15 --genome_dir bins_50_10 --full_tree -x fna --out_dir gtdbtk 
tail -n+2 gtdbtk/gtdbtk.bac120.summary.tsv|cut -f 1-2|sed 's/;/\t/g'|sed '1 s/^/ID\tDomain\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies\n/' > gtdbtk/tax.txt

gunzip gtdbtk/align/gtdbtk.bac120.user_msa.fasta.gz
gtdbtk infer --out_dir infer --cpus 15 --msa_file gtdbtk/align/gtdbtk.bac120.user_msa.fasta

gunzip gtdbtk/align/gtdbtk.ar53.user_msa.fasta.gz
gtdbtk infer --out_dir infer --cpus 15 --msa_file gtdbtk/align/gtdbtk.ar53.user_msa.fasta
