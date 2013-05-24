echo "running tests"
rspec _processors/spec/
if [[ $? != 0 ]] ; then
	exit $?
fi
jasmine-headless-webkit -c -j assets/javascripts/_jasmine/support/jasmine.yml assets/javascripts/_jasmine/
exit $?