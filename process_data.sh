echo "Processing csvs to create pages with data"
ruby -r "./_processors/oscar_processor.rb" -e "OscarProcessor.process '_processors/data/oscar.csv'"
ruby -r "./_processors/qds_processor.rb" -e "QdsProcessor.process '_processors/data/qds.csv'"