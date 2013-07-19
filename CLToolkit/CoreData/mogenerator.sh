PATH=${PATH}:/usr/local/bin
cd Collections
mogenerator -m Models/Collections.xcdatamodeld/Collections.xcdatamodel/ --human-dir Models --machine-dir Models/_Models --template-var arc=true --base-class FObject
# --includem Models/CLModels.h
