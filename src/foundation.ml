open Objc

module NSObject = struct
    class t = Base.proxied_object "NSObject"
end

module NSString = struct
    class t = Base.nsstring

    let stringWithUTF8String' = (new t ())#initWithUTF8String'
    let make = stringWithUTF8String'
end

module NSSelector = struct
    let fromString (str : NSString.t) = selector str#_UTF8String
    let make = selector
end

module NSNotification = struct
    class t ?wrap () = object
        inherit Base.standard_object ?wrap "NSNotification"

        (* method initWithName'object'userInfo' _name _obj _info *)

        method name =
            new NSString.t ~wrap:(msgSend obj (selector "name") ~ret:id) ()
    end

    let () = register_wrap_cb "NSNotification" (fun o -> new t ~wrap:(id_from_addr o) ())
end

module NSPoint = struct
    type t
    let t : t structure typ = structure "CGPoint"
    let x = field t "x" double
    let y = field t "y" double
    let () = seal t
    let make ~x:x' ~y:y' =
        let p = make t in
        setf p x x';
        setf p y y';
        p
end

module NSSize = struct
    type t
    let t : t structure typ = structure "CGSize"
    let width = field t "width" double
    let height = field t "height" double
    let () = seal t
    let make ~width:w ~height:h =
        let s = make t in
        setf s width w;
        setf s height h;
        s
end

module NSRect = struct
    type t
    let t : t structure typ = structure "CGRect"
    let origin = field t "origin" NSPoint.t
    let size = field t "size" NSSize.t
    let () = seal t
    let make ~x ~y ~width ~height =
        let r = make t in
        setf r origin (NSPoint.make ~x ~y);
        setf r size (NSSize.make ~width ~height);
        r
end
