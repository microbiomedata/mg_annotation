Metagenome Annotation Workflow (v1.0.0)
=======================================

.. image:: annotation.png

Workflow Overview
-----------------
This workflow takes assembled metagenomes and generates structural and functional annotations. The workflow uses a number of open-source tools and databases to generate the structural and functional annotations. 

The input assembly is first split into 10MB splits to be processed in parallel. Depending on the workflow engine configuration, the split can be processed in parallel. Each split is first structurally annotated, then those results are used for the functional annotation. The structural annotation uses tRNAscan_se, RFAM, CRT, Prodigal and GeneMarkS. These results are merged to create a consensus structural annotation. The resulting GFF is the input for functional annotation which uses multiple protein family databases (SMART, COG, TIGRFAM, SUPERFAMILY, Pfam and Cath-FunFam) along with custom HMM models. The functional predictions are created using Last and HMM. These annotations are also merged into a consensus GFF file. Finally, the respective split annotations are merged together to generate a single structural annotation file and single functional annotation file. In addition, several summary files are generated in TSV format.


Workflow Availability
---------------------
The workflow is available in GitHub: https://github.com/microbiomedata/mg_annotation/ and the corresponding Docker image is available in DockerHub: https://hub.docker.com/r/microbiomedata/mg-annotation.

Requirements for Execution (recommendations are in bold):  
---------------------------------------------------------

- WDL-capable Workflow Execution Tool **(Cromwell)**
- Container Runtime that can load Docker images **(Docker v2.1.0.3 or higher)**

Hardware Requirements: 
----------------------
- Disk space: 106 GB for the reference databases
- Memory: >100 GB RAM


Workflow Dependencies
---------------------

- Third party software (This is included in the Docker image.)  
   - Conda (3-clause BSD)
   - tRNAscan-SE >= 2.0 (GNU GPL v3)
   - Infernal 1.1.2 (BSD)
   - CRT-CLI 1.8 (Public domain software, last official version is 1.2)
   - Prodigal 2.6.3 (GNU GPL v3)
   - GeneMarkS-2 >= 1.07 (Academic license for GeneMark family software)
   - Last >= 983 (GNU GPL v3)
   - HMMER 3.1b2 (3-clause BSD)
   - TMHMM 2.0 (Academic)
- Requisite databases: The databases are available by request. Please contact NMDC (support@microbiomedata.org) for access.


Sample datasets
---------------
https://raw.githubusercontent.com/microbiomedata/mg_annotation/master/example.fasta


**Input:** A JSON file containing the following: 

1. The path to the assembled contigs fasta file 
2. The ID to associate with the result products (e.g. sample ID)

An example JSON file is shown below:

.. literalinclude:: inputs.json
  :language: JSON

**Output:** The final structural and functional annotation files are in GFF format and the summary files are in TSV format.  The key outputs are listed below but additional files are available.

- GFF: Structural annotation
- GFF: Functional annotation
- TSV: KO Summary
- TSV: EC Summary
- TSV: Gene Phylogeny Summar

The output paths can be obtained from the output metadata file from the Cromwell Exectuion.  Here is a snippet from the outputs section
of the full metadata JSON file.

.. literalinclude:: meta.json
  :language: JSON


**Version History:** 1.0.0 (release data)

Point of contact
----------------

* Package maintainer: Shane Canon <scanon@lbl.gov>


