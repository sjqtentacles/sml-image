(* test_edge.sml -- degenerate sizes and malformed inputs raise Image cleanly. *)

structure EdgeTests =
struct
  structure I = Image
  open Support

  fun px (r,g,b,a) = { r=Word8.fromInt r, g=Word8.fromInt g,
                       b=Word8.fromInt b, a=Word8.fromInt a } : I.rgba8

  fun truncEnd (v, n) =
    Word8VectorSlice.vector
      (Word8VectorSlice.slice (v, 0, SOME (Word8Vector.length v - n)))

  fun run () =
    let
      val _ = Harness.section "degenerate dimensions"
      val one = I.fill (1,1) (px (5,6,7,8))
      val () = Harness.check "1x1 PNG round-trip"
                 (I.getPixel (I.decodePng (I.encodePng one)) (0,0) = px (5,6,7,8))
      val () = Harness.check "1x1 BMP round-trip"
                 (I.getPixel (I.decodeBmp (I.encodeBmp one)) (0,0) = px (5,6,7,8))
      val zeroW = I.fill (0, 3) (px (0,0,0,255))
      val () = Harness.check "0-width image has empty data"
                 (Word8Vector.length (#data zeroW) = 0)
      val () = Harness.check "PNG round-trip of 0-dim image"
                 (let val d = I.decodePng (I.encodePng zeroW)
                  in #width d = 0 andalso #height d = 3 end)

      val _ = Harness.section "out-of-range pixel access"
      val () = Harness.checkRaises "getPixel beyond width"
                 (fn () => I.getPixel one (1, 0))
      val () = Harness.checkRaises "getPixel negative"
                 (fn () => I.getPixel one (~1, 0))

      val _ = Harness.section "malformed PNG"
      val () = Harness.checkRaises "bad PNG signature"
                 (fn () => I.decodePng (Word8Vector.fromList [0w0,0w1,0w2,0w3,0w4,0w5,0w6,0w7,0w8]))
      val () = Harness.checkRaises "truncated PNG (no IEND)"
                 (fn () => I.decodePng (truncEnd (Fixtures.png_rgba_none, 12)))
      val () = Harness.checkRaises "corrupt IDAT zlib (bad adler)"
                 (fn () =>
                    let
                      val v = Fixtures.png_rgba_none
                      val n = Word8Vector.length v
                      (* flip a byte inside the IDAT region (not the trailing CRC) *)
                      val corrupt =
                        Word8Vector.mapi
                          (fn (i, b) => if i = 40 then b + 0w1 else b) v
                    in I.decodePng corrupt end)

      val _ = Harness.section "malformed BMP / TGA"
      val () = Harness.checkRaises "bad BMP magic"
                 (fn () => I.decodeBmp (Word8Vector.fromList [0w0,0w0,0w0,0w0]))
      val () = Harness.checkRaises "TGA RLE type unsupported"
                 (fn () =>
                    let val v = I.encodeTga one
                    in I.decodeTga (Word8Vector.mapi
                         (fn (i,b) => if i = 2 then 0w10 (* RLE truecolor *) else b) v)
                    end)

      val _ = Harness.section "format detection"
      val () = Harness.check "detect returns NONE on garbage"
                 (I.detect (Word8Vector.fromList [0w0, 0w1]) = NONE)
    in () end
end
