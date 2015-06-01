%: %.nim nim.cfg src/golib.nim
	$(NIM) c $<

check_DATA = tests/bug234 \
			 tests/select \
			 tests/select7 \
			 tests/select_custom \
			 tests/gc/gcbench \
			 tests/gc/gctest

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

