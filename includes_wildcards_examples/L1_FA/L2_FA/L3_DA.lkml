# include: "/**/*.*" #everything at any level

# include: "/*/*.*" ##everything at level 1


#relative includes
#in this example curent path is:
# /includes_wildcards_examples/L1_FA/L2_FA/L3_DA.lkml
include:                              "../**/*" #everthing in grandparent (L1_FA) (but not L1_FB)
include:                               "./**/*" #everthing in parent (L2_FA (not L2_FB)
include:                               "../*/*.*" #everthing in parent (L2_FA (not FB)

include:                              "../**/*DB*" #everthing in grandparent down, and with DB in filename
include:                              "../*L2*/*.*" #everthing in grandparent down, and with L2 in path

include:                              "../*DB*" #everthing in grandparent down, and with DB in filename
