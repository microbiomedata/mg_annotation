
## crt

### Inputs

#### Required

  * `container` (String, **required**)
  * `imgap_input_fasta` (String, **required**)
  * `imgap_project_id` (String, **required**)

#### Defaults

  * `run.jar` (String, default="java -Xmx1536m -jar /opt/omics/bin/CRT-CLI.jar")
  * `run.transform_bin` (String, default="/opt/omics/bin/structural_annotation/transform_crt_output.py")

### Outputs

  * `crisprs` (File)
  * `gff` (File)
  * `crt_out` (File)

## run

### Inputs

#### Required

  * `container` (String, **required**)
  * `input_fasta` (File, **required**)
  * `project_id` (String, **required**)

#### Defaults

  * `jar` (String, default="java -Xmx1536m -jar /opt/omics/bin/CRT-CLI.jar")
  * `transform_bin` (String, default="/opt/omics/bin/structural_annotation/transform_crt_output.py")

### Outputs

  * `crisprs` (File)
  * `gff` (File)
  * `crt_out` (File)
