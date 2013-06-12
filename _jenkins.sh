env
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

bundle
echo "Creating main.css ..."
touch assets/stylesheets/main.css
echo "Copying govuk styles ...."
/bin/bash _copy_govuk_styles.sh && sleep 2
echo "Processing data ...."
/bin/bash _process_test_data.sh && sleep 2
cp -R _submodules/static/app/assets/images/* static/
cp -R _submodules/static/app/assets/javascripts/* static/

echo "Running rspec ...."
rspec -f d -c _spec/



echo "Building application ...."
bundle exec jekyll build && sleep 2

echo "Starting Jekyll server ...."
jekyll serve &
sleep 2

echo "Generating images ...."
/bin/bash _phantomjs_generate_chart_images.sh
sleep 2
jekyll build

echo "Stopping Jekyll ...."
PID=`sudo ps aux | tr -s " " | grep -v grep | grep -E */jekyll | cut -d " " -f 2`
kill $PID

echo "Creating artifact"
zip -r _site.zip _site