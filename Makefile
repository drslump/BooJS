HELPTEXT = "\
\n BooJs Makefile usage         					\
\n                               					\
\n  Options (current value)  		    			\
\n                               					\
\n    MSBUILD_PATH  ($(MSBUILD_PATH))   			\
\n    MSBUILD_OPTS  ($(MSBUILD_OPTS))   			\
\n    NUNIT_PATH    ($(NUNIT_PATH))    				\
\n    NUNIT_OPTS    ($(NUNIT_OPTS)) 			    \
\n                					                \
\n  Targets                  					    \
\n                               					\
\n    compile        - compile the solution         \
\n    compile-tests  - compile the tests            \
\n    test           - run uptodate tests           \
\n    run            - run pre compiled tests       \
\n    clean                      					\
\n    help                       					\
\n                                                  \
\n  Notes                        					\
\n                               					\
\n    Use FIXTURE and TEST with *test* and *run*    \
\n    targets to launch specific tests:             \
\n      make test FIXTURE=BoojayFixtures            \
\n\n                             					\
"


MSBUILD_PATH=xbuild
MSBUILD_OPTS=/nologo /verbosity:quiet

NUNIT_PATH=/Library/Frameworks/Mono.framework/Commands/nunit-console4
NUNIT_OPTS=-nologo -domain=single -output=/tmp/nunit-stdout


all: test

compile:
	$(MSBUILD_PATH) $(MSBUILD_OPTS) src/boojs/boojs.booproj

compile-tests: compile
	$(MSBUILD_PATH) $(MSBUILD_OPTS) src/BooJs.Tests/BooJs.Tests.booproj

test: compile-tests run

run:
ifdef FIXTURE
ifdef TEST
	$(NUNIT_PATH) $(NUNIT_OPTS) -run=BooJs.Tests.$(FIXTURE).$(TEST) src/BooJs.Tests/bin/Debug/BooJs.Tests.dll
else
	$(NUNIT_PATH) $(NUNIT_OPTS) -fixture=BooJs.Tests.$(FIXTURE) src/BooJs.Tests/bin/Debug/BooJs.Tests.dll
endif
else
	$(NUNIT_PATH) $(NUNIT_OPTS) src/BooJs.Tests/bin/Debug/BooJs.Tests.dll
endif

clean:
	$(MSBUILD_PATH) $(MSBUILD_OPTS) /target:clean src/boojs.sln

help:
	@printf $(HELPTEXT)
 
.PHONY: all clean help test run
