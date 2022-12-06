![alt text](https://arimagenomics.com/wp-content/files/2021/08/Arima-Genomics-logo.png "Celebrating Science and Scientist")

# Arima Capture HiC Pipeline using Arima-HiC<sup>+</sup> Kit

This pipeline is for analyzing capture HiC data with HiCUP and CHiCAGO pipelines for generating Arima Genomics QC metrics and output data files. The pipeline runs the standard HiCUP and CHiCAGO algorithms from https://www.bioinformatics.babraham.ac.uk/projects/hicup/ and https://bioconductor.org/packages/release/bioc/html/Chicago.html with some minor changes to the default parameters. These parameters have been optimized by internal benchmarking and have been found to optimize sensitivity and specificity. This pipeline will also generate shallow and deep sequencing QC metrics which can be copied into the Arima QC Worksheet for analysis. Additionally, the pipeline automatically generates metaplots for data QC and arc plots of chromatin loops for data visualization.

## Getting Started

This pipeline is suited for CHiC from any protocol but optimal results are obtained when using the Arima-HiC<sup>+</sup> kit with the Arima-CHiC protocol.

To order Arima-HiC<sup>+</sup> kits, please visit our website: https://arimagenomics.com/

### Installing Arima CHiC

```
git clone https://github.com/ArimaGenomics/CHiC.git
cd CHiC
tar xf chicagoTools.tar.gz
chmod 755 Arima-CHiC-v1.5.sh
```

### Installing Python 3.4 or later

- Anaconda3, https://docs.anaconda.com/anaconda/install/linux/

```
curl -O https://repo.anaconda.com/archive/Anaconda3-2019.07-Linux-x86_64.sh
sh Anaconda3-2019.07-Linux-x86_64.sh
# read the user agreement and answer yes. install Anaconda3 in the default location which is your home folder.
```

### Installing R 3.4.3 or later

```
conda install R
```

- argparser (0.7.1), https://cran.r-project.org/web/packages/argparser/index.html

```
# in R
install.packages("argparser")
```

### Installing HiCUP

Refer to the documentation at: https://www.bioinformatics.babraham.ac.uk/projects/hicup/read_the_docs/html/index.html for help installing HiCUP and its dependencies (Perl, R, bowtie2, and samtools).

```
wget https://github.com/StevenWingett/HiCUP/archive/refs/tags/v0.8.0.tar.gz
tar -xzf v0.8.0.tar.gz
```

### Installing CHiCAGO

Refer to the documentation at: https://bioconductor.org/packages/release/bioc/html/Chicago.html for help installing CHiCAGO and its dependencies.
#### *IMPORTANT NOTE: bedtools v2.26 or later isn't compatible with CHiCAGO! Please use v2.25 instead!!!*

```
# in R
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("Chicago")
BiocManager::install("Rsamtools")
```

### Other

Before installing HTSLIB, gcc and zlib are required. Before installing bedtools, g++ is required. Skip if you already have those compilers installed.
- gcc, https://gcc.gnu.org/

```
conda install -c conda-forge gcc_linux-64
```

- g++, https://gcc.gnu.org/

```
apt install g++
```

- libz, https://zlib.net/

```
apt install libz-dev
```

- bowtie2, https://github.com/BenLangmead/bowtie2

```
apt install bowtie2
```

- HTSLIB 1.10.2, http://www.htslib.org/download/

```
wget https://github.com/samtools/htslib/releases/download/1.10.2/htslib-1.10.2.tar.bz2
tar -xjf htslib-1.10.2.tar.bz2
cd htslib-1.10.2/
./configure --prefix=/where/to/install
make
make install
export PATH=/where/to/install/bin:$PATH
```

- samtools (v1.10), http://www.htslib.org/download/

```
wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2
tar -xjf samtools-1.10.tar.bz2
cd samtools-1.10/
./configure --prefix=/where/to/install
make
make install
export PATH=/where/to/install/bin:$PATH
```

- bedtools (v2.25), https://github.com/arq5x/bedtools2/releases/tag/v2.25.0

  ***IMPORTANT NOTE: bedtools v2.26 or later isn't compatible with CHiCAGO! Please use v2.25 instead!!!***

```
wget https://github.com/arq5x/bedtools2/releases/download/v2.25.0/bedtools-2.25.0.tar.gz
tar -xzf bedtools-2.25.0.tar.gz
mv bedtools2 bedtools-2.25.0
cd bedtools-2.25.0
make
make install
export PATH=/where/to/install/bin:$PATH
```

- bcftools (v1.10.2), http://www.htslib.org/download/

```
wget https://github.com/samtools/bcftools/releases/download/1.10.2/bcftools-1.10.2.tar.bz2
tar -xjf bcftools-1.10.2.tar.bz2
cd bcftools-1.10.2
./configure --prefix=/where/to/install
make
make install
export PATH=/where/to/install/bin:$PATH
```

- deeptools, https://deeptools.readthedocs.io/en/develop/content/installation.html

```
conda install -c bioconda deeptools
```

## Usage (Command line options)
Arima-CHiC-v1.5.sh [-W run_hicup] [-Y run_bam2chicago] [-Z run_chicago] [-P run_plot]
              [-A bowtie2] [-X bowtie2_index_basename] [-d digest] [-H hicup_dir] [-C chicago_dir]
              [-I FASTQ_string] [-o out_dir] [-p output_prefix] [-b BED] [-R RMAP] [-B BAITMAP]
              [-D design_dir] [-O organism] [-r resolution] [-t threads] [-v] [-h]

      * [-W run_hicup]: "1" (default) to run HiCUP pipeline, "0" to skip. If skipping,
            HiCUP_summary_report_*.txt and *R1_2*.hicup.bam need to be in the HiCUP output folder.
      * [-Y run_bam2chicago]: "1" (default) to run bam2chicago.sh, "0" to skip
      * [-Z run_chicago]: "1" (default) to run CHiCAGO pipeline, "0" to skip
      * [-P run_plot]: "1" (default) to generate plots, "0" to skip
      * [-A bowtie2]: bowtie2 tool path
      * [-X bowtie2_index_basename]: bowtie2 index file prefix
      * [-d digest]: genome digest file produced by hicup_digester
      * [-H hicup_dir]: directory of the HiCUP tool
      * [-C chicago_dir]: directory of the CHiCAGO tool
      * [-I FASTQ_string]: a pair of FASTQ files separated by "," (no space is allowed)
      * [-o out_dir]: output directory
      * [-p output_prefix]: output file prefix (filename only, not including the path)
      * [-b BED]: the Arima capture probes design BED file for CHiCAGO
      * [-R RMAP]: CHiCAGO's *.rmap file
      * [-B BAITMAP]: CHiCAGO's *.baitmap file
      * [-D design_dir]: directory containing CHiCAGO's design files
            (exactly one of each: *.poe, *.npb, and *.nbpb)
      * [-O organism]: organism must be one of "hg19", "hg38", "mm9", or "mm10"
      * [-r resolution]: resolution of the loops called, must be one of
            "1f", "1kb", "3kb", or "5kb"
      * [-t threads]: number of threads to run HiCUP and CHiCAGO
      * [-v]: print version number and exit
      * [-h]: print this help and exit

## Arima Specific outputs

### Arima Shallow Sequencing QC

#### [output_directory]/[output_prefix]_Arima_QC_shallow.txt
Contents: This file includes QC metrics for assessing the shallow sequencing data for each CHiC library.
- Break down of the number of read pairs
- The target sequencing depth for deep sequencing
- The percentage of long-range cis interactions that overlap the probe regions

### Arima Deep Sequencing QC

#### [output_directory]/[output_prefix]_Arima_QC_deep.txt
Contents: This file includes QC metrics for assessing the deep sequencing data for each CHiC library.
- Break down of the number of read pairs
- The number of loops called
- The percentage of long-range cis interactions that overlap the probe regions

### Loops

#### [output_directory]/chicago/data/[output_prefix].cis_le_2Mb.bedpe
- Significant loops called by CHiCAGO

### Arima Arc Plots

#### [output_directory]/chicago/data/[output_prefix].cis_le_2Mb.arcplot.gz
- bgzipped arcplot file

#### [output_directory]/chicago/data/[output_prefix].cis_le_2Mb.arcplot.gz.tbi
- tabix index of the bgzipped arcplot file

These files can be viewed in the WashU EpiGenome Browser (http://epigenomegateway.wustl.edu/browser/). See the Arima-CHiC Analysis User Guide for more details.

### Metaplots

#### [output_directory]/chicago/data/[output_prefix].bigwig
- bigwig file of all mapped reads. This file can be used to view the sequencing coverage in a genome browser.

#### [output_directory]/chicago/data/[output_prefix].heatmap.pdf
- PDF of metaplot and heatmap of all mapped reads overlapping the probe regions used for loop calling. This file can be used to assess the signal to noise of the CHiC enrichment.


## Test Dataset (hg38)

25 and 100 million Illumina paired-end sequencing datasets and their pipeline output files (based on hg38) can be downloaded from:

ftp://ftp-arimagenomics.sdsc.edu/pub/ARIMA_Capture_HiC_Settings/test_data/

On the FTP ( ftp://ftp-arimagenomics.sdsc.edu/pub/ARIMA_Capture_HiC_Settings/ ), there are 4 pre-computed design folders: hg38, hg19, mm10, and mm9. For each genome build, there are three folders named: 1kb, 3kb and 5kb, which correspond to 1kb, 3kb and 5kb resolutions respectively. We found that after the binning, 5kb resolution provides the best replicate reproducibility and sensitivity. For each resolution, there are 7 files: three pre-computed design files (*.npb, *.poe and *.nbpb), one *.rmap, one *.baitmap, one *.baitmap_4col.txt and one CHiCAGO setting file.

It also contains a reference folder, with one reference FASTA file (\*.fa), one HiCUP digest file for Arima's dual-enzyme chemistry and six bowtie2 index files (\*.bt2) in it.

**Here is a detailed description of each file on our FTP.**

*hg38.fa*
- This is the genome reference file downloaded from UCSC table browser.

*Digest_hg38_Arima.txt*
- This is the HiCUP digest file for Arima's dual-enzyme chemistry, generated using the "hicup_digester" script from HiCUP pipeline.
- Reference: https://www.bioinformatics.babraham.ac.uk/projects/hicup/read_the_docs/html/index.html#arima-protocol

*hg38.1.bt2, hg38.2.bt2, hg38.3.bt2, hg38.4.bt2, hg38.rev.1.bt2, hg38.rev.2.bt2*
- These six files are are bowtie2 index files, generated using "bowtie2-build" script from Bowtie 2 pipeline.
- Reference: http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#the-bowtie2-build-indexer

*hg38_chicago_input_5kb.rmap*
- This is a tab-separated file of the format <chr> <start> <end> <numeric ID>, describing the restriction digest (or "virtual digest" if pooled fragments are used). These numeric IDs are referred to as "otherEndID" in CHiCAGO. All read fragments mapping outside of the digest coordinates will be disregarded.
- The file can be created using "create_baitmap_rmap.pl" script from CHiCAGO pipeline (with some pre-processing using custom scripts).
- Reference: https://bitbucket.org/chicagoTeam/chicago/src/master/chicagoTools/

*hg38_chicago_input_5kb.baitmap*
- This is a tab-separated file of the format <chr> <start> <end> <numeric ID> <annotation>, listing the coordinates of the baited/captured restriction fragments (should be a subset of the fragments listed in *.rmap file), their numeric IDs (should match those listed in *.rmap file for the corresponding fragments) and their annotations (such as, for example, the names of baited promoters). The numeric IDs are referred to as "baitID" in CHiCAGO.
- The file can be created using "create_baitmap_rmap.pl" script from CHiCAGO pipeline (with some pre-processing using custom scripts).
- Reference: https://bitbucket.org/chicagoTeam/chicago/src/master/chicagoTools/

*hg38_chicago_input_5kb.baitmap_4col.txt*
- This is the first 4 columns of the "hg38_chicago_input_5kb.baitmap" file.

*GW_PCHIC_hg38_5kb.nbpb, GW_PCHIC_hg38_5kb.npb, GW_PCHIC_hg38_5kb.poe*
- These three files are called design files in CHiCAGO pipeline. They are ASCII files containing the following information:
- NPerBin file (.npb): <baitID> <Total no. valid restriction fragments in distance bin 1> ... <Total no. valid restriction fragments in distance bin N>, where the bins map within the "proximal" distance range from each bait (0; maxLBrownEst] and bin size is defined by the binsize parameter.
- NBaitsPerBin file (.nbpb): <otherEndID> <Total no. valid baits in distance bin 1> ... <Total no. valid baits in distance bin N>, where the bins map within the "proximal" distance range from each other end (0; maxLBrownEst] and bin size is defined by the binsize parameter.
- Proximal Other End (ProxOE) file (.poe): <baitID> <otherEndID> <absolute distance> for all combinations of baits and other ends that map within the "proximal" distance range from each other (0; maxLBrownEst].
- These three files can be created using "makeDesignFiles_py3.py" script from CHiCAGO pipeline (with *rmap and *.baitmap as the input).
- Reference: https://bitbucket.org/chicagoTeam/chicago/src/master/chicagoTools/

*hicup.conf*
- This is the configuration file for HiCUP pipeline. Detailed descriptions on how to tune those parameters can be found at: https://www.bioinformatics.babraham.ac.uk/projects/hicup/read_the_docs/html/index.html#running-hicup

*chicago_settings_5kb.txt*
- This is the settings file for CHiCAGO pipeline. Detailed descriptions on how to tune those parameters can be found at: https://rdrr.io/bioc/Chicago/man/defaultSettings.html


## Arima Pipeline Version

1.5

## Support

For Arima customer support, please contact techsupport@arimagenomics.com

## Acknowledgments
#### Authors of HiCUP: https://www.bioinformatics.babraham.ac.uk/projects/hicup/

- Wingett S, et al. (2015) HiCUP: pipeline for mapping and processing Hi-C data F1000Research, 4:1310 (doi: 10.12688/f1000research.7334.1)

#### Authors of CHiCAGO: https://bioconductor.org/packages/release/bioc/html/Chicago.html

- Cairns J, Freire-Pritchett P, Wingett SW, Dimond A, Plagnol V, Zerbino D, Schoenfelder S, Javierre B, Osborne C, Fraser P, Spivakov M (2016). “CHiCAGO: Robust Detection of DNA Looping Interactions in Capture Hi-C data.” Genome Biology, 17, 127.
