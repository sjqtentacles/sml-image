(* test_ppm.sml -- Netpbm encode/decode and ASCII/binary parsing. *)

structure PpmTests =
struct
  structure I = Image
  open Support

  fun px (r,g,b,a) = { r=Word8.fromInt r, g=Word8.fromInt g,
                       b=Word8.fromInt b, a=Word8.fromInt a } : I.rgba8

  fun run () =
    let
      val _ = Harness.section "Netpbm round-trip"
      val img = I.setPixel (I.fill (2,2) (px (10,20,30,255))) (1,1) (px (200,100,50,255))
      val back = I.decodePnm (I.encodePpm img)
      val () = Harness.check "P6 encode->decode preserves opaque pixels"
                 (I.getPixel back (1,1) = px (200,100,50,255)
                  andalso I.getPixel back (0,0) = px (10,20,30,255))

      val _ = Harness.section "ASCII P3 parsing"
      val p3 = Byte.stringToBytes "P3\n# a comment\n1 1\n255\n10 20 30\n"
      val a = I.getPixel (I.decodePnm p3) (0,0)
      val () = Harness.check "P3 with comment parses rgb"
                 (a = px (10,20,30,255))

      val _ = Harness.section "binary P6 parsing"
      val p6 = Word8Vector.concat
                 [ Byte.stringToBytes "P6 1 1 255 ",
                   Word8Vector.fromList [0w1, 0w2, 0w3] ]
      val () = Harness.check "P6 raw bytes parse"
                 (I.getPixel (I.decodePnm p6) (0,0) = px (1,2,3,255))

      val _ = Harness.section "PGM (grayscale)"
      val p5 = Word8Vector.concat
                 [ Byte.stringToBytes "P5 2 1 255 ", Word8Vector.fromList [0w64, 0w200] ]
      val g = I.decodePnm p5
      val () = Harness.check "P5 gray expands to r=g=b"
                 (I.getPixel g (0,0) = px (64,64,64,255)
                  andalso I.getPixel g (1,0) = px (200,200,200,255))
    in () end
end
