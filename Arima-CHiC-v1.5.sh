#!/bin/bash

############################################################################
###                       Computing Environment                          ###
############################################################################

# Computing Resources: For shallow sequencing (5 - 20 million raw paired-end reads), the Arima Capture HiC pipeline (Arima-CHiC) requires 12 CPU cores with 48 GB RAM. The shallow sequencing analysis should complete in less than 2 hrs. For deep sequencing (200 – 600 million raw paired-end reads), we recommend 20 - 30 CPU cores with at least 80 - 120 GB RAM.  Samples with 200 million raw paired-end reads will run in about 48 hours with the recommended computational resources. Additional resources can be added to decrease the analysis time.

# Please install the following dependencies and add them to your PATH variable to ensure HiCUP and CHiCAGO will execute in your computing environment:
# IMPORTANT NOTE: bedtools v2.26 or later isn't compatible with CHiCAGO! Please use v2.25 instead!!!

# Dependencies:
# R 3.4.3 packages: argparse (v2.0.1)
# HTSLIB (v1.10.2)
# samtools (v1.10)
# bedtools (v2.25)
# bcftools (v1.10)
# deeptools

# See https://github.com/ArimaGenomics/CHiC for installation help

version="v1.5"
cwd=$(dirname $0)
############################################################################
###                         Arima CHiC pipeline                         ###
############################################################################

############################################################################
###                      Command Line Arguments                          ###
############################################################################
usage_Help="Usage: ${0##*/} [-W run_hicup] [-Y run_bam2chicago] [-Z run_chicago] [-P run_plot]
              [-A bowtie2] [-X bowtie2_index_basename] [-d digest] [-H hicup_dir] [-C chicago_dir]
              [-I FASTQ_string] [-o out_dir] [-p output_prefix] [-b BED] [-R RMAP] [-B BAITMAP]
              [-D design_dir] [-O organism] [-r resolution] [-t threads] [-v] [-h] \n"
run_hicup_Help="* [-W run_hicup]: \"1\" (default) to run HiCUP pipeline, \"0\" to skip. If skipping,
    HiCUP_summary_report_*.txt and *R1_2*.hicup.bam need to be in the HiCUP output folder."
run_bam2chicago_Help="* [-Y run_bam2chicago]: \"1\" (default) to run bam2chicago.sh, \"0\" to skip"
run_chicago_Help="* [-Z run_chicago]: \"1\" (default) to run CHiCAGO pipeline, \"0\" to skip"
run_plot_Help="* [-P run_plot]: \"1\" (default) to generate plots, \"0\" to skip"
bowtie2_Help="* [-A bowtie2]: bowtie2 tool path"
bowtie2_index_basename_Help="* [-X bowtie2_index_basename]: bowtie2 index file prefix"
digest_Help="* [-d digest]: genome digest file produced by hicup_digester"
hicup_dir_Help="* [-H hicup_dir]: directory of the HiCUP tool"
chicago_dir_Help="* [-C chicago_dir]: directory of the CHiCAGO tool"
FASTQ_string_Help="* [-I FASTQ_string]: a pair of FASTQ files separated by \",\" (no space is allowed)"
out_dir_Help="* [-o out_dir]: output directory"
output_prefix_Help="* [-p output_prefix]: output file prefix (filename only, not including the path)"
BED_Help="* [-b BED]: the Arima capture probes design BED file for CHiCAGO"
RMAP_Help="* [-R RMAP]: CHiCAGO's *.rmap file"
BAITMAP_Help="* [-B BAITMAP]: CHiCAGO's *.baitmap file"
design_dir_Help="* [-D design_dir]: directory containing CHiCAGO's design files (exactly one of each: *.poe, *.npb, and *.nbpb)"
organism_Help="* [-O organism]: organism must be one of \"hg19\", \"hg38\", \"mm9\", or \"mm10\""
#minFragLen_Help="* [-m minFragLen]: minFragLen and maxFragLen correspond to the limits within
#    which we observed no clear dependence between fragment length and the numbers
#    of reads mapping to these fragments in CHiC data"
#maxFragLen_Help="* [-M maxFragLen]: minFragLen and maxFragLen correspond to the limits within
#    which we observed no clear dependence between fragment length and the numbers
#    of reads mapping to these fragments in CHiC data"
resolution_Help="* [-r resolution]: resolution of the loops called, must be one of \"1f\", \"1kb\", \"3kb\", or \"5kb\""
#binsize_Help="* [-s binsize]: the bin size (in bases) used when estimating the Brownian collision
#    parameters. The bin size should, on average, include several (~4-5)
#    restriction fragments to increase the robustness of parameter estimation."
#minNPerBait_Help="* [-n minNPerBait]: minimum number of reads that a bait has to accumulate to be
#    included in the analysis. Default: 250"
#maxLBrownEst_Help="* [-L maxLBrownEst]: the distance range to be used for estimating the Brownian
#    component of the null model. The parameter setting should approximately
#    reflect the maximum distance, at which the power-law distance dependence is
#    still observable. Default: 1500000"
threads_Help="* [-t threads]: number of threads to run HiCUP and CHiCAGO"
version_Help="* [-v]: print version number and exit"
help_Help="* [-h]: print this help and exit"

printHelpAndExit() {
    echo -e "$usage_Help"
    echo -e "$run_hicup_Help"
    echo -e "$run_bam2chicago_Help"
    echo -e "$run_chicago_Help"
    echo -e "$run_plot_Help"
    echo -e "$bowtie2_Help"
    echo -e "$bowtie2_index_basename_Help"
    echo -e "$digest_Help"
    echo -e "$hicup_dir_Help"
    echo -e "$chicago_dir_Help"
    echo -e "$FASTQ_string_Help"
    echo -e "$out_dir_Help"
    echo -e "$output_prefix_Help"
    echo -e "$BED_Help"
    echo -e "$RMAP_Help"
    echo -e "$BAITMAP_Help"
    echo -e "$design_dir_Help"
    echo -e "$organism_Help"
#    echo -e "$minFragLen_Help"
#    echo -e "$maxFragLen_Help"
    echo -e "$resolution_Help"
#    echo -e "$binsize_Help"
#    echo -e "$minNPerBait_Help"
#    echo -e "$maxLBrownEst_Help"
    echo -e "$threads_Help"
    echo -e "$version_Help"
    echo -e "$help_Help"
    exit "$1"
}

printVersionAndExit() {
    echo "$version"
    exit 0
}
############################################################################
###                    Arima Recommended Parameters                      ###
############################################################################

# The parameter settings in this section are based on the default parameters for HiCUP and CHiCAGO with some minor adjustments. These parameters have been optimized by internal benchmarking using Arima's dual-enzyme chemistry.
run_hicup=1 # "1" to run HiCUP pipeline, "0" to skip
run_bam2chicago=1 # "1" to run bam2chicago.sh, "0" to skip
run_chicago=1 # "1" to run CHiCAGO pipeline, "0" to skip
run_plot=1 # "1" to generate plots, "0" to skip
resolution="5kb" # Resolution of the loops called, must be one of "1f", "1kb", "3kb", or "5kb"
minFragLen=4000 # minFragLen and maxFragLen correspond to the limits within which we observed no clear dependence between fragment length and the numbers of reads mapping to these fragments in CHiC data.
maxFragLen=6000 # minFragLen and maxFragLen correspond to the limits within which we observed no clear dependence between fragment length and the numbers of reads mapping to these fragments in CHiC data.
binsize=25000 # The bin size (in bases) used when estimating the Brownian collision parameters. The bin size should, on average, include several (~4-5) restriction fragments to increase the robustness of parameter estimation.
minNPerBait=250 # Minimum number of reads that a bait has to accumulate to be included in the analysis.
maxLBrownEst=2000000 # Default: 1500000. The distance range to be used for estimating the Brownian component of the null model. The parameter setting should approximately reflect the maximum distance, at which the power-law distance dependence is still observable.
threads=12 # number of threads to run HiCUP and CHiCAGO.

#if [ $organism == "hg19" ]; then
#  BED="GW_PC_S3207364_S3207414_hg19.uniq.bed"
  #genome_size=3095693983
#elif [ $organism == "hg38" ]; then
#  BED="GW_PC_S3207364_S3207414.uniq.bed"
  #genome_size=3088286401
#elif [ $organism == "mm9" ]; then
#  BED="mouse_GW_PC_S3207063_S3207103_mm9.uniq.bed"
  #genome_size=2654911517
#elif [ $organism == "mm10" ]; then
#  BED="mouse_GW_PC_S3207063_S3207103.uniq.bed"
  #genome_size=2725537669
#fi

while getopts "A:B:b:C:d:D:hH:I:O:o:P:p:R:r:t:vW:X:Y:Z:" opt; do
    case $opt in
    h) printHelpAndExit 0;;
    v) printVersionAndExit 0;;
    W) run_hicup=$OPTARG ;;
    Y) run_bam2chicago=$OPTARG ;;
    Z) run_chicago=$OPTARG ;;
    P) run_plot=$OPTARG ;;
    A) bowtie2=$OPTARG ;;
    X) bowtie2_index_basename=$OPTARG ;;
    d) digest=$OPTARG ;;
    H) hicup_dir=$OPTARG ;;
    C) chicago_dir=$OPTARG ;;
    I) FASTQ_string=$OPTARG ;;
    o) out_dir=$OPTARG ;;
    p) output_prefix=$OPTARG ;;
    b) BED=$OPTARG ;;
    R) RMAP=$OPTARG ;;
    B) BAITMAP=$OPTARG ;;
    D) design_dir=$OPTARG ;;
    O) organism=$OPTARG ;;
    # m) minFragLen=$OPTARG ;;
    # M) maxFragLen=$OPTARG ;;
    r) resolution=$OPTARG ;;
    # s) binsize=$OPTARG ;;
    # n) minNPerBait=$OPTARG ;;
    # L) maxLBrownEst=$OPTARG ;;
    t) threads=$OPTARG ;;
    [?]) printHelpAndExit 1;;
    esac
done

# Sanity checks
#hash Rscript &> /dev/null
command -v Rscript &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "Could not find R. Please install or include it into the \"PATH\" variable!"
    printHelpAndExit 1
fi

#hash samtools &> /dev/null
command -v samtools &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "Could not find samtools. Please install or include it into the \"PATH\" variable!"
    printHelpAndExit 1
fi

#hash bedtools &> /dev/null
command -v bedtools &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "Could not find bedtools. Please install or include it into the \"PATH\" variable!"
    printHelpAndExit 1
fi

#hash bgzip &> /dev/null
command -v bgzip &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "Could not find bgzip. Please install or include it into the \"PATH\" variable!"
    printHelpAndExit 1
fi

#hash tabix &> /dev/null
command -v tabix &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "Could not find tabix. Please install or include it into the \"PATH\" variable!"
    printHelpAndExit 1
fi

#hash deeptools &> /dev/null
command -v deeptools &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "Could not find deeptools. Please install or include it into the \"PATH\" variable!"
    printHelpAndExit 1
fi

if ! [[ "$run_hicup" == "0" || "$run_hicup" == "1" ]]; then
    echo "The argument \"run_hicup\" must be either 0 or 1 (-W)!"
    printHelpAndExit 1
fi

if ! [[ "$run_bam2chicago" == "0" || "$run_bam2chicago" == "1" ]]; then
    echo "The argument \"run_bam2chicago\" must be either 0 or 1 (-Y)!"
    printHelpAndExit 1
fi

if ! [[ "$run_chicago" == "0" || "$run_chicago" == "1" ]]; then
    echo "The argument \"run_chicago\" must be either 0 or 1 (-Z)!"
    printHelpAndExit 1
fi

if ! [[ "$run_plot" == "0" || "$run_plot" == "1" ]]; then
    echo "The argument \"run_plot\" must be either 0 or 1 (-P)!"
    printHelpAndExit 1
fi

if [ ! -x "$bowtie2" ]; then
    echo "Please provide a correct bowtie2 tool path (-A)!"
    printHelpAndExit 1
fi

if [ ! -d "$hicup_dir" ]; then
    echo "Please provide the directory of the HiCUP tool (-H)!"
    printHelpAndExit 1
fi

if [ ! -d "$chicago_dir" ]; then
    echo "Please provide the directory of the CHiCAGO tool (-C)!"
    printHelpAndExit 1
fi

if [ ! -f "$BED" ]; then
    echo "Please provide a correct Arima capture probes design BED file for CHiCAGO (-b)!"
    printHelpAndExit 1
fi

if [ ! -f "$RMAP" ]; then
    echo "Please provide a correct RMAP for CHiCAGO (-R)!"
    printHelpAndExit 1
fi

if [ ! -f "$BAITMAP" ]; then
    echo "Please provide a correct BAITMAP for CHiCAGO (-B)!"
    printHelpAndExit 1
fi

if [ ! -d "$design_dir" ]; then
    echo "Please provide the correct folder containing design files for CHiCAGO (-D)!"
    printHelpAndExit 1
elif ! [[ `ls $design_dir/*.poe 2> /dev/null | wc -l` -eq 1 && `ls $design_dir/*.npb 2> /dev/null | wc -l` -eq 1 && `ls $design_dir/*.nbpb 2> /dev/null | wc -l` -eq 1 ]]; then
    echo "Please provide exactly one of each: *.poe, *.npb and *.nbpb in the design folder (-D)"
    printHelpAndExit 1
fi

if [ -z "$organism" ]; then
    echo "Please provide an organism (-O)!"
    printHelpAndExit 1
elif [[ $organism != "hg19" && $organism != "hg38" && $organism != "mm9" && $organism != "mm10" ]]; then
    echo "The organism must be one of \"hg19\", \"hg38\", \"mm9\", or \"mm10\" (-O)!"
    printHelpAndExit 1
fi

if [[ -z "$bowtie2_index_basename" || `ls $bowtie2_index_basename.* 2> /dev/null | wc -l` -eq 0 ]]; then
    echo "Please provide a correct bowtie2 index file prefix (-X)!"
    printHelpAndExit 1
fi

if [ ! -f "$digest" ]; then
    echo "Please provide a correct genome digest file produced by hicup_digester (-d)!"
    printHelpAndExit 1
fi

if [ -z "$FASTQ_string" ]; then
    echo "Please provide a pair of FASTQ files separated by \",\" only (no space) (-I)!"
    printHelpAndExit 1
else
    IFS=',' read -a FASTQ <<< "$FASTQ_string"
    for i in "${FASTQ[@]}"; do
        if [ ! -f "$i" ]; then
            echo "$i does not exist (-I)!"
            printHelpAndExit 1
        fi
    done
fi

if [ -z "$out_dir" ]; then
    echo "Please provide an output directory (-o)!"
    printHelpAndExit 1
fi

if [ -z "$output_prefix" ]; then
    echo "Please provide an output file prefix (-p)!"
    printHelpAndExit 1
fi

if [ -z "$resolution" ]; then
    echo "Please provide a resolution for CHiCAGO (-r)!"
    printHelpAndExit 1
else
    if [[ "$resolution" == "1f" ]]; then
        minFragLen=10
        maxFragLen=1000
        binsize=1000
        maxLBrownEst=1500000
    elif [[ "$resolution" == "1kb" ]]; then
        minFragLen=800
        maxFragLen=1200
        binsize=5000
        maxLBrownEst=1500000
    elif [[ "$resolution" == "3kb" ]]; then
        minFragLen=2400
        maxFragLen=3600
        binsize=15000
        maxLBrownEst=1500000
    elif [[ "$resolution" == "5kb" ]]; then
        minFragLen=4000
        maxFragLen=6000
        binsize=25000
        maxLBrownEst=2000000
    else
        echo "The resolution string must be one of \"1f\", \"1kb\", \"3kb\", or \"5kb\" (-r)!"
        printHelpAndExit 1
    fi
fi

if [ -z "$binsize" ]; then
    echo "Please provide a binsize for CHiCAGO (-s)!"
    printHelpAndExit 1
elif ! [[ "$binsize" =~ ^[0-9]+$ ]]; then
    echo "The binsize must be an integer (-s)!"
    printHelpAndExit 1
fi

if [ -z "$minFragLen" ]; then
    echo "Please provide a minFragLen for CHiCAGO (-m)!"
    printHelpAndExit 1
elif ! [[ "$minFragLen" =~ ^[0-9]+$ ]]; then
    echo "The minFragLen must be an integer (-s)!"
    printHelpAndExit 1
fi

if [ -z "$maxFragLen" ]; then
    echo "Please provide a maxFragLen for CHiCAGO (-M)!"
    printHelpAndExit 1
elif ! [[ "$maxFragLen" =~ ^[0-9]+$ ]]; then
    echo "The maxFragLen must be an integer (-s)!"
    printHelpAndExit 1
fi

if ! [[ "$minNPerBait" =~ ^[0-9]+$ ]]; then
    echo "The minNPerBait must be an integer (-n)!"
    printHelpAndExit 1
fi

if ! [[ "$maxLBrownEst" =~ ^[0-9]+$ ]]; then
    echo "The maxLBrownEst must be an integer (-L)!"
    printHelpAndExit 1
fi

if ! [[ "$threads" =~ ^[0-9]+$ ]]; then
    echo $threads
    echo "The # of threads must be an integer (-t)!"
    printHelpAndExit 1
fi

# output_prefix=$(basename ${FASTQ[0]} | sed 's/^\(.*\)[._]R1.f.*q.*$/\1/')

out_hicup=$out_dir"/hicup/"
out_chicago=$out_dir"/chicago/"
out_bam2chicago=$out_dir"/bam2chicago/"
[ -d "$out_dir" ] || mkdir -p $out_dir
[ -d "$out_hicup" ] || mkdir -p $out_hicup
[ -d "$out_chicago" ] || mkdir -p $out_chicago
[ -d "$out_bam2chicago" ] || mkdir -p $out_bam2chicago

hicup_config=$out_hicup"/hicup.conf"
if [ ! -f $cwd"/utils/hicup_example.conf" ]; then
    echo "ERROR: Missing hicup_example.conf file in $cwd/utils/"
    exit 1
fi
cp $cwd"/utils/hicup_example.conf" $hicup_config
chmod +w $hicup_config

sed -r -i -e "s@\[OUT_DIR\]@$out_hicup@" -e "s@\[THREADS\]@$threads@" -e "s@\[bowtie2_toolpath\]@$bowtie2@" -e "s@\[bowtie2_index_basename\]@$bowtie2_index_basename@" -e "s@\[DIGEST_FILE\]@$digest@" -e "s@\[FASTQ_R1\]@${FASTQ[0]}@" -e "s@\[FASTQ_R2\]@${FASTQ[1]}@" $hicup_config

chicago_settings=$out_chicago"/chicago_settings_"${resolution}".txt"

TAB=$'\t'
cat <<- EOF | sed -r -e "s@V1@$minFragLen@" -e "s@V2@$maxFragLen@" -e "s@V3@$binsize@" -e "s@V4@$minNPerBait@" -e "s@V5@$maxLBrownEst@" > $chicago_settings
minFragLen${TAB}V1
maxFragLen${TAB}V2
binsize${TAB}V3
minNPerBait${TAB}V4
maxLBrownEst${TAB}V5
EOF

echo "Running: $0 [$version]"
echo "Command: $0 $@"
echo
echo "User Defined Inputs:"
echo run_hicup=$run_hicup
echo run_bam2chicago=$run_bam2chicago
echo run_chicago=$run_chicago
echo run_plot=$run_plot
echo bowtie2=$bowtie2
echo bowtie2_index_basename=$bowtie2_index_basename
echo hicup_dir=$hicup_dir
echo chicago_dir=$chicago_dir
echo digest=$digest
echo hicup_config=$hicup_config
echo FASTQ_string=$FASTQ_string
echo out_dir=$out_dir
echo out_hicup=$out_hicup
echo out_bam2chicago=$out_bam2chicago
echo out_chicago=$out_chicago
echo output_prefix=$output_prefix
echo BED=$BED
echo RMAP=$RMAP
echo BAITMAP=$BAITMAP
echo design_dir=$design_dir
echo chicago_settings=$chicago_settings
echo organism=$organism
echo minFragLen=$minFragLen
echo maxFragLen=$maxFragLen
echo resolution=$resolution
echo binsize=$binsize
echo minNPerBait=$minNPerBait
echo maxLBrownEst=$maxLBrownEst
echo threads=$threads
echo

############################################################################
###                           CHiC Pipeline                             ###
############################################################################

if [ "$run_hicup" -eq 0 ]; then
    echo "Skipping HiCUP pipeline and using previous HiCUP output from $out_hicup"
else
    timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    echo "Running HiCUP [$timestamp] ..."
    echo "$hicup_dir/hicup --config $hicup_config &> $out_hicup/hicup.log"
    $hicup_dir"/hicup" --config $hicup_config &> $out_hicup"/hicup.log"
    timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    echo "Finished running HiCUP! [$timestamp]"
fi

hicup_output_bam=$out_hicup"/*R1_2*.hicup.bam"
if [ `ls $hicup_output_bam 2> /dev/null | wc -l` -ne 1 ]; then
    echo "ERROR: There should be exactly one *R1_2*.hicup.bam file in the HiCUP output!"
    exit 1
fi

hicup_output_bam_string=`echo $hicup_output_bam`
echo -e "HiCUP output: $hicup_output_bam_string\n"

#hicup_stat_1=$out_hicup"/hicup_truncater_summary_*.txt"
#hicup_stat_2=$out_hicup"/hicup_mapper_summary_*.txt"
#hicup_stat_3=$out_hicup"/hicup_filter_summary_*.txt"
#hicup_stat_4=$out_hicup"/hicup_deduplicator_summary_*.txt"
hicup_summary_report=$out_hicup"/HiCUP_summary_report_*.txt"

if [[ `ls $hicup_summary_report 2> /dev/null | wc -l` -ne 1 ]]; then
    echo "ERROR: There should be exactly one HiCUP_summary_report_*.txt file in the HiCUP output!"
    exit 1
fi

raw_R1=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f2 )
raw_R2=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f3 )
raw_pairs=$(( ($raw_R1 + $raw_R2)/2 ))

if [ "$run_bam2chicago" -eq 0 ]; then
    echo "Skipping bam2chicago.sh and using previous HiCUP output from $out_hicup and $output_prefix.chinput from $out_bam2chicago/$output_prefix/"
else
    timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    echo "Converting HiCUP output to CHiCAGO input using resolution $resolution [$timestamp] ..."
    bam2chicago_log=$out_bam2chicago"/bam2chicago_"${output_prefix}"_"${resolution}".log"
    echo "bash $chicago_dir/bam2chicago.sh $hicup_output_bam_string $BAITMAP $RMAP $out_bam2chicago/$output_prefix &> $bam2chicago_log"
    bash $chicago_dir"/bam2chicago.sh" $hicup_output_bam_string $BAITMAP $RMAP $out_bam2chicago"/"$output_prefix &> $bam2chicago_log
    timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    echo "Finished converting! [$timestamp]"
fi

chinput=$out_bam2chicago"/"$output_prefix"/"$output_prefix".chinput"
if [ ! -f "$chinput" ]; then
    echo "ERROR: No *.chinput file can be found in $out_bam2chicago/$output_prefix/"
    echo "bam2chicago was not finished successfully. Please check the log file."
    exit 1
fi

echo -e "CHiCAGO input: $chinput\n"

if [ "$run_chicago" -eq 0 ]; then
    echo "Skipping CHiCAGO pipeline and using previous HiCUP output from $out_hicup and CHiCAGO output from $out_chicago/data/"
else
    timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    echo "Running CHiCAGO using resolution $resolution [$timestamp] ..."
    chicago_log=$out_chicago"/runChicago_"${output_prefix}"_"${resolution}".log"
    echo "Rscript $chicago_dir/runChicago.R --print-memory --settings-file $chicago_settings --export-format seqMonk,interBed,washU_text,washU_track --design-dir $design_dir --output-dir $out_chicago $chinput $output_prefix &> $chicago_log"
    Rscript $chicago_dir"/runChicago.R" --print-memory --settings-file $chicago_settings --export-format seqMonk,interBed,washU_text,washU_track --design-dir $design_dir --output-dir $out_chicago $chinput $output_prefix &> $chicago_log
    timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    echo -e "Finished running CHiCAGO! [$timestamp]\n"
fi

plot_dir=$out_chicago"/data/"
washU_text=$plot_dir/${output_prefix}"_washU_text.txt"
washU_track=$plot_dir/${output_prefix}"_washU_track.txt"
washU_track_gz=$plot_dir/${output_prefix}"_washU_track.txt.gz"
washU_track_gz_tbi=$plot_dir/${output_prefix}"_washU_track.txt.gz.tbi"
loop_file=$plot_dir"/"${output_prefix}".bedpe"
loop_file_cis_le_2Mb=$plot_dir"/"${output_prefix}".cis_le_2Mb.bedpe"

if [[ ! -f "$washU_text" || ! -f "$washU_track" ]]; then
    echo "Warning: No *_washU_text.txt or *_washU_track.txt file can be found in $plot_dir"
    echo "CHiCAGO was not finished successfully."
    echo "Do you have enough reads? Number of raw read-pairs: $raw_pairs"
    echo -e "Please check the CHiCAGO log file: $chicago_log\n"

    chicago_failed=1
    # exit 1
else
    # All interactions
    echo "Arcplot files for WashU EpiGenome Browser (all interactions):"
    echo $washU_track_gz
    echo $washU_track_gz_tbi

    # All loops
    sed 's/[:,-]/\t/g' $washU_text | cut -f1-7 > $loop_file
    echo "All loops in *.bedpe format:"
    echo -e "$loop_file\n"

    # Keep only those intra-chromosomal interactions that are <= 2Mb
    awk -v FS=",|\t" -v OFS="\t" 'BEGIN {print "chr1","start1","end1","chr2","start2","end2","fdr"} {if($1==$4 && ($6+$5)/2 - ($3+$2)/2 <= 2000000 && ($6+$5)/2 - ($3+$2)/2 >= -2000000) print $1,$2,$3,$4,$5,$6,$7}' $washU_text > $plot_dir"/"${output_prefix}".cis_le_2Mb.longrange"
    Rscript $cwd"/utils/bedpe2tabix.R" -i $plot_dir"/"${output_prefix}".cis_le_2Mb.longrange" -t $plot_dir"/"${output_prefix}".cis_le_2Mb.arcplot" > /dev/null
    echo "Arcplot files for WashU EpiGenome Browser (cis <= 2Mb):"
    echo "$plot_dir/${output_prefix}.cis_le_2Mb.arcplot.gz"
    echo "$plot_dir/${output_prefix}.cis_le_2Mb.arcplot.gz.tbi"

    # Keep only those loops that are <= 2Mb
    grep -v fdr $plot_dir"/"${output_prefix}".cis_le_2Mb.longrange" > $loop_file_cis_le_2Mb
    echo "cis <= 2Mb loops in *.bedpe format:"
    echo -e "$loop_file_cis_le_2Mb\n"
fi

if [ "$run_plot" -eq 1 ]; then
    timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    echo "Generating metaplot and heatmap images [$timestamp] ..."

    [ -d "$plot_dir" ] || mkdir -p $plot_dir
    bam_file_sorted=$( echo $hicup_output_bam_string | sed 's/^\(.*\)_R1_2.*\.hicup\.bam$/\1_R1_2.hicup.sorted.bam/' )
    bigwig_file=$plot_dir"/"$output_prefix".bigwig"
    matrix_file=$plot_dir"/"$output_prefix".matrix.tab.gz"
    #metaplot=$plot_dir"/"$output_prefix".metaplot.pdf"
    heatmap=$plot_dir"/"$output_prefix".heatmap.pdf"

    echo "Sorting and creating index for the bam file ..."
    samtools sort -T $out_dir"/sorting_tempfile" -@ $threads $hicup_output_bam_string -o $bam_file_sorted 2> /dev/null
    samtools index -@ $threads $bam_file_sorted

    echo "Generating coverage bigwig file from sequencing reads ..."
    bamCoverage \
    --bam $bam_file_sorted \
    --outFileName $bigwig_file \
    --outFileFormat bigwig \
    --ignoreDuplicates \
    --numberOfProcessors max \
    2> /dev/null

    # Generate a matrix file with +/- 5kb from baited regions in the baitmap
    ###computeMatrix reference-point###
    echo "Generating coverage matrix file ..."
    computeMatrix scale-regions \
    --scoreFileName $bigwig_file \
    --regionsFileName $BAITMAP \
    --regionBodyLength 100 \
    --beforeRegionStartLength 5000 \
    --afterRegionStartLength 5000 \
    --binSize 5 \
    --outFileName $matrix_file \
    --numberOfProcessors max

    # Use plotHeatmap to plot a heatmap of the average of the matrix
    echo "Generating heatmap image ..."
    plotHeatmap \
    --matrixFile $matrix_file \
    --outFileName $heatmap \
    --xAxisLabel "" \
    --yAxisLabel "Coverage" \
    --refPointLabel "Probe Regions" \
    --regionsLabel $output_prefix \
    --startLabel "" \
    --endLabel "" \
    --samplesLabel "Signal Enrichment at Capture Regions" \
    --colorList "white,darkblue" \
    --heatmapHeight 12 \
    --yMin 0

    #enrichment=$(zcat $matrix_file | awk -F $'\t' 'BEGIN {background = 0; peak = 0} {background = background + $7; peak = peak + ($1016+$1017)/2} END {enrichment = peak / background; printf("%.2f", enrichment)}');

    timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    echo -e "Finished making metaplot and heatmap images in $plot_dir [$timestamp]\n"

    # Make 4C plots!!!
    #timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    #echo "Generating 4C plots [$timestamp] ..."

    #timestamp=`date '+%Y/%m/%d %H:%M:%S'`
    #echo -e "Finished making 4C plots in $plot_dir [$timestamp]\n"
fi

############################################################################
###               Arima Genomics Post-processing and QC                  ###
############################################################################
timestamp=`date '+%Y/%m/%d %H:%M:%S'`
echo "Post-processing by Arima Genomics [$timestamp] ..."

if [ -f "$loop_file_cis_le_2Mb" ]; then
    total_loops=`grep -v "start1" $loop_file_cis_le_2Mb | wc -l`
else
    total_loops=0
fi

uniq_mapped_R1=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f12 )
uniq_mapped_R2=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f13 )
uniq_mapped_SE=$(( $uniq_mapped_R1 + $uniq_mapped_R2 ))

multi_mapped_R1=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f14 )
multi_mapped_R2=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f15 )
multi_mapped_SE=$(( $multi_mapped_R1 + $multi_mapped_R2 ))

mapped_SE=$(( $uniq_mapped_SE + $multi_mapped_SE ))
mapped_p=`echo "scale=4; 100 * $mapped_SE / $raw_pairs / 2" | bc | awk '{ printf("%.1f", $0) }'`

total_pairs=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f18 )
valid_pairs=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f20 )
uniq_valid_pairs=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f31 )
duplicated_pairs=$(( $valid_pairs - $uniq_valid_pairs ))

# Modified based on the metrics definition spreadsheet, but is inconsistent with HiCUP summary report output!
uniq_valid_pairs_p=`echo "scale=4; 100 * $uniq_valid_pairs / $total_pairs" | bc | awk '{ printf("%.1f", $0) }'`
duplicated_pairs_p=`echo "scale=4; 100 * $duplicated_pairs / $total_pairs" | bc | awk '{ printf("%.1f", $0) }'`

# Change the calculation of %Lcis. Use "uniq_total_pairs" as the denominator (Modified in v1.5).
uniqueness_rate=`echo "scale=9; $uniq_valid_pairs / $valid_pairs" | bc | awk '{ printf("%.9f", $0) }'`
#invalid_pairs=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f24 )
#uniq_invalid_pairs=`echo "scale=4; $invalid_pairs * $uniqueness_rate + 0.5" | bc | awk '{ printf("%d", $0) }'`
uniq_total_pairs=`echo "scale=4; $total_pairs * $uniqueness_rate + 0.5" | bc | awk '{ printf("%d", $0) }'`

inter_pairs=$( head $hicup_summary_report | grep -v "Total_Reads_1" | head -1 | cut -f34 )
# Modified in v1.5
inter_pairs_p=`echo "scale=4; 100 * $inter_pairs / $uniq_total_pairs" | bc | awk '{ printf("%.1f", $0) }'`
# Modified in v1.5
intra_pairs=$(( $uniq_total_pairs - $inter_pairs ))
# Modified in v1.5
intra_pairs_p=`echo "scale=4; 100 * $intra_pairs / $uniq_total_pairs" | bc | awk '{ printf("%.1f", $0) }'`

# Calculate long cis from HiCUP BAM file
hicup_output_bam_bedpe=${hicup_output_bam_string%.bam}.original.bedpe
if [ ! -f "$hicup_output_bam_bedpe" ]; then
    bedtools bamtobed -i $hicup_output_bam_string -bedpe > $hicup_output_bam_bedpe
fi
intra_ge_15kb_pairs=$( awk '{ if($1==$4 && ($5+$6)/2 - ($2+$3)/2 >= 15000) intra_ge_15kb++ } END { print intra_ge_15kb }' $hicup_output_bam_bedpe )
# Modified in v1.5
intra_ge_15kb_pairs_p=`echo "scale=4; 100 * $intra_ge_15kb_pairs / $uniq_total_pairs" | bc | awk '{ printf("%.1f", $0) }'`

Lcis_trans_ratio=`echo "scale=2; $intra_ge_15kb_pairs / $inter_pairs" | bc | awk '{ printf("%.1f", $0) }'`

timestamp=`date '+%Y/%m/%d %H:%M:%S'`
echo "Calculating on-target rate [$timestamp] ..."

# Calculate % on-target
genome_size=$( awk '{ if($7=="None") sum+=$3 } END { printf("%d", sum) }' $digest )

hicup_bam_extended_srt_bedpe=${hicup_output_bam_string%.bam}.extended.srt.bedpe
if [ ! -f "$hicup_bam_extended_srt_bedpe" ]; then
    awk '{ {if($9=="+") $3=$3+275} {if($9=="-") $2=$2-275} {if($10=="+") $6=$6+275} {if($10=="-") $5=$5-275} print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6 }' $hicup_output_bam_bedpe | sort -V > $hicup_bam_extended_srt_bedpe
fi

on_target=$( bedtools pairtobed -f 0 -a $hicup_bam_extended_srt_bedpe -b $BED -type "either" | cut -f1-6 | uniq | wc -l )
# off_target=$( bedtools pairtobed -f 0 -a $hicup_bam_extended_srt_bedpe -b $BED -type "neither" | cut -f1-6 | uniq | wc -l )
on_target_p=`echo "scale=4; 100 * $on_target / $uniq_valid_pairs" | bc | awk '{ printf("%.1f", $0) }'`
ALL=$uniq_valid_pairs  # $( cat $hicup_bam_extended_srt_bedpe | wc -l )
off_target=$(( $ALL - $on_target ))

# Calculate % Long-cis on-target
# hicup_bam_lcis_extended_srt_bedpe=${hicup_output_bam_string%.bam}.lcis.extended.srt.bedpe
# bedtools bamtobed -i $hicup_output_bam_string -bedpe | awk '{ if($1==$4 && ($5+$6)/2 - ($2+$3)/2 >= 15000) print }' | awk '{ {if($9=="+") $3=$3+275} {if($9=="-") $2=$2-275} {if($10=="+") $6=$6+275} {if($10=="-") $5=$5-275} print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6 }' | sort -V > $hicup_bam_lcis_extended_srt_bedpe
# lcis_on_target=$( bedtools pairtobed -f 0 -a $hicup_bam_lcis_extended_srt_bedpe -b $BED -type "either" | cut -f1-6 | sort -uV | wc -l )
# lcis_on_target_p=`echo "scale=4; 100 * $lcis_on_target / $intra_ge_15kb_pairs" | bc | awk '{ printf("%.1f", $0) }'`

# Estimated, needs to be updated
target_raw_pairs="100000000"

timestamp=`date '+%Y/%m/%d %H:%M:%S'`
echo -e "Finished calculating on-target rate. [$timestamp]\n"

timestamp=`date '+%Y/%m/%d %H:%M:%S'`
echo "Calculating enrichment score [$timestamp] ..."

# Use the updated enrichment score calculation!
# sed -e 's/chrx/chrX/g' -e 's/chry/chrY/g' -e 's/chrm/chrM/g' -e 's/"//g' $BED | cut -f4 | sed 's/,/\n/g' | sed 's/[:-]/\t/g' | sort -uV > $region_list
target_size=$( cat $BED | awk '{ sum+=$3-$2 } END { printf("%d", sum) }' )
off_target_size=$(( $genome_size - $target_size ))

background_RPKM=`echo "scale=16; $off_target * (1000 / $off_target_size) * (1000000 / $ALL)" | bc | awk '{ printf("%.10f", $0) }'`

hicup_bam_extended_srt_bedpe_enrichment_bed=${hicup_bam_extended_srt_bedpe%.srt.bedpe}.enrichment.srt.bed
if [ ! -f "$hicup_bam_extended_srt_bedpe_enrichment_bed" ]; then
    echo -e "# Genome size = $genome_size\n# Target size = $target_size\n# Off-target size = $off_target_size\n# Total reads = $ALL\n# Off-target reads = $off_target\n# Background RPKM = $background_RPKM\n# Chr\tStart\tEnd\tCount\tRegion_size\tRPKM\tEnrichment" > $hicup_bam_extended_srt_bedpe_enrichment_bed

    bedtools pairtobed -f 0 -a $hicup_bam_extended_srt_bedpe -b $BED -type "either" | cut -f7-9 | sort -V | uniq -c | awk -v all_reads=$ALL -v off_target=$off_target -v off_target_size=$off_target_size -v background_RPKM=$background_RPKM '{ len=$4-$3; count=$1; RPKM = count * (1000 / len) * (1000000 / all_reads); enrichment = RPKM / background_RPKM; print $2"\t"$3"\t"$4"\t"$1"\t"len"\t"RPKM"\t"enrichment }' | sort -V >> $hicup_bam_extended_srt_bedpe_enrichment_bed
fi

echo genome_size=$genome_size
echo target_size=$target_size
echo off_target_size=$off_target_size
echo ALL=$ALL
echo on_target=$on_target
echo off_target=$off_target
echo on_target_p=$on_target_p
#echo lcis_on_target=$lcis_on_target
#echo lcis_on_target_p=$lcis_on_target_p
echo background_RPKM=$background_RPKM
enrichment=$(( $off_target_size * $on_target / $target_size / $off_target ))

timestamp=`date '+%Y/%m/%d %H:%M:%S'`
echo -e "Finished calculating enrichment score. [$timestamp]\n"

echo output_prefix=$output_prefix
echo raw_R1=$raw_R1
echo raw_R2=$raw_R2
echo raw_pairs=$raw_pairs
echo uniq_mapped_R1=$uniq_mapped_R1
echo uniq_mapped_R2=$uniq_mapped_R2
echo uniq_mapped_SE=$uniq_mapped_SE
echo multi_mapped_R1=$multi_mapped_R1
echo multi_mapped_R2=$multi_mapped_R2
echo multi_mapped_SE=$multi_mapped_SE
echo mapped_SE=$mapped_SE
echo mapped_p=$mapped_p

echo total_pairs=$total_pairs
echo valid_pairs=$valid_pairs
echo uniq_total_pairs=$uniq_total_pairs
echo uniq_valid_pairs=$uniq_valid_pairs
echo uniqueness_rate=$uniqueness_rate
echo duplicated_pairs=$duplicated_pairs
echo duplicated_pairs_p=$duplicated_pairs_p
echo uniq_valid_pairs_p=$uniq_valid_pairs_p

echo inter_pairs=$inter_pairs
echo inter_pairs_p=$inter_pairs_p
echo intra_pairs=$intra_pairs
echo intra_pairs_p=$intra_pairs_p
echo intra_ge_15kb_pairs=$intra_ge_15kb_pairs
echo intra_ge_15kb_pairs_p=$intra_ge_15kb_pairs_p
echo Lcis_trans_ratio=$Lcis_trans_ratio

echo total_loops=$total_loops
echo target_raw_pairs=$target_raw_pairs
printf "Enrichment score = %.2f\n" $enrichment

# Write QC tables
QC_result_deep=$out_dir"/"$output_prefix"_Arima_QC_deep.txt"
QC_result_shallow=$out_dir"/"$output_prefix"_Arima_QC_shallow.txt"

header_deep=("Sample_name" "Raw_pairs" "Mapped_SE_reads" "%_Mapped_SE_reads" "Duplicated_pairs" "%_Duplicated_pairs" "Unique_valid_pairs" "%_Unique_valid_pairs" "Intra_pairs" "%_Intra_pairs" "Intra_ge_15kb_pairs" "%_Intra_ge_15kb_pairs" "Inter_pairs" "%_Inter_pairs" "%_on-target" "Enrichment" "Loops")
IFS=$'\t'; echo "${header_deep[*]}" > $QC_result_deep

result_deep=($output_prefix $raw_pairs $mapped_SE $mapped_p $duplicated_pairs $duplicated_pairs_p $uniq_valid_pairs $uniq_valid_pairs_p $intra_pairs $intra_pairs_p $intra_ge_15kb_pairs $intra_ge_15kb_pairs_p $inter_pairs $inter_pairs_p $on_target_p $enrichment $total_loops)
IFS=$'\t'; echo "${result_deep[*]}" >> $QC_result_deep

header_shallow=("Sample_name" "Raw_pairs" "Mapped_SE_reads" "%_Mapped_SE_reads" "Duplicated_pairs" "%_Duplicated_pairs" "Unique_valid_pairs" "%_Unique_valid_pairs" "Intra_pairs" "%_Intra_pairs" "Intra_ge_15kb_pairs" "%_Intra_ge_15kb_pairs" "Inter_pairs" "%_Inter_pairs" "%_on-target" "Enrichment" "Target_raw_pairs")
IFS=$'\t'; echo "${header_shallow[*]}" > $QC_result_shallow

result_shallow=($output_prefix $raw_pairs $mapped_SE $mapped_p $duplicated_pairs $duplicated_pairs_p $uniq_valid_pairs $uniq_valid_pairs_p $intra_pairs $intra_pairs_p $intra_ge_15kb_pairs $intra_ge_15kb_pairs_p $inter_pairs $inter_pairs_p $on_target_p $enrichment $target_raw_pairs)
IFS=$'\t'; echo "${result_shallow[*]}" >> $QC_result_shallow

timestamp=`date '+%Y/%m/%d %H:%M:%S'`
echo -e "\nArima CHiC pipeline finished successfully! [$timestamp]"
echo "Please download the QC result from: $QC_result_deep $QC_result_shallow and then copy the contents to the corresponding tables in the QC worksheet."

exit 0
