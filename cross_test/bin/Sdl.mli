open Cross_test_C

type nonrec 'a result = ('a, [ `Msg of string ]) result
type rw_ops
type uint8 = int
type uint16 = int
type int16 = int
type uint32 = int32
type uint64 = int64
type ('a, 'b) bigarray = ('a, 'b, Bigarray.c_layout) Bigarray.Array1.t

type audio_spec = {
  as_freq : int;
  as_format : uint16;
  as_channels : uint8;
  as_silence : uint8;
  as_samples : uint16;
  as_size : uint16;
      (* TODO: callback clashes with ocaml_callback *)
      (* as_callback : audio_callback option; *)
}

val rw_from_file : string -> string -> rw_ops result

val load_wav_rw :
  rw_ops ->
  audio_spec ->
  ('a, 'b) Bigarray.kind ->
  (audio_spec * ('a, 'b) bigarray) result

val init_sub_system : Type.Init.t -> unit result

type audio_device_id = uint32

(* enum for allow *)
val open_audio_device :
  string option ->
  bool ->
  audio_spec ->
  int ->
  (audio_device_id * audio_spec) result

val queue_audio : audio_device_id -> ('a, 'b) bigarray -> unit result
val pause_audio_device : audio_device_id -> bool -> unit
val delay : uint32 -> unit
val close_audio_device : audio_device_id -> unit
val free_wav : ('a, 'b) bigarray -> unit
val quit : unit -> unit
