open Objc
open Foundation

module StyleMask = struct
    let t = uint
    let borderless = UInt.zero
    let titled = UInt.(shift_left one 0)
    let closable = UInt.(shift_left one 1)
    let miniaturizable = UInt.(shift_left one 2)
    let resizable = UInt.(shift_left one 3)
    let texturedBackground = UInt.(shift_left one 8)
    let unifiedTitleAndToolbar = UInt.(shift_left one 12)
    let fullScreen = UInt.(shift_left one 14)
    let fullSizeContentView = UInt.(shift_left one 15)

    (* The following are only applicable for NSPanel *)
    let utilityWindow = UInt.(shift_left one 4)
    let docModalWindow = UInt.(shift_left one 6)
    let nonactivatingPanel = UInt.(shift_left one 7)
    let _HUDWindow = UInt.(shift_left one 13)
end

module BackingStoreType = struct
    let t = uint
    let buffered = UInt.of_int 2
end

class t () = object (self)
    inherit Base.standard_object "NSWindow"

    method initWithContentRect'styleMask'backing'defer' rect style backing defer =
        obj <- msgSend4 obj (selector "initWithContentRect:styleMask:backing:defer:")
            ~a:(NSRect.t, rect)
            ~b:(StyleMask.t, combine_options style)
            ~c:(BackingStoreType.t, backing)
            ~d:(bool, defer)
            ~ret:id;
        self

    method init_ ~contentRect ~styleMask ~backing ~defer =
        self#initWithContentRect'styleMask'backing'defer' contentRect styleMask backing defer

    method contentView =
        let cv = msgSend obj (selector "contentView") ~ret:id in
        new Appkit_internal.nsview ~wrap:cv "NSView"

    method makeKeyAndOrderFront' sender =
        msgSend' obj (selector "makeKeyAndOrderFront:") ~a:(id, sender) ~ret:void

    method setTitle' (title : NSString.t) =
        msgSend' obj (selector "setTitle:") ~a:(id, title#obj) ~ret:void

    method cascadeTopLeftFromPoint' point =
        msgSend' obj (selector "cascadeTopLeftFromPoint:") ~a:(NSPoint.t, point) ~ret:void
end

let windowWithContentViewController' = ()
