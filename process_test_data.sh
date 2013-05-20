echo "Processing test data to create sample pages with data"
ruby -r "./_processors/oscar_processor.rb" -e "OscarProcessor.process '_processors/spec/test_data/test_oscar.csv'"
ruby -r "./_processors/qds_processor.rb" -e "QdsProcessor.process '_processors/spec/test_data/test_qds.csv'"