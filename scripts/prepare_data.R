# prepare_data.R
# Builds the tidy inputs in data/ from their public sources.
#
#   data/raw_counts.tsv       gene-level read counts for GEO series GSE71595 (Peeters et al., 2015),
#                             as distributed in the nf-core/test-datasets repository
#                             (branch differentialabundance, testdata/raw_counts_mixedmodel.tsv, MIT License)
#   data/sample_metadata.tsv  sample annotations transcribed from the same repository's samplesheet
#   data/gene_annotation.tsv  Entrez Gene ID to HGNC symbol mapping for the genes in the count table,
#                             taken from the annotables package (GRCh38, Ensembl)
#
# Run from the repository root:  Rscript scripts/prepare_data.R path/to/grch38.rda
# grch38.rda: https://raw.githubusercontent.com/stephenturner/annotables/master/data/grch38.rda

args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1)

counts <- read.delim("data/raw_counts.tsv", check.names = FALSE)

metadata <- data.frame(
  sample    = sprintf("GSM18410%02d", 68:81),
  donor     = c("HC_A", "HC_A", "HC_B", "HC_B", "HC_C", "HC_C", "HC_D", "HC_D",
                "JIA_A", "JIA_A", "JIA_B", "JIA_B", "JIA_C", "JIA_C"),
  diagnosis = rep(c("Healthy", "JIA"), times = c(8, 6)),
  treatment = rep(c("Control", "JQ1"), times = 7)
)
stopifnot(identical(metadata$sample, colnames(counts)[-1]))
write.table(metadata, "data/sample_metadata.tsv", sep = "\t", quote = FALSE, row.names = FALSE)

load(args[1])  # provides grch38
annotation <- unique(grch38[!is.na(grch38$entrez), c("entrez", "symbol", "biotype")])
annotation <- annotation[annotation$entrez %in% counts$gene_id, ]
annotation <- annotation[!duplicated(annotation$entrez), ]
names(annotation)[1] <- "gene_id"
write.table(annotation, "data/gene_annotation.tsv", sep = "\t", quote = FALSE, row.names = FALSE)

cat(nrow(counts), "genes,", ncol(counts) - 1, "samples;", nrow(annotation), "genes with a symbol\n")
