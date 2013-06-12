env
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

bundle
echo "Starting Jekyll server ...."
bundle exec jekyll serve &

echo "Generating images ...."
sleep 60 && /bin/bash _phantomjs_generate_chart_images.sh

bundle exec jekyll build

echo "Stopping Jekyll ...."
PID=`sudo ps aux | tr -s " " | grep -v grep | grep -E */jekyll | cut -d " " -f 2`
kill $PID

echo "Creating artifact"
zip -r _site.zip _site