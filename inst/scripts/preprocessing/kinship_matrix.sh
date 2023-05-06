#Forming an all SNP file
#remove the header files and append to the allSNPs
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c1.imp.hmp.txt > allSNPs.txt
#enter a new line
echo "" >> allSNPs.txt
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c2.imp.hmp.txt >> allSNPs.txt
echo "" >> allSNPs.txt
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c3.imp.hmp.txt >> allSNPs.txt
echo "" >> allSNPs.txt
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c4.imp.hmp.txt >> allSNPs.txt
echo "" >> allSNPs.txt
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c5.imp.hmp.txt >> allSNPs.txt
echo "" >> allSNPs.txt
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c6.imp.hmp.txt >> allSNPs.txt
echo "" >> allSNPs.txt
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c7.imp.hmp.txt >> allSNPs.txt
echo "" >> allSNPs.txt
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c8.imp.hmp.txt >> allSNPs.txt
echo "" >> allSNPs.txt
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c9.imp.hmp.txt >> allSNPs.txt
echo "" >> allSNPs.txt
sed '1d' /rsstu/users/r/rrellan/sara/SorghumGEA_data/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c10.imp.hmp.txt >> allSNPs.txt

#Producing random SNPs
#jot produces a random number from 1 to file length
jot -r "$(wc -l allSNPs.txt)" 1 |
#paste pastes the random number to each line in the file
paste - allSNPs.txt |
#sort sorts numeric each line
sort -n |
#cut removes the random number from each line
cut -f 2- |
#head outputs the first n lines
head -n 5000 > kinship_matrix.txt

#Creating a kinship matrix
#copy header from any of the file
sed -n '1p' /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c1.imp.hmp.txt > header.txt
echo "" >> header.txt
#join two files
cat kinship_matrix.txt >> header.txt
cat header.txt > kinship_matrix.txt
