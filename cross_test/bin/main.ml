open Cross_test_C

let ( let* ) = Result.bind

let () =
  let open Sdl in
  let print_spec spec =
    Printf.printf
      "as_freq=%d, as_format=%d, as_channels=%d, as_silence=%d as_samples=%d \
       as_size = %d\n"
      spec.as_freq spec.as_format spec.as_channels spec.as_silence
      spec.as_samples spec.as_size
  in
  let result =
    let file = "./test.wav" in
    let* file = Sdl.rw_from_file file "rb" in
    let format = Type.AudioFormat.s16_lsb in
    let spec =
      {
        as_freq = 44100;
        as_format = format;
        as_channels = 2;
        as_silence = 0;
        (* as_callback = None; *)
        as_samples = 4096;
        as_size = 8192;
      }
    in
    let* () = init_sub_system Type.Init.audio in
    print_spec spec;
    let* spec, data = Sdl.load_wav_rw file spec Bigarray.Int16_signed in
    print_spec spec;
    let* device, _ = open_audio_device None false spec 0 in
    let* () = queue_audio device data in
    let () = pause_audio_device device false in
    delay 5000l;
    close_audio_device device;
    free_wav data;
    quit ();
    Ok data
  in
  result |> Result.iter_error (fun (`Msg error) -> print_endline error)
