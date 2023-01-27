
## trnascan

author
: Brian Foster

email
: bfoster@lbl.gov

version
: 1.0.0

### Inputs

#### Required

  * `additional_threads` (Int, **required**)
  * `imgap_input_fasta` (String, **required**)
  * `imgap_project_id` (String, **required**)
  * `imgap_project_type` (String, **required**)

#### Defaults

  * `container` (String, default="microbiomedata/img-omics@sha256:9f092d7616e0d996123e039d6c40e95663cb144a877b88ee7186df6559b02bc8")
  * `trnascan_ba.bin` (String, default="/opt/omics/bin/tRNAscan-SE")

### Outputs

  * `gff` (File)
  * `bacterial_out` (File)
  * `archaeal_out` (File)

## trnascan_ba

### Inputs

#### Required

  * `container` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)
  * `threads` (Int, **required**)

#### Defaults

  * `bin` (String, default="/opt/omics/bin/tRNAscan-SE")

### Outputs

  * `bacterial_out` (File)
  * `archaeal_out` (File)
  * `gff` (File)
