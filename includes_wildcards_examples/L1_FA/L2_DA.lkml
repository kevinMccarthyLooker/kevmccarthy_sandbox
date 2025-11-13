# include: "/**/*.*" #everything at any level

# include: "/*/*.*" ##everything at level 1


#relative includes
#in this example curent path is:
# /includes_wildcards_examples/L1_FA/L2_DA.lkml
include:                     "../**/*" #everthing in grandparent (includes_wildcards)
include:                     "../*/*" #everthing within grandparent at this same depth (L1_FA (not FB)
include:                     "../*" #files within grandparent folder

include:                     "./**/*" #everthing in parent, any number of levels
include:                     "./*/*" #everthing exactly one level below parent
include:                     "./*" #files exactly in parent folder





include:                     "../**/*DB*" #everthing in grandparent down, and with DB in filename
# include:                   "../*L2*/*.*" #everthing in grandparent down, and with L2 in path
include:                     "../*DB*" #everthing in grandparent one level down, and with DB in filename


include:                     "./*_*/*.*" #everthing in parent down with "_" in remaining path, and with DB in filename
include:                     "./**/*" #everthing in parent (L1_FA and any number of levels down
include:                     "./**/*.*" #same
