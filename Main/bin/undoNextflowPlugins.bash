#!/usr/bin/env bash

set -euo pipefail

while getopts f:n: flag
do
    case "${flag}" in
        f) filterarg=${OPTARG};;
        n) namearg=${OPTARG};;
    esac
done

# for nextflow's stderr file (.command.err) for processes tagged as "plugin"
#   the stderr file will contain a "PLUGIN" and an "AlgInvocationId" which we can use to construct a call to GUS::Community::Plugin::Undo 
#   just running the undo's serially in reverse order from the logs

# First get the most recent nextflow run
LAST=$(nextflow log |tail -n 1|cut -f 3)

# user can call with named run (default is most recent)
NAME=${namearg:-$LAST}
STATUS_FILTER=${filterarg:-".*"}

echo Undo nextflow run name=$NAME, with filter=$STATUS_FILTER
 
nextflow log $NAME -filter "tag == 'plugin' && status =~ /(?i)${STATUS_FILTER}/" -f workdir | # filter by steps tagged as plugin and optionally by status;  
tac | #print in reverse order
while read line; do undoCommandFromPluginStderr.pl $line/.command.err 1 | tac ; done |  #pass stderr file to command to parse and get the undo command; 
bash -e #run the undo command

