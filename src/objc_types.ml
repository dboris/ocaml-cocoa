(* Extends Ctypes with common ObjC types. *)

include Ctypes

include (
    struct
        type 'a opaque = unit ptr
        let opaque = ptr void
    end : sig
        type 'a opaque
        val opaque : 'a opaque typ
    end)

type objc_type = Id | SEL | Void | String | Bool | Int | Float | Double | Class

(* val reference_type : 'a ptr -> 'a typ *)

let encode_type = function
    | Id -> "@"
    | SEL -> ":"
    | Void -> "v"
    | String -> "*"
    | Bool -> "c"
    | Int -> "i"
    | Float -> "f"
    | Double -> "d"
    | Class -> "#"

type id
let id : id opaque typ = opaque
let _Class = id

type _Protocol
let _Protocol : _Protocol opaque typ = opaque

type _IMP
let _IMP : _IMP opaque typ = opaque

type _Ivar
let _Ivar : _Ivar opaque typ = opaque

type objc_property_t
let objc_property_t : objc_property_t opaque typ = opaque

let _SEL = ptr char

let types = string

let nil = null
