env
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8


bundle
echo "Creating main.css ..."
touch assets/stylesheets/main.css
echo "Copying govuk styles ...."
/bin/bash _copy_govuk_styles.sh && sleep 2
echo "Processing data ...."

rm -rf _processors/data/*

if [ -e /data/qds.csv ] && [ -e /data/oscar.csv ]; then
cp /data/* _processors/data/
/bin/bash _convert_from_windows_encoding.sh _processors/data/qds.cvs _processors/data/qds.cvs
/bin/bash _convert_from_windows_encoding.sh _processors/data/oscar.cvs _processors/data/oscar.cvs
/bin/bash _process_data.sh
else \
/bin/bash _process_test_data.sh && sleep 2
fi


cp -R _submodules/static/app/assets/images/* static/
cp -R _submodules/static/app/assets/javascripts/* static/

echo "Running rspec ...."
rspec -f d -c _spec/

echo "Building application ...."
bundle exec jekyll build

zip -r workspace.zip *