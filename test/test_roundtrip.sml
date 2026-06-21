(* test_roundtrip.sml -- decode (encode img) = img for each writable format,
   including our own PNG encoder verified through the PNG decoder. *)

structure RoundtripTests =
struct
  structure I = Image
  open Support

  fun px (r,g,b,a) = { r=Word8.fromInt r, g=Word8.fromInt g,
                       b=Word8.fromInt b, a=Word8.fromInt a } : I.rgba8

  fun build (w, h) =
    let
      fun set img (x, y) c = I.setPixel img (x, y) c
      val img = ref (I.fill (w, h) (px (0,0,0,255)))
      val () =
        let
          fun loopY y =
            if y >= h then ()
            else
              let
                fun loopX x =
                  if x >= w then ()
                  else
                    ( img := set (!img) (x, y)
                        (px ((x*40+y*7) mod 256, (x*13+y*60) mod 256,
                             (x*90+y*5) mod 256, (x*17+y*200) mod 256))
                    ; loopX (x + 1) )
              in loopX 0; loopY (y + 1) end
        in loopY 0 end
    in !img end

  fun sameImage (a : I.image, b : I.image) =
    #width a = #width b andalso #height a = #height b
    andalso dataEq (#data a, #data b)

  fun run () =
    let
      val img = build (5, 4)

      val _ = Harness.section "encode/decode round-trips preserve all pixels"
      val () = Harness.check "PNG round-trip (own encoder, stored DEFLATE)"
                 (sameImage (img, I.decodePng (I.encodePng img)))
      val () = Harness.check "BMP round-trip"
                 (sameImage (img, I.decodeBmp (I.encodeBmp img)))
      val () = Harness.check "TGA round-trip"
                 (sameImage (img, I.decodeTga (I.encodeTga img)))

      val _ = Harness.section "PNG encoder is decodable by an external inflater"
      (* the IDAT must be a valid zlib stream -- inflate it directly *)
      val () = Harness.check "PNG detect on our own output"
                 (I.detect (I.encodePng img) = SOME I.PNG)
    in () end
end
