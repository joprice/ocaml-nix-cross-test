open Ctypes

module Types (F : Ctypes.TYPE) = struct
  open F

  let int_as_uint8_t =
    view ~read:Unsigned.UInt8.to_int ~write:Unsigned.UInt8.of_int uint8_t

  let int_as_uint16_t =
    view ~read:Unsigned.UInt16.to_int ~write:Unsigned.UInt16.of_int uint16_t

  let int_as_uint32_t =
    view ~read:Unsigned.UInt32.to_int ~write:Unsigned.UInt32.of_int uint32_t

  let int32_as_uint32_t =
    view ~read:Unsigned.UInt32.to_int32 ~write:Unsigned.UInt32.of_int32 uint32_t

  module AudioFormat = struct
    (* type t = Unsigned.uint16 typ *)
    (* type t = int *)

    (* let format = int_as_uint16_t *)
    let t = int_as_uint16_t
    let format value = constant value t
    let s16_lsb = format "AUDIO_S16LSB"

    (* let t = format "SDL_AUDIO_MASK_BITSIZE" *)
  end

  module AudioSpec = struct
    type t = [ `AudioSpec ] structure

    let t : t typ = typedef (structure "`AudioSpec") "SDL_AudioSpec"

    (* let audio_spec : t structure typ = structure "SDL_AudioSpec" *)
    let freq = field t "freq" int
    let format = field t "format" AudioFormat.t
    let channels = field t "channels" int_as_uint8_t
    let silence = field t "silence" int_as_uint8_t
    let samples = field t "samples" int_as_uint16_t
    let _ = field t "padding" int_as_uint16_t
    let size = field t "size" int_as_uint32_t

    (* let callback = ptr void @-> ptr uint8_t @-> int @-> returning void *)
    (* let callback = field t "callback" (static_funptr callback) *)
    let () = seal t

    (* as_format : Audio.format; *)
    (*   as_channels : uint8_t; *)
    (*   as_silence : uint8; *)
    (*   as_samples : uint8; *)
    (*   as_size : uint32; *)
    (*   as_callback : audio_callback option; *)
    (* } *)
  end

  module Init = struct
    type t = int

    let t = int_as_uint32_t
    let format value = constant value t
    let audio = format "SDL_INIT_AUDIO"
  end
end
