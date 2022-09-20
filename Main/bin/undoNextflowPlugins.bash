#!/usr/bin/env bash

set -euo pipefail

LAST=$(nextflow log |tail -n 1|cut -f 3)

NAME=${1:-$LAST}

echo Undo nextflow run $NAME

nextflow log $NAME -filter 'tag == "plugin"' -f tag,workdir,start | tac | cut -f 2 | while read line; do undoCommandFromPluginStderr.pl $line/.command.err 1; done | bash -e
