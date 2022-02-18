#!/bin/tcsh

mkdir fixed
set data_dir="/rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/snpsLaskySciAdv_dryad"

foreach hapmap (`ls $data_dir`)
    bsub -n 1 -W 15 -o stdout.%J -e stderr.%J "source ./fix_hapmap.sh $data_dir/$hapmap"
end

