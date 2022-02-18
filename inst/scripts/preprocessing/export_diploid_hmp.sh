!#/usr/bin/bash
# We had a problem with the Lansky 2015  hapmap ddata format
# importing and exporting  as diploid wiith the TASSEL5 GUI
# was useful to fix that
# Maybe using the TASSEL CLI will heelp too.
# sb_snpsDryad_sept2013_filter.c1.imp.hmp.txt
TASSEL5=/usr/local/usrapps/maize/tassel-5-standalone/run_pipeline.pl
$TASSEL5 -importGuess \
    sb_snpsDryad_sept2013_filter.c2.imp.hmp.txt \
    -export sb_snpsDryad_sept2013_filter.c1.dip.hmp.txt \
    -exportType HapmapDiploid
