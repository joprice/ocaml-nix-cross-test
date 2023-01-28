open Ctypes
module Types = Types_generated
open Types

module Functions (F : Ctypes.FOREIGN) = struct
  open F

  type _rw_ops

  let rw_ops_struct : _rw_ops structure typ = structure "SDL_RWops"
  let rw_ops : _rw_ops structure ptr typ = ptr rw_ops_struct
  let rw_ops_opt : _rw_ops structure ptr option typ = ptr_opt rw_ops_struct
  let get_error = foreign "SDL_GetError" (void @-> returning string)

  let rw_from_file =
    foreign "SDL_RWFromFile" (string @-> string @-> returning rw_ops_opt)

  let load_wav_rw =
    foreign "SDL_LoadWAV_RW"
      (rw_ops @-> int @-> ptr AudioSpec.t
      @-> ptr (ptr void)
      @-> ptr uint32_t
      @-> returning (ptr_opt AudioSpec.t))

  let init_sub_system = foreign "SDL_InitSubSystem" (uint32_t @-> returning int)

  (* TODO: type for Allow *)
  let open_audio_device =
    foreign "SDL_OpenAudioDevice"
      (string_opt @-> bool @-> ptr Types.AudioSpec.t @-> ptr Types.AudioSpec.t
     @-> int
      @-> returning int32_as_uint32_t)

  let audio_device_id = int32_as_uint32_t

  let queue_audio =
    foreign "SDL_QueueAudio"
      (audio_device_id @-> ptr void @-> int_as_uint32_t @-> returning int)

  let close_audio_device =
    foreign "SDL_CloseAudioDevice" (audio_device_id @-> returning void)

  let pause_audio_device =
    foreign "SDL_PauseAudioDevice" (audio_device_id @-> bool @-> returning void)

  let free_wav = foreign "SDL_FreeWAV" (ptr void @-> returning void)

  (* only release lock for some code (generate two sets of stubs? *)
  let delay = foreign "SDL_Delay" (int32_t @-> returning void)
  let quit = foreign "SDL_Quit" (void @-> returning void)
end
