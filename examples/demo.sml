(* sml-image demo: builds a deterministic RGBA raster (a radial disc over a
   coordinate gradient with a grid and border), encodes it to PNG via
   Image.encodePng, round-trips it back through Image.decode to prove the codec
   is self-consistent, then writes assets/demo.png.

   Output is byte-identical across MLton and Poly/ML: the raster is built purely
   from integer arithmetic and the PNG encoder is deterministic. *)

val width = 256
val height = 256

fun clampByte n = if n < 0 then 0 else if n > 255 then 255 else n

(* Pixel color as (r,g,b,a) for integer coordinates (x,y). *)
fun colorAt (x, y) =
  let
    val dx = x - 128
    val dy = y - 128
    val d2 = dx * dx + dy * dy
    val onGrid = (x mod 32 = 0) orelse (y mod 32 = 0)
    val onBorder = x = 0 orelse y = 0 orelse x = width - 1 orelse y = height - 1
  in
    if onBorder then (235, 235, 235, 255)
    else if d2 <= 78 * 78 then
      (* solid disc with a soft radial falloff toward the rim *)
      let val shade = clampByte (255 - (d2 * 70) div (78 * 78))
      in (shade, clampByte (shade - 80), 40, 255) end
    else if d2 <= 86 * 86 then (250, 250, 250, 255)  (* disc outline ring *)
    else if onGrid then (52, 58, 70, 255)            (* grid lines *)
    else (clampByte x, clampByte y, 110, 255)        (* gradient background *)
  end

val data =
  Word8Vector.tabulate
    (4 * width * height, fn i =>
       let
         val p = i div 4
         val ch = i mod 4
         val x = p mod width
         val y = p div width
         val (r, g, b, a) = colorAt (x, y)
         val v = case ch of 0 => r | 1 => g | 2 => b | _ => a
       in
         Word8.fromInt v
       end)

val img : Image.image = { width = width, height = height, data = data }

val png = Image.encodePng img

(* Self-check: decoding our own PNG must reproduce the exact raster. *)
val () =
  let
    val back = Image.decode png
    val { width = w', height = h', data = d' } = back
  in
    if w' = width andalso h' = height andalso d' = data
    then ()
    else raise Fail "demo: PNG round-trip mismatch"
  end

val () =
  let val os = BinIO.openOut "assets/demo.png"
  in BinIO.output (os, png); BinIO.closeOut os end

val () =
  print ("wrote assets/demo.png (" ^ Int.toString width ^ "x"
         ^ Int.toString height ^ " RGBA, " ^ Int.toString (Word8Vector.length png)
         ^ " bytes)\n")
