
## rfam

### Inputs

#### Required

  * `additional_threads` (Int, **required**)
  * `cmzscore` (String, **required**)
  * `container` (String, **required**)
  * `imgap_input_fasta` (String, **required**)
  * `imgap_project_id` (String, **required**)
  * `imgap_project_type` (String, **required**)

#### Defaults

  * `claninfo_tsv` (String, default="~{database_location}" + "Rfam/13.0/Rfam.claninfo")
  * `cm` (String, default="~{database_location}" + "Rfam/13.0/Rfam.cm")
  * `database_location` (String, default="/refdata/img/")
  * `feature_lookup_tsv` (String, default="~{database_location}" + "Rfam/13.0/Rfam_feature_lookup.tsv")
  * `run.bin` (String, default="/opt/omics/bin/cmsearch")
  * `run.clan_filter_bin` (String, default="/opt/omics/bin/structural_annotation/rfam_clan_filter.py")
  * `run.rfam_version_file` (String, default="rfam_version.txt")

### Outputs

  * `rfam_gff` (File)
  * `rfam_tbl` (File)
  * `rfam_version` (String)

## run

### Inputs

#### Required

  * `claninfo_tsv` (String, **required**)
  * `cm` (String, **required**)
  * `cmzscore` (String, **required**)
  * `container` (String, **required**)
  * `feature_lookup_tsv` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)
  * `threads` (Int, **required**)

#### Defaults

  * `bin` (String, default="/opt/omics/bin/cmsearch")
  * `clan_filter_bin` (String, default="/opt/omics/bin/structural_annotation/rfam_clan_filter.py")
  * `rfam_version_file` (String, default="rfam_version.txt")

### Outputs

  * `tbl` (File)
  * `rfam_gff` (File)
  * `rfam_ver` (String)
