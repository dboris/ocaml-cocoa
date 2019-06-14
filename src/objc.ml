open Objc_api

include Objc_types
include Unsigned

(* Can I use `objc_type` types to have a single msgSend fn? *)

let msgSend ~ret = objc_msgSend (id @-> _SEL @-> returning ret)

let msgSend' ~ret ~a target sel =
    objc_msgSend (id @-> _SEL @-> fst a @-> returning ret)
    target sel (snd a)

let msgSend2 ~ret ~a ~b target sel =
    objc_msgSend (id @-> _SEL @-> fst a @-> fst b @-> returning ret)
    target sel (snd a) (snd b)

let msgSend3 ~ret ~a ~b ~c target sel =
    objc_msgSend (id @-> _SEL @-> fst a @-> fst b @-> fst c @-> returning ret)
    target sel (snd a) (snd b) (snd c)

let msgSend4 ~ret ~a ~b ~c ~d target sel =
    objc_msgSend (id @-> _SEL @-> fst a @-> fst b @-> fst c @-> fst d @-> returning ret)
    target sel (snd a) (snd b) (snd c) (snd d)

let msgSend5 ~ret ~a ~b ~c ~d ~e target sel =
    objc_msgSend (id @-> _SEL @-> fst a @-> fst b @-> fst c @-> fst d @-> fst e @-> returning ret)
    target sel (snd a) (snd b) (snd c) (snd d) (snd e)

let getClass = objc_getClass
let selector = sel_registerName

let retain obj =
    msgSend obj (selector "retain") ~ret:id

let release obj =
    msgSend obj (selector "release") ~ret:void

let alloc class_ =
    msgSend class_ (selector "alloc") ~ret:id

let init obj =
    msgSend obj (selector "init") ~ret:id

(* Util *)

let newProxy ~targetObject ~camlObjectCallbackId =
    let proxy_class = getClass "CamlProxy" in
    assert (not (is_null (coerce _Class (ptr void) proxy_class)));
    msgSend2 (alloc proxy_class) (selector "initWithTargetObject:camlObjectCallbackId:")
        ~a:(id, targetObject)
        ~b:(string, camlObjectCallbackId)
        ~ret:id

let register_wrap_cb class_name cb =
    Callback.register (Printf.sprintf "wrap%s" class_name) cb

let combine_options = List.fold_left UInt.logor UInt.zero

let method_signature ?(args = []) ~ret =
    (* Implicit args: self and _cmd *)
    encode_type ret :: encode_type Id :: encode_type SEL :: List.map encode_type args
    |> String.concat ""

let nil_sel = coerce (ptr void) _SEL null
let nil_id = coerce (ptr void) id null

let id_from_addr addr =
    coerce (ptr void) id (ptr_of_raw_address addr)