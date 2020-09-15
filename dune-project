(lang dune 2.7)
(name cocoa)

(generate_opam_files true)
(authors "Boris D. <borisd@gmx.com>")
(maintainers "Boris D. <borisd@gmx.com>")
(source (github dboris/ocaml-cocoa))
(license ISC)

(package
  (name cocoa)
  (synopsis "OCaml bindings for macOS Cocoa")
  (depends
    (ocaml (>= 4.08.0))
    (dune (and :build (>= 2.7)))
    (ctypes (>= 0.17.0))
    (ctypes-foreign (>= 0.4.0))))