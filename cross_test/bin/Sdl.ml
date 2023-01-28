open Ctypes
open Cross_test_C
open Functions

type nonrec 'a result = ('a, [ `Msg of string ]) result

let error () = Error (`Msg (get_error ()))

let some_to_ok t =
  let read = function Some v -> Ok v | None -> error () in
  read t

type uint8 = int
type uint16 = int
type int16 = int
type uint32 = int32
type uint64 = int64

type audio_spec = {
  as_freq : int;
  as_format : uint16;
  as_channels : uint8;
  as_silence : uint8;
  as_samples : uint16;
  as_size : uint16;
}

let audio_spec_to_c a =
  let open Type.AudioSpec in
  let c = make Type.AudioSpec.t in
  setf c freq a.as_freq;
  setf c format a.as_format;
  setf c channels a.as_channels;
  setf c silence a.as_silence;
  setf c samples a.as_samples;
  setf c size a.as_size;
  (* setf c callback a.as_callback; *)
  (* setf c userdata null; *)
  c

let audio_spec_of_c c =
  let open Type.AudioSpec in
  let as_freq = getf c freq in
  let as_format = getf c format in
  let as_channels = getf c channels in
  let as_silence = getf c silence in
  let as_samples = getf c samples in
  let as_size = getf c size in
  (* let as_callback = None in *)
  {
    as_freq;
    as_format;
    as_channels;
    as_silence;
    as_samples;
    as_size;
    (* as_callback; *)
  }

type rw_ops = _rw_ops structure ptr

let ba_kind_byte_size : ('a, 'b) Bigarray.kind -> int =
 fun k ->
  let open Bigarray in
  (* FIXME: see http://caml.inria.fr/mantis/view.php?id=6263 *)
  match Obj.magic k with
  | k when k = char || k = int8_signed || k = int8_unsigned -> 1
  | k when k = int16_signed || k = int16_unsigned -> 2
  | k when k = int32 || k = float32 -> 4
  | k when k = float64 || k = int64 || k = complex32 -> 8
  | k when k = complex64 -> 16
  | k when k = int || k = nativeint -> Sys.word_size / 8
  | _ -> assert false

let access_ptr_typ_of_ba_kind : ('a, 'b) Bigarray.kind -> 'a ptr typ =
 fun k ->
  let open Bigarray in
  (* FIXME: use typ_of_bigarray_kind when ctypes support it. *)
  match Obj.magic k with
  | k when k = float32 -> Obj.magic (ptr Ctypes.float)
  | k when k = float64 -> Obj.magic (ptr Ctypes.double)
  | k when k = complex32 -> Obj.magic (ptr Ctypes.complex32)
  | k when k = complex64 -> Obj.magic (ptr Ctypes.complex64)
  | k when k = int8_signed -> Obj.magic (ptr Ctypes.int8_t)
  | k when k = int8_unsigned -> Obj.magic (ptr Ctypes.uint8_t)
  | k when k = int16_signed -> Obj.magic (ptr Ctypes.int16_t)
  | k when k = int16_unsigned -> Obj.magic (ptr Ctypes.uint16_t)
  | k when k = int -> Obj.magic (ptr Ctypes.camlint)
  | k when k = int32 -> Obj.magic (ptr Ctypes.int32_t)
  | k when k = int64 -> Obj.magic (ptr Ctypes.int64_t)
  | k when k = nativeint -> Obj.magic (ptr Ctypes.nativeint)
  | k when k = char -> Obj.magic (ptr Ctypes.char)
  | _ -> assert false

let str = Printf.sprintf

let err_bigarray_data len ba_el_size =
  str
    "invalid bigarray kind: data (%d bytes) not a multiple of bigarray element \
     byte size (%d)"
    len ba_el_size

let rw_from_file file access = rw_from_file file access |> some_to_ok

type ('a, 'b) bigarray = ('a, 'b, Bigarray.c_layout) Bigarray.Array1.t

let load_wav_rw (ops : rw_ops) (spec : audio_spec)
    (kind : ('a, 'b) Bigarray.kind) : (audio_spec * ('a, 'b) bigarray) result =
  let d = allocate (ptr void) null in
  let len = allocate uint32_t Unsigned.UInt32.zero in
  match load_wav_rw ops 0 (addr (audio_spec_to_c spec)) d len |> some_to_ok with
  | Error _ as e -> e
  | Ok r ->
      let rspec = audio_spec_of_c !@r in
      let kind_size = ba_kind_byte_size kind in
      let len = Unsigned.UInt32.to_int !@len in
      if len mod kind_size <> 0 then
        invalid_arg (err_bigarray_data len kind_size)
      else
        let ba_size = len / kind_size in
        let ba_ptr = access_ptr_typ_of_ba_kind kind in
        let d = coerce (ptr void) ba_ptr !@d in
        Ok (rspec, bigarray_of_ptr array1 ba_size kind d)

let zero_to_ok = function 0 -> Ok () | _ -> error ()

let init_sub_system system =
  zero_to_ok (init_sub_system (Unsigned.UInt32.of_int system))

type audio_device_id = uint32

(* enum for allow *)
let open_audio_device dev capture desired allow =
  let desiredc = audio_spec_to_c desired in
  let obtained = make Type.AudioSpec.t in
  match open_audio_device dev capture (addr desiredc) (addr obtained) allow with
  | id when id = Int32.zero -> error ()
  | id -> Ok (id, audio_spec_of_c obtained)

let queue_audio dev ba =
  let len = Bigarray.Array1.dim ba in
  let kind_size = ba_kind_byte_size (Bigarray.Array1.kind ba) in
  zero_to_ok
    (queue_audio dev (to_voidp (bigarray_start array1 ba)) (len * kind_size))

let pause_audio_device = pause_audio_device

(* TODO: release runtime lock *)
let delay = delay
let close_audio_device = close_audio_device
let free_wav ba = free_wav (to_voidp (bigarray_start array1 ba))
let quit = quit
