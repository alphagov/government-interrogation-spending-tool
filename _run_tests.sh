echo "running tests"
rspec -f d -c _spec/
if [[ $? != 0 ]] ; then
	exit $?
fi
jasmine-headless-webkit -c -j _spec/jasmine/support/jasmine.yml _spec/jasmine/
exit $?
