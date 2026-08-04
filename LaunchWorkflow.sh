#!/usr/bin/env bash

# SETUP 

# specify help message
showHelp() {

cat << EOF  
Usage: $(basename $SCRIPT) -s <system> -p <parameters> -i <inputs> -x <branch> [-w <workDir> -o <outputDir> -r <launchDir> -a <archiveDir> -c -t -q SUPPLEMENTARY=NAME]

-h     Display help.

-s     Specify nextflow config system profile name

-p     Specify nextflow params-file basename

-i     Specify path to primary inputs list (e.g. samples)

-x     Specify workflow branches to execute

-w     Specify work directory

-o     Specify output directory

-r     Specify previous launch directory to resume

-c     Clean up cache and work directories

-t     Test run

$1

EOF

exit 0 

}

exec() {

eval "$1"

case "$?" in

    0)  ;;

    ?)  # ERROR
        echo -e "\n>>> ResumeDir: $(basename $NF_LAUNCH_SUBDIR)"

        echo -e "\n>>> ArchiveDir: $(dirname $NF_LAUNCH_SUBDIR)"

        echo -e "\nError ~ Execution aborted with exit code $?.\n"

        exit 0 ;; 

esac

}

# parse arguments

REPO_DIR=$(dirname $(realpath "$0"))

PARAMETERS="default"
BRANCHES="none"
INPUTS='none'
ARCHIVE="$REPO_DIR/archive"

while getopts ':hs:p:i:x:b:a:r:ct' OPT; do

    case "$OPT" in

        h) showHelp "Launch script to run & resume nextflow pipelines" ;;

        s) SYSTEM="$OPTARG" ;;

        p) PARAMETERS="$OPTARG" ;;

        i) INPUTS="$OPTARG" ;;

        x) BRANCHES="$OPTARG" ;;

        b) BUCKET_DIR="$OPTARG" ;;

        a) ARCHIVE="$OPTARG" ;;

        r) DIR2RESUME="$OPTARG" ;;

        c) CLEAN=1 ;;

        t) TEST=1 ;;

        ?) showHelp "Error ~ Incorrect arguments provided" ;;
    
    esac

done; shift "$(($OPTIND -1))"


# RESUME PARAMETERS

if [ -z "$DIR2RESUME" ]; then

    echo -e "\n*** Starting New Run ***"

else
    
    echo -e "\n*** Resuming Old Run ***"

    IFS=_ read -r PREFIX SYSTEM PARAMETERS DATE TIME <<< "$DIR2RESUME"

    echo -e "\n*** Previous Parameters Inferred ***"

fi


# SPECIFY PIPELINE STRUCTURE

SCRIPT=$(readlink -f $0)

SCRIPT_DIR=$(dirname $SCRIPT)


if [ -z "$ARCHIVE" ]; then

    ARCHIVE="$SCRIPT_DIR"

else 
    
    if [ ! -d $ARCHIVE ]; then

        ARCHIVEBASE="$(basename $ARCHIVE)" 
        ARCHIVEDIR="$(dirname $ARCHIVE)" 

        if [ -d "$ARCHIVEDIR" ]; then

            echo -e "\nCreating archive subdirectory \"$ARCHIVEBASE\""

            mkdir -p "$ARCHIVE"

        else

            echo -e "\nNeither archive directory nor parent directory found;\nCheck path \"$ARCHIVE\""

            exit 0

        fi

    fi

fi

PROJECT_DIR="$SCRIPT_DIR/pipeline"

WORKFLOW="$PROJECT_DIR/stem.nf"

CONFIG="$PROJECT_DIR/nextflow.config"

PARAMETER_DIR="$PROJECT_DIR/params"


# CHECK SYSTEM

if [ -z $SYSTEM ]; then # no profile provided

    showHelp "Error ~ System not provided: Check config file for available system profiles; $CONFIG"

fi


# CHECK PARAMETERS; TBC

PARAMETER_FILE=($(ls -1 $PARAMETER_DIR/$PARAMETERS.{json,yml,yaml} 2> /dev/null)) # list parameters found; error suppressed

if [ -z $PARAMETER_FILE ]; then # no parameters provided

    showHelp "Error ~ Parameters not found: Check parameter directory for available files; $PARAMETER_DIR"

elif [ "${#PARAMETER_FILE[@]}" -gt 1 ]; then # multiple parameter formats found

    showHelp "Error ~ Multiple parameters found: *** TBC *** ; $(printf "\n\n\t> %s" "${PARAMETER_FILE[@]}")"

fi

# CHECK INPUTS

INPUTS=$(readlink -f "$INPUTS")

if [ ! -f "$INPUTS" ]; then

    showHelp "Error ~ Input not found: Check input file path"

fi

SUPPLEMENTARY=''

for ARGUMENT in "$@"; do

    IFS='=' read -r INFO TAG <<< "$ARGUMENT"

    INFO=$(readlink -f "$INFO")

    if [ ! -f "$INFO" ]; then
        showHelp "Error ~ Supplementary input not found: Check input file path"
    fi

    SUPPLEMENTARY="${SUPPLEMENTARY:+$SUPPLEMENTARY }$ARGUMENT"
  
done


# TEST MODE

if [ $TEST ]; then

    #DRYRUN=".DRYRUN"
    #STUB="-stub"
    PREVIEW='-preview'

fi


# CHECK PREVIOUS LAUNCH

# specify launch directory
DIR2START="launch_${SYSTEM}_${PARAMETERS}"

#NF_LAUNCH_DIR_NEW="$ARCHIVE/$DIR2START"
NF_LAUNCH_DIR_NEW="$ARCHIVE/$DIR2START"

#NF_LAUNCH_DIR_OLD="$ARCHIVE/$DIR2RESUME"
NF_LAUNCH_DIR_OLD="$ARCHIVE/$DIR2RESUME"


if [ -z $DIR2RESUME ]; then

    DATE_TIME=$(date '+%Y.%m.%d_%H.%M.%S') # get current datetime
    
    NF_LAUNCH_SUBDIR="${NF_LAUNCH_DIR_NEW}_${DATE_TIME}${DRYRUN}" # label launch directory

else

    if [ ! -d $NF_LAUNCH_DIR_OLD ]; then # previous launch directory not found

        showHelp "Error ~ launchDir not found: Check archive for available options; $ARCHIVE"
            
    elif [[ ! "$NF_LAUNCH_DIR_OLD" == ${NF_LAUNCH_DIR_NEW}_* ]]; then # previous launch directory format unexpected
        
        echo "- $NF_LAUNCH_DIR_NEW"
        echo "-- $NF_LAUNCH_DIR_OLD"
        showHelp "Error ~ launchDir format unexpected: Check prefix matches \"$(basename $NF_LAUNCH_DIR_NEW)\"; $NF_LAUNCH_DIR_OLD"

    elif [[ ! "$SYSTEM" =~ ^(awsbatch|cloud_other)$ && ! -d "$NF_LAUNCH_DIR_OLD/work" && -z "$WORK_DIR" ]]; then

        showHelp "Error ~ launchDir work subdirectory not found; $NF_LAUNCH_DIR_OLD"

    elif [[ ! "$SYSTEM" =~ ^(awsbatch|cloud_other)$ && ! -d "$NF_LAUNCH_DIR_OLD/work" && ! -d "$WORK_DIR" ]]; then

        showHelp "Error ~ workDir not found; $WORK_DIR"

    else
    
        NF_LAUNCH_SUBDIR=$NF_LAUNCH_DIR_OLD # specify relevant launch directory
    
        RESUME="-resume"

    fi # checks; RESUME

fi # mode; NEW|RESUME


# WORK DIRECTORY
if [ $BUCKET_DIR ]; then

    BUCKET_DIR=$BUCKET_DIR/$(basename $ARCHIVE)/$(basename $NF_LAUNCH_SUBDIR)
    
    WORK_DIR="$BUCKET_DIR/work"
    OUTPUT_DIR="$BUCKET_DIR/outputs"

    WORK="-work-dir $WORK_DIR"
    OUTPUT="-output-dir $OUTPUT_DIR"

fi


# PREPARE LAUNCH

# create launch directory
exec "mkdir -p $NF_LAUNCH_SUBDIR"

# specify pipeline execution command
IFS='' read -r -d '' LAUNCH_COMMAND << EOF
    nextflow \\
        -C $CONFIG \\
        run $WORKFLOW \\
        $WORK \\
        $OUTPUT \\
        $RESUME \\
        $STUB \\
        $PREVIEW \\
        -profile $SYSTEM \\
        -params-file $PARAMETER_FILE \\
        --execute $BRANCHES \\
        --inputs $INPUTS \\
        --supplementary "$SUPPLEMENTARY"
EOF

LAUNCH_COMMAND=$(grep -v '^\s*\\' <<< "$LAUNCH_COMMAND")

echo -e "\nEXECUTING:\n\n$LAUNCH_COMMAND\n"



# LAUNCH

# move to launch directory
exec "cd $NF_LAUNCH_SUBDIR"

echo -e "\n>>> LaunchDir: $(basename $(pwd))\n"

# launch pipeline
exec "$LAUNCH_COMMAND"




if [[ "$SYSTEM" =~ ^(awsbatch|cloud_other) ]]; then

    echo -e "\nCopying local logs to s3 bucket \"$BUCKET_DIR\"\n"

    aws s3 cp ./logs $BUCKET_DIR/logs --recursive

fi

# PLOT DAG

DOT=$(which dot) # check graphviz installed

DAG=$(ls -t logs/*/*.dot 2> /dev/null | head -n 1) # find latest dag; error suppressed
#DAG=$(ls -t logs/*/dag.html 2> /dev/null | head -n 1) # find latest dag; error suppressed

if [ -z $DOT ] || [ -z $DAG ]; then # DAG dependencies missing
#if [ -z $DAG ]; then # DAG dependencies missing

    echo -e "\n*** Unable to plot DAG ***"

else # Graphviz installed & DAG found

    echo -e "\n>>> Generating DAG..."

    exec "dot -Tpdf $DAG -O" # execute graphviz
    
    exec "cp ${DAG}.pdf $SCRIPT_DIR/dag_latest.pdf" # publish latest dag
#    exec "cp $DAG $SCRIPT_DIR/dag_latest.html" # publish latest dag

fi # checks; plot


# CLEAN UP

if [ $CLEAN ]; then
    
    echo -e "\n>>> Cleaning up workflow directory..."

    exec "nextflow clean -force -keep-logs -quiet -but none" # execute clean

    exec "tar -cf workClean.tar work" # archive .command files

    exec "rm -r work" # remove cleaned work directory

    # remove singularity cache directory layers; ~/.singularity/cache
    # singularity cache clean -f

    # remove nextflow singularity cache images; cacheDir
    # rm -r ./singularity

fi # checks; clean

echo -e "\n>>> ResultDir: $(basename $NF_LAUNCH_SUBDIR)"

echo -e "\n>>> ArchiveDir: $(dirname $NF_LAUNCH_SUBDIR)"

echo -e "\nDONE\n"
