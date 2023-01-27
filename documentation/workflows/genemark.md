
## genemark

### Inputs

#### Required

  * `container` (String, **required**)
  * `imgap_input_fasta` (String, **required**)
  * `imgap_project_id` (String, **required**)
  * `imgap_project_type` (String, **required**)

#### Defaults

  * `clean_and_unify.unify_bin` (String, default="/opt/omics/bin/structural_annotation/unify_gene_ids.py")
  * `gm_isolate.bin` (String, default="/opt/omics/bin/gms2.pl")
  * `gm_meta.bin` (String, default="/opt/omics/bin/gmhmmp2")
  * `gm_meta.model` (String, default="/opt/omics/programs/gms2_linux_64/mgm_11.mod")

### Outputs

  * `gff` (File)
  * `genes` (File)
  * `proteins` (File)

## gm_isolate

### Inputs

#### Required

  * `container` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)

#### Defaults

  * `bin` (String, default="/opt/omics/bin/gms2.pl")

### Outputs

  * `gff` (File)
  * `genes` (File)
  * `proteins` (File)

## gm_meta

### Inputs

#### Required

  * `container` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)

#### Defaults

  * `bin` (String, default="/opt/omics/bin/gmhmmp2")
  * `model` (String, default="/opt/omics/programs/gms2_linux_64/mgm_11.mod")

### Outputs

  * `gff` (File)
  * `genes` (File)
  * `proteins` (File)

## clean_and_unify

### Inputs

#### Required

  * `container` (String, **required**)
  * `project_id` (String, **required**)

#### Optional

  * `iso_genes_fasta` (File?)
  * `iso_gff` (File?)
  * `iso_proteins_fasta` (File?)
  * `meta_genes_fasta` (File?)
  * `meta_gff` (File?)
  * `meta_proteins_fasta` (File?)

#### Defaults

  * `unify_bin` (String, default="/opt/omics/bin/structural_annotation/unify_gene_ids.py")

### Outputs

  * `gff` (File)
  * `genes` (File)
  * `proteins` (File)
