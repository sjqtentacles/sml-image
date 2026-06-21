(* test_png.sml -- PNG decode against authoritative python-zlib fixtures.

   Covers every filter type (None/Sub/Up/Average/Paeth) for RGBA, and the
   grayscale / RGB / grayscale+alpha color types. This is where sml-inflate,
   CRC32, Adler32, and the filter reconstruction all integrate. *)

structure PngTests =
struct
  structure I = Image
  open Support

  fun run () =
    let
      val _ = Harness.section "PNG filter types (RGBA)"
      val () = checkImage "filter None"
                 (Fixtures.width, Fixtures.height, Fixtures.expected)
                 (I.decodePng Fixtures.png_rgba_none)
      val () = checkImage "filter Sub"
                 (Fixtures.width, Fixtures.height, Fixtures.expected)
                 (I.decodePng Fixtures.png_rgba_sub)
      val () = checkImage "filter Up"
                 (Fixtures.width, Fixtures.height, Fixtures.expected)
                 (I.decodePng Fixtures.png_rgba_up)
      val () = checkImage "filter Average"
                 (Fixtures.width, Fixtures.height, Fixtures.expected)
                 (I.decodePng Fixtures.png_rgba_avg)
      val () = checkImage "filter Paeth"
                 (Fixtures.width, Fixtures.height, Fixtures.expected)
                 (I.decodePng Fixtures.png_rgba_paeth)

      val _ = Harness.section "PNG color types"
      val () = checkImage "RGB (alpha forced opaque)"
                 (Fixtures.width, Fixtures.height, Fixtures.expected_opaque)
                 (I.decodePng Fixtures.png_rgb)
      val () = checkImage "grayscale (r=g=b, opaque)"
                 (Fixtures.width, Fixtures.height, Fixtures.expected_gray0)
                 (I.decodePng Fixtures.png_gray)
      val () = checkImage "grayscale + alpha"
                 (Fixtures.width, Fixtures.height, Fixtures.expected_gray)
                 (I.decodePng Fixtures.png_gray_alpha)

      val _ = Harness.section "PNG detect + dispatch"
      val () = Harness.check "detect recognizes PNG"
                 (I.detect Fixtures.png_rgba_none = SOME I.PNG)
      val () = checkImage "decode dispatches to PNG"
                 (Fixtures.width, Fixtures.height, Fixtures.expected)
                 (I.decode Fixtures.png_rgba_none)
    in () end
end
