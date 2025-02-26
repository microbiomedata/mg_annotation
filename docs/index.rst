Metagenome Annotation Workflow (v1.1.4)
=======================================

.. image:: anno_workflow2024.svg

Workflow Overview
-----------------
This workflow takes assembled metagenomes and generates structural and functional annotations. It is based on the `JGI/IMG annotation pipeline <https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline/>`_ (`more details <https://journals.asm.org/doi/10.1128/msystems.00804-20>`_) and uses a number of open-source tools and databases to generate the structural and functional annotations. 

The input assembly is first split into 10MB splits to be processed in parallel. Depending on the workflow engine configuration, the split can be processed in parallel. Each split is first structurally annotated, then those results are used for the functional annotation. The structural annotation uses :code:`tRNAscan-SE`, :code:`Rfam`, :code:`CRT`, :code:`Prodigal` and :code:`GeneMarkS`. These results are merged to create a consensus structural annotation. The resulting GFF is the input for functional annotation which uses multiple protein family databases (:code:`SMART`, :code:`COG`, :code:`TIGRFAM`, :code:`SUPERFAMILY`, :code:`Pfam` and :code:`Cath-FunFam`) along with custom :code:`HMM` models. The functional predictions are created using :code:`Last` and :code:`HMM`. These annotations are also merged into a consensus GFF file. Finally, the respective split annotations are merged together to generate a single structural annotation file and single functional annotation file. In addition, several summary files are generated in TSV format.


Workflow Availability
---------------------
The workflow is available in GitHub: https://github.com/microbiomedata/mg_annotation/ and the corresponding Docker image is available in DockerHub: 

- `microbiomedata/img-omics:5.2.0 <https://hub.docker.com/r/microbiomedata/img-omics>`_


Requirements for Execution (recommendations are in bold):  
---------------------------------------------------------

- WDL-capable Workflow Execution Tool *(Cromwell)*
- Container Runtime that can load Docker images *(Docker v2.1.0.3 or higher)*

Hardware Requirements: 
----------------------
- Disk space: 106 GB for the reference databases
- Memory: >100 GB RAM


Workflow Dependencies
---------------------

- Third party software (This is included in the Docker image.)  

  - Conda (3-clause BSD)
  - tRNAscan-SE >= 2.0.12 (GNU GPL v3)
  - Infernal 1.1.4 (BSD)
  - CRT-CLI 1.8.4 (Public domain software, last official version is 1.2)
  - Prodigal 2.6.3_patched (GNU GPL v3)
  - GeneMarkS-2 >= 1.25 (`Academic license for GeneMark family software <http://topaz.gatech.edu/GeneMark/license_download.cgi>`_)
  - Last >= 1584 (GNU GPL v3)
  - HMMER 3.3.2 (3-clause BSD, `thread optimized <https://github.com/Larofeticus/hpc_hmmsearch>`_)
  - GeNomad 1.8.1 (GNU GPL v3, pulled from `IMG Annotation Pipeline repo <https://code.jgi.doe.gov/img/img-pipelines/img-annotation-pipeline>`_)

- Requisite databases: 

  - Rfam 13.0 (public domain/CC0 1.0; `more info <http://reusabledata.org/rfam>`_)
  - KEGG (paid subscription, getting KOs/ECs indirectly via IMG-NR 20240916; `more info <http://reusabledata.org/kegg-ftp>`_)
  - SMART 01_06_2016 (restrictive license/custom; `more info <http://reusabledata.org/smart>`_)
  - COG 2003 (copyright/unlicensed; `more info <http://reusabledata.org/cogs>`_)
  - TIGRFAM v15.0 (copyleft/LGPL 2.0 or later; `more info <http://reusabledata.org/tigrfams>`_)
  - SUPERFAMILY v1.75 (permissive/custom; `more info <http://reusabledata.org/supfam>`_) 
  - Pfam v37.0 (public domain/ CC0 1.0; `more info <http://reusabledata.org/pfam>`_) 
  - Cath-FunFam v4.2.0 (permissive/CC BY 4.0; `more info <http://reusabledata.org/cath>`_) 
  - GeNomad DB v1.7 (permissive/CC BY 4.0; `more info <https://zenodo.org/records/10594875>`_) 


Sample datasets
---------------

- Processed Metatranscriptome of soil microbial communities from the East River watershed near Crested Butte, Colorado, United States - ER_RNA_119 (`SRR11678315 <https://www.ncbi.nlm.nih.gov/sra/SRX8239222>`_) with `metadata available in the NMDC Data Portal <https://data.microbiomedata.org/details/study/nmdc:sty-11-dcqce727>`_. 

  - The zipped raw FASTA file is available `here <https://portal.nersc.gov/cfs/m3408/test_data/metaT/SRR11678315.fastq.gz>`_
  - The zipped, QC'ed FASTA file is available `here <https://portal.nersc.gov/cfs/m3408/test_data/metaT/SRR11678315/readsqc_output/SRR11678315-int-0.1_filtered.fastq.gz>`_
  - The assembled FASTA file is available `here <https://portal.nersc.gov/cfs/m3408/test_data/metaT/SRR11678315/assembly_output/SRR11678315-int-0.1_contigs.fna>`_
  - The sample annotation outputs are available `here <https://portal.nersc.gov/cfs/m3408/test_data/metaT/SRR11678315/annotation_output/>`_

Inputs
------
A JSON file containing the following: 

#.  The path to the assembled contigs FASTA file 
#.  output file prefix
#.	(optional) parameters for memory 
#.	(optional) number of threads requested

An example JSON file is shown below:

.. code-block:: JSON

      {
      "annotation.input_file": "https://portal.nersc.gov/cfs/m3408/test_data/metaT/SRR11678315/assembly_output/SRR11678315-int-0.1_contigs.fna",
      "annotation.proj": "SRR11678315-int-0.1",
      "annotation.imgap_project_id": "SRR11678315-int-0.1"
      }


Output
------
The final structural and functional annotation files are in GFF format and the summary files are in TSV format.  

.. list-table:: 
   :header-rows: 1

   * - Directory/File Name
     - Description
   * - prefix_cath_funfam.gff
     - GFF / tab-delimited functional annotation generated from Cath-FunFam (Functional Families) database
   * - prefix_cog.gff
     - GFF / tab-delimited functional annotation generated from COG (Clusters of Orthologous Groups) database
   * - prefix_contig_names_mapping.tsv
     - Tab-delimited file with mapping of original contig/read IDs (headers of submitted fasta file) to specified contig names
   * - prefix_contigs.fna
     - FASTA nucleic acid file for taxon.
   * - prefix_crt.crisprs
     - Tab-delimited file for CRISPR array annotation details
   * - prefix_crt.gff
     - GFF / tab-delimited structural annotation generated with CRT
   * - prefix_ec.tsv
     - Tab-delimited file file for EC annotation
   * - prefix_functional_annotation.gff
     - GFF / tab-delimited with functional annotations
   * - prefix_genemark.gff
     - GFF / tab-delimited with structural annotation by GeneMark
   * - prefix_gene_phylogeny.tsv
     - Tab-delimited file of gene phylogeny
   * - prefix_imgap.info
     - Workflow information
   * - prefix_ko_ec.gff
     - GFF / tab-delimited annotation with KO and EC terms
   * - prefix_ko.tsv
     - Tab-delimited file of only KO terms
   * - prefix_pfam.gff
     - GFF / tab-delimited functional annotation from Pfam database
   * - prefix_prodigal.gff
     - GFF3 structural annotation by Prodigal
   * - prefix_product_names.tsv
     - Tab-delimited file of annotation products
   * - prefix_proteins.faa
     - FASTA amino acid file for taxon
   * - prefix_rfam.gff
     - GFF / tab-delimited structural annotation for non-coding RNA and regulatory RNA motif and binding site annotation by Rfam
   * - prefix_scaffold_lineage.tsv
     - Tab-delimited file of phylogeny at scaffold level
   * - prefix_smart.gff
     - GFF / tab-delimited functional annotation from SMART database
   * - prefix_stats.json
     - JSON of annotation statistics report
   * - prefix_stats.tsv
     - Tab-delimited file of annotation statistics report
   * - prefix_structural_annotation.gff
     - GFF / tab-delimited structural annotation
   * - prefix_supfam.gff
     - GFF / tab-delimited functional annotation from SUPERFAMILY database
   * - prefix_tigrfam.gff
     - GFF / tab-delimited functional annotation from TIGRFAM database
   * - prefix_trna.gff
     - GFF / tab-delimited structural annotation by tRNAscan-SE


Structure of GFF and tab-delimited text files
---------------------------------------------

General GFFs
~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - seqid
     - Sequence ID
   * - 2
     - source
     - Version of IMG database
   * - 3
     - type
     - Feature type
   * - 4
     - start_coord
     - Starting coordinate
   * - 5
     - end_coord
     - Ending coordinate
   * - 6
     - score
     - NA
   * - 7
     - strand
     - Strand orientation
   * - 8
     - phase
     - NA
   * - 9
     - attributes
     - ID=<feature_id>;locus_tag=<gene_id>;product=<initial product>


:code:`prefix_cog.gff` (From NCBI RPSBLAST or hmmsearch with COG HMMs)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene object identifier of query gene
   * - 2
     - cog_id
     - COG identifier
   * - 3
     - percent_identity
     - Percent identity of aligned amino acid residues (Not valid for HMM's, retained for compatibility with legacy data)
   * - 4
     - align_length
     - Alignment length
   * - 5
     - query_start
     - Start coordinate of alignment on query gene
   * - 6
     - query_end
     - End coordinate of alignment on query gene
   * - 7
     - subj_start
     - Start coordinate of alignment on subject sequence
   * - 8
     - subj_end
     - End coordinate of alignment on subject sequence
   * - 9
     - eHeader
     - Expectation Header
   * - 10
     - bit_score
     - Bit score of alignment


:code:`prefix_pfam.gff` (From hmmsearch with Pfam HMMs)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene identifier of query gene
   * - 2
     - pfam_id
     - Pfam identifier
   * - 3
     - percent_identity
     - (Always "100%". Not valid for HMMs, retained for compatibility with legacy data)
   * - 4
     - query_start
     - Start coordinate of alignment on query gene
   * - 5
     - query_end
     - End coordinate of alignment on query gene
   * - 6
     - subj_start
     - Start coordinate of alignment on subject sequence
   * - 7
     - subj_end
     - End coordinate of alignment on subject sequence
   * - 8
     - eHeader
     - Expectation Header
   * - 9
     - bit_score
     - Bit score of alignment
   * - 10
     - align_length
     - Alignment length


:code:`prefix_tigrfam.gff` (TIGRFAM annotation)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene identifier of query gene
   * - 2
     - tfam_id
     - TIGRFAM identifier
   * - 3
     - percent_identity
     - (Always "100%". Not valid for HMMs, retained for compatibility with legacy data)
   * - 4
     - query_start
     - Start coordinate of alignment on query gene
   * - 5
     - query_end
     - End coordinate of alignment on query gene
   * - 6
     - subj_start
     - Start coordinate of alignment on subject sequence
   * - 7
     - subj_end
     - End coordinate of alignment on subject sequence
   * - 8
     - eHeader
     - Expectation Header
   * - 9
     - bit_score
     - Bit score of alignment
   * - 10
     - align_length
     - Alignment length


:code:`prefix_cath_funfam.gff` (CATH FUNFAM annotation)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene identifier of query gene
   * - 2
     - cathfunfam_id
     - CATH FUNFAM identifier
   * - 3
     - percent_identity
     - Percent identity match in alignment (Not valid for HMMs, retained for compatibility with legacy data)
   * - 4
     - query_start
     - Start coordinate of alignment on query gene
   * - 5
     - query_end
     - End coordinate of alignment on query gene
   * - 6
     - subj_start
     - Start coordinate of alignment on subject sequence
   * - 7
     - subj_end
     - End coordinate of alignment on subject sequence
   * - 8
     - eHeader
     - Expectation Header
   * - 9
     - bit_score
     - Bit score of alignment
   * - 10
     - align_length
     - Alignment length


:code:`prefix_supfam.gff` (SUPERFAM annotation)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene identifier of query gene
   * - 2
     - superfam_id
     - SUPERFAM identifier
   * - 3
     - percent_identity
     - Percent identity match in alignment (Not valid for HMMs, retained for compatibility with legacy data)
   * - 4
     - query_start
     - Start coordinate of alignment on query gene
   * - 5
     - query_end
     - End coordinate of alignment on query gene
   * - 6
     - subj_start
     - Start coordinate of alignment on subject sequence
   * - 7
     - subj_end
     - End coordinate of alignment on subject sequence
   * - 8
     - eHeader
     - Expectation Header
   * - 9
     - bit_score
     - Bit score of alignment
   * - 10
     - align_length
     - Alignment length


:code:`prefix_smart.gff` (SMART annotation)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene identifier of query gene
   * - 2
     - smart_id
     - SMART identifier
   * - 3
     - percent_identity
     - Percent identity match in alignment (Not valid for HMMs, retained for compatibility with legacy data)
   * - 4
     - query_start
     - Start coordinate of alignment on query gene
   * - 5
     - query_end
     - End coordinate of alignment on query gene
   * - 6
     - subj_start
     - Start coordinate of alignment on subject sequence
   * - 7
     - subj_end
     - End coordinate of alignment on subject sequence
   * - 8
     - eHeader
     - Expectation Header
   * - 9
     - bit_score
     - Bit score of alignment
   * - 10
     - align_length
     - Alignment length


:code:`prefix_gene_phylogeny.tsv` (from LAST on non-redundant database of IMG proteins extracted from high-quality genomes)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene identifier of query gene
   * - 2
     - homolog_gene_oid
     - IMG gene object identifier of LAST hit (subject sequence)
   * - 3
     - homolog_taxon_oid
     - IMG taxon object identifier of LAST hit protein (subject sequence)
   * - 4
     - percent_identity
     - Percent identity match in alignment
   * - 5
     - lineage
     - Domain;phylum;class;order;family;genus;species;taxon_name of the genome in which LAST hit was found


:code:`prefix_ko.tsv` (from LAST on IMG genes)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene object identifier of query gene
   * - 2
     - img_ko_flag
     - IMG generated KO assignment. Always 'Yes'.
   * - 3
     - ko_term
     - KEGG Orthology (KO) identifier of LAST hit (subject sequence)
   * - 4
     - percent_identity
     - Percent identity of aligned amino acid residues
   * - 5
     - query_start
     - Start coordinate of alignment on query gene
   * - 6
     - query_end
     - End coordinate of alignment on query gene
   * - 7
     - subj_start
     - Start coordinate of alignment on subject sequence
   * - 8
     - subj_end
     - End coordinate of alignment on subject sequence
   * - 9
     - eHeader
     - Expectation Header
   * - 10
     - bit_score
     - Bit score of alignment
   * - 11
     - align_length
     - Alignment length

:code:`prefix_ec.tsv` (from LAST on IMG genes)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene object identifier of query gene
   * - 2
     - img_ko_flag
     - IMG generated KO assignment. Always 'Yes'.
   * - 3
     - EC
     - EC derived from KEGG Orthology (KO) identifier of LAST hit (subject sequence)
   * - 4
     - percent_identity
     - Percent identity of aligned amino acid residues
   * - 5
     - query_start
     - Start coordinate of alignment on query gene
   * - 6
     - query_end
     - End coordinate of alignment on query gene
   * - 7
     - subj_start
     - Start coordinate of alignment on subject sequence
   * - 8
     - subj_end
     - End coordinate of alignment on subject sequence
   * - 9
     - eHeader
     - Expectation Header
   * - 10
     - bit_score
     - Bit score of alignment
   * - 11
     - align_length
     - Alignment length

:code:`prefix_product_names.tsv` (from COG, Pfam, TIGRfam)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - gene_id
     - Gene identifier
   * - 2
     - product_name
     - Product name
   * - 3
     - source
     - Source of assignment


:code:`prefix_contig_names_mapping.tsv` 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - orig_id
     - Original sequence ID (derived from the headers of the fasta file submitted to IMG)
   * - 2
     - new_id
     - New sequence ID assigned by IMG annotation pipeline


:code:`prefix_crt.crisprs`
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table:: 
   :header-rows: 1

   * - Column
     - Header
     - Description
   * - 1
     - contig_id
     - Contig/Scaffold ID
   * - 2
     - crispr_no
     - CRISPR number
   * - 3
     - pos
     - Starting position of array element
   * - 4
     - repeat_seq
     - Repeat sequence
   * - 5
     - spacer_seq
     - Spacer sequence
   * - 6
     - tool_code
     - Single letter code for tool used


Version History
---------------
- 1.1.4 (08/09/2024)
- 1.0.0 (release data)

Point of contact
----------------

- Author: Shane Canon <scanon@lbl.gov>
- Maintainer: Kaitlyn Li <kli@lanl.gov>



