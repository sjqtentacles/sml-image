(* test_bmp_tga.sml -- BMP and TGA decode/encode, padding, and origin/flip. *)

structure BmpTgaTests =
struct
  structure I = Image
  open Support

  fun px (r,g,b,a) = { r=Word8.fromInt r, g=Word8.fromInt g,
                       b=Word8.fromInt b, a=Word8.fromInt a } : I.rgba8

  (* a 3x2 image whose row width (3) forces BMP's 4-byte row padding for 24-bit,
     and exercises non-trivial pixel placement. *)
  fun sample () =
    let
      val img0 = I.fill (3,2) (px (0,0,0,255))
      val img1 = I.setPixel img0 (0,0) (px (10,20,30,255))
      val img2 = I.setPixel img1 (2,0) (px (40,50,60,255))
      val img3 = I.setPixel img2 (0,1) (px (70,80,90,255))
    in I.setPixel img3 (2,1) (px (100,110,120,128)) end

  fun run () =
    let
      val img = sample ()

      val _ = Harness.section "BMP"
      val bmp = I.decodeBmp (I.encodeBmp img)
      val () = Harness.check "BMP 32-bit round-trip (top-down)"
                 (I.getPixel bmp (0,0) = px (10,20,30,255)
                  andalso I.getPixel bmp (2,0) = px (40,50,60,255)
                  andalso I.getPixel bmp (0,1) = px (70,80,90,255)
                  andalso I.getPixel bmp (2,1) = px (100,110,120,128))
      val () = Harness.check "BMP detect" (I.detect (I.encodeBmp img) = SOME I.BMP)

      val _ = Harness.section "TGA"
      val tga = I.decodeTga (I.encodeTga img)
      val () = Harness.check "TGA 32-bit truecolor round-trip"
                 (I.getPixel tga (0,0) = px (10,20,30,255)
                  andalso I.getPixel tga (2,1) = px (100,110,120,128))
    in () end
end
