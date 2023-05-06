!#/usr/bin/bash
# Capturing the sorghum line ids so we can meerge genotypes
# with passport (georeference) data
# with the coordinates we can extract eenvironmental variables
# from maps

head -n1  sb_snpsDryad_sept2013_filter.c10.imp.hmp.txt | cut -f13-  | sed -e  's/\t/\n/g'| sed -e 's/"//g' > p

head -n1  sb_snpsDryad_sept2013_filter.c10.imp.hmp.txt | cut -f13-  | sed -e  's/\t/\n/g'| sed -e 's/"//g'| sed 's/\./\t/g' > q

paste p q > genotype_ids.txt
