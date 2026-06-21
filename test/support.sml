(* support.sml -- shared helpers for image tests. *)

structure Support =
struct
  structure I = Image

  fun dataEq (a : Word8Vector.vector, b : Word8Vector.vector) =
    Word8Vector.length a = Word8Vector.length b
    andalso Word8Vector.foldli
              (fn (i, x, ok) => ok andalso Word8Vector.sub (b, i) = x) true a

  (* compare a decoded image's pixels to a flat expected RGBA8 vector *)
  fun checkImage name (w, h, expected) (img : I.image) =
    let
      val { width, height, data } = img
      val ok = width = w andalso height = h andalso dataEq (expected, data)
    in
      if ok then Harness.check name true
      else
        ( Harness.check name false
        ; print ("       dims " ^ Int.toString width ^ "x" ^ Int.toString height
                 ^ " (want " ^ Int.toString w ^ "x" ^ Int.toString h ^ "), "
                 ^ "len " ^ Int.toString (Word8Vector.length data)
                 ^ " vs " ^ Int.toString (Word8Vector.length expected) ^ "\n") )
    end

  fun checkData name (expected, actual) =
    Harness.check name (dataEq (expected, actual))
end
