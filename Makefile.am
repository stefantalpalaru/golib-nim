%: %.nim nim.cfg src/golib.nim
	$(NIM) c $<

check_DATA = tests/bug234 \
			 tests/gc/weakrefs \
			 tests/select \
			 tests/select7 \
			 tests/peano \
			 tests/select_custom \
			 tests/gc/gcbench \
			 tests/gc/gctest \
			 tests/gc/bintrees \
			 tests/gc/closureleak \
			 tests/gc/cyclecollector \
			 tests/gc/cycleleak \
			 tests/gc/gcleak \
			 tests/gc/gcleak2 \
			 tests/gc/gcleak3 \
			 tests/gc/refarrayleak \
			 tests/gc/stackrefleak \
			 tests/gc/gcleak4 \
			 tests/gc/gcleak5 \
			 tests/gc/growobjcrash

TESTS = $(check_DATA)

noinst_DATA = benchmarks/cw_nim

MOSTLYCLEANFILES := $(check_DATA) $(noinst_DATA)

clean-local:
	-rm -rf benchmarks/nimcache tests/nimcache tests/*/nimcache

EXTRA_DIST := tests/*.go \
	tests/*.nim \
	tests/*/*.nim \
	benchmarks/*.nim \
	benchmarks/*.nim.cfg \
	autogen.sh \
	nim.cfg.in \
	LICENSE \
	README.md

