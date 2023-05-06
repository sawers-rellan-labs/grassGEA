# which  field corresponds to phosphorus measurements
head -n 1 wosis_201909_layers_chemical.tsv| sed "s/\t/\n/g"| grep -n -P "^php.*_value_avg"

# 99:phpbyi_value_avg
# 106:phpmh3_value_avg
# 113:phpols_value_avg
# 120:phprtn_value_avg
# 127:phptot_value_avg
# 134:phpwsl_value_avg

# add depth columns 

head -n1 wosis_201909_layers_chemical.tsv| sed "s/\t/\n/g"| grep -n "depth"

# 3:upper_depth
# 4:lower_depth

cut -f1,3,4,106,113,120,127,134 wosis_201909_layers_chemical.tsv |  grep -v  -P "\\t\\t\\t\\t\\t$" > php.tsv 

# get unique ids for getting lon lat from wosis_201909_profiles.tsv

cut -f1 php.tsv | sort -n | uniq >lon_lat_ids.list

# get lon lat from wosis_201909_profiles.tsv


head -n 1  wosis_201909_profiles.tsv| sed "s/\t/\n/g"| grep -n -P "tude$"
# 6:latitude
# 7:longitude



