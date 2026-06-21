(* entry.sml -- runs every suite, prints the summary, exits with status. *)

fun runAllSuites () =
  ( Harness.reset ()
  ; PpmTests.run ()
  ; BmpTgaTests.run ()
  ; PngTests.run ()
  ; RoundtripTests.run ()
  ; EdgeTests.run ()
  ; Harness.run () )

fun main () =
  OS.Process.exit
    (if runAllSuites () then OS.Process.success else OS.Process.failure)
