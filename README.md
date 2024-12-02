## Workflow for Metagenome annotation                                                                                                                                                                                                                      
This workflow takes assembled metagenomes and generates structural and functional annotations. It is based on the [JGI/IMG annotation](https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline/) pipeline ([more details] (https://journals.asm.org/doi/10.1128/msystems.00804-20)) and uses a number of open-source tools and databases to generate the structural and functional annotations. 

The input assembly is first split into 10MB splits to be processed in parallel. Depending on the workflow engine configuration, the split can be processed in parallel. Each split is first structurally annotated, then those results are used for the functional annotation. The structural annotation uses `tRNAscan_se`, `RFAM`, `CRT`, `Prodigal` and `GeneMarkS`. These results are merged to create a consensus structural annotation. The resulting GFF is the input for functional annotation which uses multiple protein family databases (`SMART`, `COG`, `TIGRFAM`, `SUPERFAMILY`, `Pfam` and `Cath-FunFam`) along with custom `HMM` models. The functional predictions are created using `Last` and `HMM`. These annotations are also merged into a consensus GFF file. Finally, the respective split annotations are merged together to generate a single structural annotation file and single functional annotation file. In addition, several summary files are generated in TSV format.


## Running Workflow in Cromwell

Description of the files:
  - `.wdl` file: the WDL file for workflow definition
  - `.json` file: the example input for the workflow
  - `.conf` file: the conf file for running Cromwell.
  - `.sh` file: the shell script for running the example workflow

## The Docker image can be found here

[microbiomedata/img-omics:5.2.0](https://hub.docker.com/r/microbiomedata/img-omics)


## Input files
A JSON file containing the following: 

1. The path to the assembled contigs fasta file 
2. The ID to associate with the result products (e.g. sample ID)


#### Requirements for Execution (recommendations are in bold):                                                  
  - WDL-capable Workflow Execution Tool **(Cromwell)**
  - Container Runtime that can load Docker images **(Docker v2.1.0.3 or higher)**


#### Third party software used (+ their licenses)
  - Conda (3-clause BSD)
  - tRNAscan-SE >= 2.0.12 (GNU GPL v3)
  - Infernal 1.1.3 (BSD)
  - CRT-CLI 1.8.4 (Public domain software, last official version is 1.2)
  - Prodigal 2.6.3_patched (GNU GPL v3)
  - GeneMarkS-2 >= 1.25 ([Academic license for GeneMark family software](http://topaz.gatech.edu/GeneMark/license_download.cgi))
  - Last >= 1456 (GNU GPL v3)
  - HMMER 3.1b2 (3-clause BSD, [thread optimized hmmsearch](https://github.com/Larofeticus/hpc_hmmsearch))
  - GeNomad 1.8.1 (GNU GPL v3, pulled from [IMG Annotation Pipeline repo](https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline))
 

#### Databases used (+ their licenses):
  - Rfam (public domain/CC0 1.0; [more info](http://reusabledata.org/rfam))
  - KEGG (paid subscription, getting KOs/ECs indirectly via IMG NR; [more info](http://reusabledata.org/kegg-ftp))
  - SMART (restrictive license/custom); [more info](http://reusabledata.org/smart)
  - COG (copyright/unlicensed); [more info](http://reusabledata.org/cogs)
  - TIGRFAM (copyleft/LGPL 2.0 or later); [more info](http://reusabledata.org/tigrfams)
  - SUPERFAMILY (permissive/custom); [more info](http://reusabledata.org/supfam)
  - Pfam (public domain/ CC0 1.0); [more info](http://reusabledata.org/pfam)
  - Cath-FunFam (permissive/CC BY 4.0); [more info](http://reusabledata.org/cath)
  - GeNomad DB v1.7 (permissive/CC BY 4.0; [more info](https://zenodo.org/records/10594875))
