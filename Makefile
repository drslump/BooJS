MSBUILD_PATH=xbuild
MSBUILD_OPTS=/nologo /verbosity:quiet

NUNIT_PATH=/Library/Frameworks/Mono.framework/Commands/nunit-console4
NUNIT_OPTS=-nologo


all: compile

compile:
	$(MSBUILD_PATH) $(MSBUILD_OPTS) src/boojs/boojs.booproj

compile-test: compile
	$(MSBUILD_PATH) $(MSBUILD_OPTS) src/BooJs.Tests/BooJs.Tests.booproj

test: compile-test
	$(NUNIT_PATH) $(NUNIT_OPTS) src/BooJs.Tests/bin/Debug/BooJs.Tests.dll

clean:
	$(MSBUILD_PATH) $(MSBUILD_OPTS) /target:clean src/boojs.sln