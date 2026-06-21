# sml-image build
#
#   make            build the test binary with MLton (default)
#   make test       build + run tests under MLton
#   make test-poly  run tests under Poly/ML (use-and-run; no link step)
#   make all-tests  run the suite under both compilers
#   make fixtures   regenerate test/fixtures.sml (python zlib + manual PNG)
#   make clean      remove build artifacts
#
# Layout B (dependent): own sources live in src/; sml-inflate and sml-color are
# vendored under lib/ and loaded first, in dependency order.

MLTON      ?= mlton
POLY       ?= poly
BIN        := bin
INFLATEDIR := lib/github.com/sjqtentacles/sml-inflate
COLORDIR   := lib/github.com/sjqtentacles/sml-color
TEST_MLB   := test/test.mlb
SRCS       := $(wildcard $(INFLATEDIR)/* $(COLORDIR)/* src/* test/*.sml) $(TEST_MLB)

.PHONY: all test poly test-poly all-tests fixtures clean

all: $(BIN)/test-mlton

$(BIN)/test-mlton: $(SRCS) | $(BIN)
	$(MLTON) -output $@ $(TEST_MLB)

test: $(BIN)/test-mlton
	$(BIN)/test-mlton

# Poly/ML has no native .mlb support; the suite runs at top level and exits on
# its own. Load vendored deps first (inflate, then color), then image, then the
# test driver.
poly test-poly:
	printf 'use "$(INFLATEDIR)/inflate.sig";\nuse "$(INFLATEDIR)/inflate.sml";\nuse "$(COLORDIR)/color.sig";\nuse "$(COLORDIR)/color.sml";\nuse "src/image.sig";\nuse "src/image.sml";\nuse "test/harness.sml";\nuse "test/fixtures.sml";\nuse "test/support.sml";\nuse "test/test_ppm.sml";\nuse "test/test_bmp_tga.sml";\nuse "test/test_png.sml";\nuse "test/test_roundtrip.sml";\nuse "test/test_edge.sml";\nuse "test/entry.sml";\nuse "test/main.sml";\n' | $(POLY) -q --error-exit

all-tests: test test-poly

fixtures:
	python3 bin/gen_fixtures.py

$(BIN):
	mkdir -p $(BIN)

clean:
	rm -f $(BIN)/test-mlton
