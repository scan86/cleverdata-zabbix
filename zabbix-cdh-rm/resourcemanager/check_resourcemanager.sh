#!/bin/bash

set -o nounset

# global vars #
fullpath=$(readlink -f $0)
scriptDir=$(dirname $fullpath)

main_pl=$scriptDir/main.pl

export PERL5LIB=$scriptDir
$main_pl $@
