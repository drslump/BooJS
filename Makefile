HELPTEXT = "\
\n BooJs Makefile usage         					\
\n                               					\
\n  Options (current value)  		    			\
\n                               					\
\n    MONO          ($(MONO))                       \
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
\n    docs           - build html docs              \
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

MONO=mono --runtime=v4.0

MSBUILD_PATH=xbuild
MSBUILD_OPTS=/nologo /verbosity:quiet

NUNIT_PATH=$(MONO) lib/nunit/nunit-console.exe
NUNIT_OPTS=-framework=4.0 -nologo -domain=none -noshadow -timeout=10000 -output=/tmp/nunit-stdout


all: test

compile:
	@$(MSBUILD_PATH) $(MSBUILD_OPTS) src/boojs/boojs.booproj

compile-tests: compile
	@$(MSBUILD_PATH) $(MSBUILD_OPTS) src/BooJs.Tests/BooJs.Tests.booproj

build:
	@$(MSBUILD_PATH) $(MSBUILD_OPTS) src/boojs.sln

rebuild: clean generate-fixtures build

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

generate-fixtures:
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/arrays > src/BooJs.Tests/ArraysFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/boojay > src/BooJs.Tests/BoojayFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/callables > src/BooJs.Tests/CallablesFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/classes > src/BooJs.Tests/ClassesFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/closures > src/BooJs.Tests/ClosuresFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/compilation > src/BooJs.Tests/CompilationFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/devel > src/BooJs.Tests/DevelFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/duck-typing > src/BooJs.Tests/DuckTypingFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/examples > src/BooJs.Tests/ExamplesFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/generators > src/BooJs.Tests/GeneratorsFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/operators > src/BooJs.Tests/OperatorsFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/primitives > src/BooJs.Tests/PrimitivesFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/statements > src/BooJs.Tests/StatementsFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/stdlib > src/BooJs.Tests/StdlibFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/typesystem > src/BooJs.Tests/TypesystemFixtures.boo
	$(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo -- tests/fixtures/boojs > src/BooJs.Tests/BoojsFixtures.boo
	
docs:
	cd docs; make html; cd -

# Tests for Travis-CI environment
ci-tests:
	@$(NUNIT_PATH) $(NUNIT_OPTS) -nodots -run=" \
    	BooJs.Tests.BoojsFixtures, \
        BooJs.Tests.ClassesFixtures, \
     	BooJs.Tests.DevelFixtures, \
     	BooJs.Tests.DucktypingFixtures, \
     	BooJs.Tests.OperatorsFixtures, \
     	BooJs.Tests.PrimitivesFixtures, \
     	BooJs.Tests.SaveFileTest, \
     	BooJs.Tests.StatementsFixtures, \
     	BooJs.Tests.StdlibFixtures, \
     	BooJs.Tests.SourceMapTest \
    " \
    src/BooJs.Tests/bin/Debug/BooJs.Tests.dll

clean:
	$(MSBUILD_PATH) $(MSBUILD_OPTS) /target:clean src/boojs.sln
	cd docs; make clean; cd -

help:
	@printf $(HELPTEXT)

.PHONY : all compile build compile-tests clean help test run docs ci-tests
