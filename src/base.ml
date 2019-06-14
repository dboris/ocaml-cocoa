open Objc

class standard_object ?wrap class_name = object (self)
    val mutable obj = nil_id
    (** The wrapped Cocoa object *)

    method obj = obj

    method private alloc =
        obj <- match wrap with
            | Some o -> retain o
            | None -> alloc (getClass class_name)

    method dealloc =
        print_endline "$!"; flush stdout;
        release obj

    method init =
        obj <- init obj;
        self

    method description =
        new nsstring ~wrap:(msgSend obj (selector "description") ~ret:id) ()
        |> ((new nsstring ())#initWithUTF8String' "Standard object: ")#stringByAppendingString'

    initializer Gc.finalise (fun o -> o#dealloc) self; self#alloc
end

and nsstring ?wrap () = object (self)
    inherit standard_object ?wrap "NSString"

    method initWithUTF8String' str =
        obj <- msgSend' obj (selector "initWithUTF8String:") ~a:(string, str) ~ret:id;
        self

    method _UTF8String =
        msgSend obj (selector "UTF8String") ~ret:string

    method stringByAppendingString' (str : nsstring) =
        let s = msgSend' obj (selector "stringByAppendingString:") ~a:(id, str#obj) ~ret:id in
        new nsstring ~wrap:s ()
end

class proxied_object ?wrap class_name = object (self)
    inherit standard_object ?wrap class_name as super

    val mutable proxy = nil_id
    (** The ObjC proxy object that bridges ObjC and Caml *)

    method proxy = proxy

    method private obj_id = Printf.sprintf "obj%i" (Oo.id self)

    method! init =
        ignore super#init;
        assert (not (is_null (coerce id (ptr void) obj)));
        proxy <- newProxy ~targetObject:obj ~camlObjectCallbackId:self#obj_id;
        self

    method! dealloc =
        print_endline "$!"; flush stdout;
        release proxy;
        (* FIXME Will calling super#dealloc overrelease obj? *)
        (* super#dealloc *)

    initializer
        Callback.register self#obj_id self;
        Gc.finalise (fun o -> o#dealloc) self
end

class custom_object class_name superclass_name (protocol_names : string list) = object
    inherit proxied_object class_name

    method! private alloc =
        let registered_class = getClass class_name in
        let cls =
            if (not (is_null (coerce _Class (ptr void) registered_class))) then registered_class
            else
                let open Objc_api in
                let alloc_class =
                    objc_allocateClassPair
                        (getClass superclass_name)
                        class_name
                        (Unsigned.Size_t.of_int 0) in
                let add_protocol p_name =
                    let p = objc_getProtocol p_name in
                    assert(not (is_null (coerce _Protocol (ptr void) p)));
                    assert(class_addProtocol alloc_class p) in
                List.iter add_protocol protocol_names;
                objc_registerClassPair alloc_class;
                alloc_class
        in
        obj <- alloc cls
end
