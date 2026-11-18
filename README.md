# BET inhibition by JQ1 in CD4+ T cells: a paired RNA-seq analysis with DESeq2

This repository contains a complete, reproducible differential expression analysis in R of a public RNA-seq data set with a paired design. Peeters and colleagues (2015) treated CD4+ memory and effector T cells from patients with juvenile idiopathic arthritis (JIA) and from healthy donors with JQ1, an inhibitor of the BET family of bromodomain proteins, and sequenced each donor's cells with and without the drug (GEO series [GSE71595](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE71595)). Because every donor contributes both a control and a treated sample, the analysis models donor explicitly, and it then asks whether the drug acts differently in patients and healthy donors using DESeq2's nested design for group-specific treatment effects.

The rendered report, with code, figures, and interpretation, is in [`docs/analysis.html`](docs/analysis.html).

## Questions

1. Which genes does JQ1 change once differences between donors are accounted for?
2. Is the response to JQ1 the same in cells from patients and from healthy donors?
3. Does a known pharmacodynamic marker of BET inhibition behave as expected, as a check on the data and the model?

## Results in brief

| | Result |
| --- | --- |
| Genes tested after filtering (at least 10 reads in at least 3 samples) | 14,362 of 39,376 |
| Genes changed by JQ1, paired by donor (FDR below 5%) | 1,606 (639 up, 967 down) |
| Of those, changed at least twofold (apeglm-shrunken fold change) | 301 |
| Genes changed within healthy donors / within patients | 689 / 228 |
| Genes whose response differs between patients and healthy donors | 20 |
| Correlation of fold changes between the groups, responsive genes | r = 0.81 |
| HEXIM1, the standard marker of BET inhibition | up about twofold (log2 fold change 1.00, adjusted p = 1.2 × 10⁻⁷) |

Among the most strongly reduced genes are the cytokines IL17A, IL17F, IL24, and LIF, consistent with the original report that BET inhibition preferentially dampens cytokine-related programs in these cells. The induction of HEXIM1 in every donor confirms that the drug engaged its target and that the analysis recovers a known biological response. The response to JQ1 is largely shared between patients and healthy donors; with three patients and four controls, the comparison between groups is exploratory.

The first principal component separates patients from healthy donors. Because the patients' cells were taken from the site of inflammation, diagnosis cannot be separated from tissue source in this design, and the analysis does not attempt to interpret that difference.

## Methods

Counts are filtered to genes with at least ten reads in at least three samples. Exploratory analysis uses the variance-stabilizing transformation, principal components, and sample-to-sample distances. The main model is `~ donor + treatment`, which compares each donor's treated sample with that donor's own control; fold changes are shrunk with apeglm for ranking and plotting. The group comparison uses the design `~ diagnosis + diagnosis:donor_n + diagnosis:treatment`, with donors numbered within each diagnosis group and the all-zero column produced by unequal group sizes removed from the model matrix, as recommended in the DESeq2 documentation; the difference between the two groups' treatment effects is tested as a contrast between the two interaction terms. Entrez Gene IDs are mapped to HGNC symbols with the GRCh38 table from the annotables package.

## Repository layout

```
analysis.Rmd                 the analysis (R Markdown)
docs/analysis.html           the rendered report
data/raw_counts.tsv          gene-level counts, 14 samples (Entrez Gene IDs)
data/sample_metadata.tsv     donor, diagnosis, and treatment for each sample
data/gene_annotation.tsv     Entrez Gene ID to symbol and biotype
scripts/prepare_data.R       builds the files in data/ from their sources
results/tables/              DESeq2 results for every comparison, with symbols
results/figures/             PCA, sample distances, volcano, MA plot, heatmap, group concordance, HEXIM1
environment.yml              conda environment (R 4.4, DESeq2 1.46, apeglm, ggplot2, rmarkdown)
```

## How to run

```
mamba env create -f environment.yml
mamba activate rnaseq-deseq2-paired-design
Rscript -e 'rmarkdown::render("analysis.Rmd", output_file = "docs/analysis.html")'
```

## Data sources

The count table is the copy of GSE71595 distributed in the [nf-core/test-datasets](https://github.com/nf-core/test-datasets/tree/differentialabundance) repository (branch `differentialabundance`, `testdata/raw_counts_mixedmodel.tsv`, MIT License), and the sample annotations are taken from the same repository's samplesheet. The gene annotation comes from the [annotables](https://github.com/stephenturner/annotables) package (Ensembl GRCh38).

Peeters, J. G. C., Vervoort, S. J., Tan, S. C., Mijnheer, G., de Roock, S., Vastert, S. J., et al. (2015). Inhibition of super-enhancer activity in autoinflammatory site-derived T cells reduces disease-associated gene expression. *Cell Reports, 12*, 1986–1996. https://doi.org/10.1016/j.celrep.2015.08.046

## Author

Patricia K. Kamanda. Released under the MIT License.
