#!/bin/bash
# Import dumps of the TAXREF Web API into MongoDB
#
# Input arguments:
# - TAXREF version, e.g. "12.0"
# - MongoDB database name, e.g. "taxrefv12"
#
# Author: F. Michel, UCA, CNRS, Inria

help()
{
  exe=$(basename $0)
  echo "Usage: $exe <TAXREF version> <MongoDB database name>"
  echo "Call example:"
  echo "   $exe 12.0 taxrefv12"
  exit 1
}

version=$1
if [[ -z "$version" ]] ; then help; fi

db=$2
if [[ -z "$db" ]] ; then help; fi

collection=media

mongo --eval "db.${collection}.drop()" localhost/$db

for FILE in `ls taxref_media_${version}_*.json`; do
    echo "Processing $FILE"

    awk -f import_media.awk $FILE > ${FILE}.tmp
    mongoimport --db $db --collection $collection --type json --jsonArray --file ${FILE}.tmp
    echo -n "**** Current nb of documents: "
    mongo --quiet --eval "db.${collection}.count()" localhost/$db
    rm -f ${FILE}.tmp
done

# Add a field licence_url
mongo localhost/$db import_media.js
