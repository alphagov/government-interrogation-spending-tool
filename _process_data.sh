#!/bin/bash

echo "Processing data to create sample pages with data"

START=$(date +%s)

qds_file="_processors/data/qds.csv"
if [ -f "$qds_file" ]
then
  QDS_START=$(date +%s)

  echo " - Processing QDS data"
  rm -rf qds/*
  ruby -r "./_processors/qds_processor.rb" -e "QdsProcessor.new.process '$qds_file'"

  QDS_END=$(date +%s)
  QDS_DIFF=$(( $QDS_END - $QDS_START ))
  echo " - Finished QDS Processing: $QDS_DIFF seconds"
else
  echo "$qds_file not found, skip processing QDS"
fi

oscar_file="_processors/data/oscar.csv"
if [ -f "$oscar_file" ]
then
  OSCAR_START=$(date +%s)

  echo " - Processing OSCAR data"
  rm -rf oscar/*
  ruby -r "./_processors/oscar_processor.rb" -e "OscarProcessor.new.process '$oscar_file'"

  OSCAR_END=$(date +%s)
  OSCAR_DIFF=$(( $OSCAR_END - $OSCAR_START ))
  echo " - Finished OSCAR Processing: $OSCAR_DIFF seconds"
else
  echo "$oscar_file not found, skip processing OSCAR"
fi

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Finished Processing: $DIFF seconds"