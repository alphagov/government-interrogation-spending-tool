#!/bin/bash
echo "Generating static images for charts"

START=$(date +%s)

BASE_URL="http://localhost:4000"

for D in $(find oscar -type d) ; do
  echo "Generating chart for $BASE_URL/$D";
  phantomjs _phantomjs_generate_chart_image.js "$BASE_URL/$D" "$D/chart.png"
done

for D in $(find qds -type d) ; do
  echo "Generating chart for $BASE_URL/$D";
  phantomjs _phantomjs_generate_chart_image.js "$BASE_URL/$D" "$D/chart.png"
done

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Finished Generating static images for charts: $DIFF seconds"