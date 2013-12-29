HELPTEXT = "\
\n BooJs Makefile usage                             \
\n                                                  \
\n  Options (current value)                         \
\n                                                  \
\n    MONO          ($(MONO))                       \
\n    MSBUILD_PATH  ($(MSBUILD_PATH))               \
\n    MSBUILD_OPTS  ($(MSBUILD_OPTS))               \
\n    NUNIT_PATH    ($(NUNIT_PATH))                 \
\n    NUNIT_OPTS    ($(NUNIT_OPTS))                 \
\n                                                  \
\n  Targets                                         \
\n                                                  \
\n    compile        - compile the solution         \
\n    compile-tests  - compile the tests            \
\n    test           - run uptodate tests           \
\n    run            - run pre compiled tests       \
\n    docs           - build html docs              \
\n    clean          -                              \
\n    rebuild        - compile everything           \
\n    help                                          \
\n                                                  \
\n  Notes                                           \
\n                                                  \
\n    Use FIXTURE and TEST with *test* and *run*    \
\n    targets to launch specific tests:             \
\n      make test FIXTURE=Ported.Boojay             \
\n\n                                                \
"

MONO=mono --debug --runtime=v4.0

MSBUILD_PATH=xbuild
MSBUILD_OPTS=/nologo /verbosity:quiet

NUNIT_PATH=$(MONO) lib/nunit/nunit-console.exe
# NOTE: -domain=none produces an error with pattern matching
NUNIT_OPTS=-framework=4.0 -nologo -domain=single -noshadow -timeout=10000 -output=/tmp/nunit-stdout

MONOLINKER_PATH=monolinker

ILREPACK_PATH=ilrepack
ILREPACK_OPTS=/log

BIN_PATH = src/boojs/bin/Debug
BUNDLE_NAME = boojs

MKBUNDLE_PATH = mkbundle
MKBUNDLE_OPTS = -z

UPX_PATH = upx
UPX_OPTS = -9


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
	$(NUNIT_PATH) $(NUNIT_OPTS) -run=BooJs.Tests.$(FIXTURE)Fixtures.$(TEST) src/BooJs.Tests.Ported/bin/Debug/BooJs.Tests*.dll
else
	$(NUNIT_PATH) $(NUNIT_OPTS) -fixture=BooJs.Tests.$(FIXTURE)Fixtures src/BooJs.Tests.Ported/bin/Debug/BooJs.Tests*.dll
endif
else
	$(NUNIT_PATH) $(NUNIT_OPTS) src/BooJs.Tests/bin/Debug/BooJs.Tests*.dll
endif

MAKE_FIXTURE = $(MONO) lib/booi.exe scripts/generate-fixture-testcases.boo --
generate-fixtures:
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/arrays > src/BooJs.Tests.Ported/ArraysFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/attributes > src/BooJs.Tests.Ported/AttributesFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/boojay > src/BooJs.Tests.Ported/BoojayFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/callables > src/BooJs.Tests.Ported/CallablesFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/closures > src/BooJs.Tests.Ported/ClosuresFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/compilation > src/BooJs.Tests.Ported/CompilationFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/ducky > src/BooJs.Tests.Ported/DuckyFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/duck-typing > src/BooJs.Tests.Ported/DuckTypingFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/extensions > src/BooJs.Tests.Ported/ExtensionsFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/generators > src/BooJs.Tests.Ported/GeneratorsFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/generics > src/BooJs.Tests.Ported/GenericsFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/meta-programming > src/BooJs.Tests.Ported/MetaProgrammingFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/modules > src/BooJs.Tests.Ported/ModulesFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/operators > src/BooJs.Tests.Ported/OperatorsFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/parser > src/BooJs.Tests.Ported/ParserFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/parser-roundtrip > src/BooJs.Tests.Ported/ParserRoundtripFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/primitives > src/BooJs.Tests.Ported/PrimitivesFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/statements > src/BooJs.Tests.Ported/StatementsFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/stdlib > src/BooJs.Tests.Ported/StdlibFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/semantics > src/BooJs.Tests.Ported/SemanticsFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests.Ported tests/fixtures/types > src/BooJs.Tests.Ported/TypesFixtures.boo

	$(MAKE_FIXTURE) BooJs.Tests tests/fixtures/boojs > src/BooJs.Tests/BoojsFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests tests/fixtures/classes > src/BooJs.Tests/ClassesFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests tests/fixtures/devel > src/BooJs.Tests/DevelFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests tests/fixtures/examples > src/BooJs.Tests/ExamplesFixtures.boo
	$(MAKE_FIXTURE) BooJs.Tests tests/fixtures/typesystem > src/BooJs.Tests/TypesystemFixtures.boo
    
docs:
	cd docs; make html; cd -

bundle-ilrepack:
	@mkdir -p build
	$(ILREPACK_PATH) $(ILREPACK_OPTS) /out:build/$(BUNDLE_NAME).exe /internalize $(BIN_PATH)/boojs.exe $(BIN_PATH)/*.dll    

bundle-dynamic:
	@mkdir -p build/linked
	CC="cc -arch i386" AS="as -arch i386" \
	    $(MKBUNDLE_PATH) $(MKBUNDLE_OPTS) -o build/$(BUNDLE_NAME).exe --deps -L $(BIN_PATH) $(BIN_PATH)/boojs.exe

bundle-static-osx:
	@mkdir -p build
	CC="cc -arch i386 -framework CoreFoundation -liconv" AS="as -arch i386" \
	    $(MKBUNDLE_PATH) $(MKBUNDLE_OPTS) --static -o build/$(BUNDLE_NAME) --deps -L $(BIN_PATH) $(BIN_PATH)/boojs.exe $(BIN_PATH)/*.dll

bundle-linked:
	# TODO: When linking there is a bug using the CommandLine Argument attribute
	@mkdir -p build/linked
	monolinker -out build/linked -d $(BIN_PATH) -l none -c link -a $(BIN_PATH)/boojs.exe

bundle-linked-ilrepack: bundle-linked
	# TODO: ilrepack can't produce the assembly when it's been linked
	$(ILREPACK_PATH) $(ILREPACK_OPTS) /out:build/$(BUNDLE_NAME).exe /internalize build/linked/boojs.exe build/linked/*.dll

bundle-linked-dynamic: bundle-linked
	CC="cc -arch i386" AS="as -arch i386" \
		$(MKBUNDLE_PATH) $(MKBUNDLE_OPTS) -o build/$(BUNDLE_NAME) -L build/linked build/linked/boojs.exe build/linked/*.dll

bundle-linked-static: bundle-linked
	CC="cc -arch i386" AS="as -arch i386" \
		$(MKBUNDLE_PATH) $(MKBUNDLE_OPTS) --static -o build/$(BUNDLE_NAME) -L build/linked build/linked/boojs.exe build/linked/*.dll

bundle-linked-static-osx: bundle-linked
	CC="cc -arch i386 -framework CoreFoundation -liconv" AS="as -arch i386" \
	    $(MKBUNDLE_PATH) $(MKBUNDLE_OPTS) --static -o build/$(BUNDLE_NAME) -L build/linked build/linked/boojs.exe build/linked/*.dll

upx:
	@echo "NOTE: For best results create the static bundle with MKBUNDLE_OPTS=''"
	$(UPX_PATH) $(UPX_OPTS) build/$(BUNDLE_NAME)


# Tests for Travis-CI environment
ci-tests:
	@$(NUNIT_PATH) $(NUNIT_OPTS) -nodots -run=" \
        BooJs.Tests.Ported.ArraysFixtures, \
        BooJs.Tests.Ported.BoojayFixtures, \
        BooJs.Tests.Ported.CallablesFixtures, \
        BooJs.Tests.Ported.ClassesFixtures, \
        BooJs.Tests.Ported.ClosuresFixtures, \
        BooJs.Tests.Ported.CompilationFixtures, \
        BooJs.Tests.Ported.DuckyFixtures, \
        BooJs.Tests.Ported.DucktypingFixtures, \
        BooJs.Tests.Ported.ExtensionsFixtures, \
        BooJs.Tests.Ported.GeneratorsFixtures, \
        BooJs.Tests.Ported.GenericsFixtures, \
        BooJs.Tests.Ported.MetaProgrammingFixtures, \
        BooJs.Tests.Ported.ModulesFixtures, \
        BooJs.Tests.Ported.OperatorsFixtures, \
        BooJs.Tests.Ported.ParserFixtures, \
        BooJs.Tests.Ported.PrimitivesFixtures, \
        BooJs.Tests.Ported.StatementsFixtures, \
        BooJs.Tests.Ported.StdlibFixtures, \
        BooJs.Tests.Ported.TypesFixtures, \
        BooJs.Tests.BoojsFixtures, \
        BooJs.Tests.DevelFixtures, \
        BooJs.Tests.SaveFileTest, \
        BooJs.Tests.SourceMapTest, \
        BooJs.Tests.TypesystemFixtures \
	" \
	src/BooJs.Tests.Ported/bin/Debug/BooJs.Tests*.dll

clean:
	$(MSBUILD_PATH) $(MSBUILD_OPTS) /target:clean src/boojs.sln
	rm -rf build
	cd docs; make clean; cd -

help:
	@printf $(HELPTEXT)

.PHONY : all compile build compile-tests clean help test run docs ci-tests
