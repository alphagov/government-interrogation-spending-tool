# This script initialises the submodules necessary to pull in GOV.UK
# styles from static and the toolkit, generates SASS files, and 
# copies css/js/images into the right locations in Jekyll.
git submodule init

# Copy normalize.css to normalize.scss so it can be included in load path
# This is needed as GOV.UK scss imports it but does not use standard import with extension
cp ./_submodules/static/vendor/assets/stylesheets/normalize.css ./_assets/stylesheets/imports/normalize.scss

# Clear static
rm -r -f static/*.*

# Compile static SASS
sass_files=( "application" "application-ie6" "application-ie7" "application-ie8" "print" "fonts" "fonts-ie8")
for i in "${sass_files[@]}"
do
  :
  sass _submodules/static/app/assets/stylesheets/$i.scss static/$i.css \
	--load-path _submodules/static/app/assets/stylesheets \
	--load-path _submodules/toolkit/stylesheets \
	--load-path _assets/stylesheets/imports \
	--style compressed  
done

# Copy files
cp -R _submodules/static/app/assets/images/ static/
cp -R _submodules/static/app/assets/javascripts/ static/