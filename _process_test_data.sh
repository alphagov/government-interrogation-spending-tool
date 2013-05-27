echo "Processing test data to create sample pages with data"
rm -rf qds/*
rm -rf oscar/*
ruby -r "./_processors/qds_processor.rb" -e "QdsProcessor.new.process '_spec/test_data/test_qds.csv'"
ruby -r "./_processors/oscar_processor.rb" -e "OscarProcessor.new.process '_spec/test_data/test_oscar.csv'"
