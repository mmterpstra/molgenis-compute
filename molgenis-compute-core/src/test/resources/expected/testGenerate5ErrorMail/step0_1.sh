#!/bin/bash
#SBATCH --job-name=step0_1
#SBATCH --output=step0_1.out
#SBATCH --error=step0_1.err
#SBATCH --partition=prod
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task 4
#SBATCH --mem 500
#SBATCH --nodes 1
#SBATCH --open-mode=append

ENVIRONMENT_DIR="."
set -e
set -u
#-%j

errorExit()
{
    if [ "testMail@testServer" = "none" ]; then
        echo "mail is not specified"
        exit 1
    fi

    if [ ! -f errorMessageSent.flag ]; then
        echo "script $0 from directory $(pwd) reports failure" | mail -s "ERROR OCCURS" testMail@testServer
        touch errorMessageSent.flag
    fi
    exit 1
}

declare MC_tmpFolder="tmpFolder"
declare MC_tmpFile="tmpFile"

function makeTmpDir {
        base=$(basename $1)
        dir=$(dirname $1)
        echo "dir $dir"
        echo "base $base"
        if [[ -d $1 ]]
        then
            	dir=$dir/$base
        fi
	myMD5=$(md5sum $0)
        IFS=' ' read -a myMD5array <<< "$myMD5"
        MC_tmpFolder=$dir/tmp_step0_1_$myMD5array/
        mkdir -p $MC_tmpFolder
        if [[ -d $1 ]]
        then
            	MC_tmpFile="$MC_tmpFolder"
        else
            	MC_tmpFile="$MC_tmpFolder/$base"
        fi
}


trap "errorExit" ERR

# For bookkeeping how long your task takes
MOLGENIS_START=$(date +%s)

touch step0_1.sh.started


#
## Generated header
#

# Assign values to the parameters in this script

# Set taskId, which is the job name of this task
taskId="step0_1"

# Make compute.properties available
rundir="TEST_PROPERTY(project.basedir)/target/test/benchmark/run"
runid="testGenerate5ErrorMail"
workflow="src/main/resources/workflows/benchmark.5.1/workflow.csv"
parameters="src/main/resources/workflows/benchmark.5.1/parameters.csv,src/main/resources/workflows/benchmark.5.1/sysparameters.csv"
user="TEST_PROPERTY(user.name)"
database="none"
backend="slurm"
port="80"
interval="2000"
path="."


# Connect parameters to environment
input="bye"

# Validate that each 'value' parameter has only identical values in its list
# We do that to protect you against parameter values that might not be correctly set at runtime.
if [[ ! $(IFS=$'\n' sort -u <<< "${input[*]}" | wc -l | sed -e 's/^[[:space:]]*//') = 1 ]]; then echo "Error in Step 'step0': input parameter 'input' is an array with different values. Maybe 'input' is a runtime parameter with 'more variable' values than what was folded on generation-time?" >&2; exit 1; fi

#
## Start of your protocol template
#

#string input

# Let's do something with string 'in'
echo "${input}_hasBeenInStep1"

#
## End of your protocol template
#

# Save output in environment file: '$ENVIRONMENT_DIR/step0_1.env' with the output vars of this step

echo "" >> $ENVIRONMENT_DIR/step0_1.env
chmod 755 $ENVIRONMENT_DIR/step0_1.env


touch step0_1.sh.finished

echo "On $(date +"%Y-%m-%d %T"), after $(( ($(date +%s) - $MOLGENIS_START) / 60 )) minutes, task step0_1 finished successfully" >> molgenis.bookkeeping.log
