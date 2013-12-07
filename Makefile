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
\n    clean          -             					\
\n    rebuild        - compile everything           \
\n    help                       					\
\n                                                  \
\n  Notes                        					\
\n                               					\
\n    Use FIXTURE and TEST with *test* and *run*    \
\n    targets to launch specific tests:             \
\n      make test FIXTURE=Boojay 		            \
\n\n                             					\
"


MSBUILD_PATH=xbuild
MSBUILD_OPTS=/nologo /verbosity:quiet

NUNIT_PATH=/Library/Frameworks/Mono.framework/Commands/nunit-console4
NUNIT_OPTS=-nologo -domain=single -noshadow -output=/tmp/nunit-stdout


all: test

compile:
	@$(MSBUILD_PATH) $(MSBUILD_OPTS) src/boojs/boojs.booproj

build: compile
	@mkdir -p build
	@rm -rf build/*
	@cp src/boojs/bin/Debug/* build/.

compile-tests: compile
	$(MSBUILD_PATH) $(MSBUILD_OPTS) src/BooJs.Tests/BooJs.Tests.booproj

test: compile-tests run

run:
ifdef FIXTURE
ifdef TEST
	$(NUNIT_PATH) $(NUNIT_OPTS) -run=BooJs.Tests.$(FIXTURE)Fixtures.$(TEST) src/BooJs.Tests/bin/Debug/BooJs.Tests.dll
else
	$(NUNIT_PATH) $(NUNIT_OPTS) -fixture=BooJs.Tests.$(FIXTURE)Fixtures src/BooJs.Tests/bin/Debug/BooJs.Tests.dll
endif
else
	$(NUNIT_PATH) $(NUNIT_OPTS) src/BooJs.Tests/bin/Debug/BooJs.Tests.dll
endif

rebuild: clean compile generate-fixtures compile-tests

generate-fixtures:
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/arrays > src/BooJs.Tests/ArraysFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/boojay > src/BooJs.Tests/BoojayFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/callables > src/BooJs.Tests/CallablesFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/classes > src/BooJs.Tests/ClassesFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/closures > src/BooJs.Tests/ClosuresFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/compilation > src/BooJs.Tests/CompilationFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/devel > src/BooJs.Tests/DevelFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/duck-typing > src/BooJs.Tests/DuckTypingFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/examples > src/BooJs.Tests/ExamplesFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/generators > src/BooJs.Tests/GeneratorsFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/operators > src/BooJs.Tests/OperatorsFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/primitives > src/BooJs.Tests/PrimitivesFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/statements > src/BooJs.Tests/StatementsFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/stdlib > src/BooJs.Tests/StdlibFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/typesystem > src/BooJs.Tests/TypesystemFixtures.boo
	lib/booi scripts/generate-fixture-testcases.boo -- tests/fixtures/boojs > src/BooJs.Tests/BoojsFixtures.boo
	
clean:
	$(MSBUILD_PATH) $(MSBUILD_OPTS) /target:clean src/boojs.sln

help:
	@printf $(HELPTEXT)

.PHONY : all compile compile-tests clean help test run
