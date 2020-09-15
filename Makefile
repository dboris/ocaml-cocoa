.PHONY: default build test deps clean

default: build

build:
	@dune build src/cocoa.cmxa

test:
	@dune exec examples/count_clicks.exe

cocoa.opam: dune-project
	@dune build | true

deps: cocoa.opam
	opam install . --deps-only --yes

clean:
	@dune clean