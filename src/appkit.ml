open Objc
open Foundation

module NSResponder = struct
    (** An abstract class that forms the basis of event and command processing in AppKit.
        The core classes — NSApplication, NSWindow, and NSView — inherit from NSResponder,
        as must any class that handles events.
     *)
    class t = Appkit_internal.nsresponder
end

module NSView = struct
    (** The infrastructure for drawing, printing, and handling events in an app. *)
    class t = Appkit_internal.nsview
    let () = register_wrap_cb "NSView" (fun o -> new t ~wrap:(id_from_addr o) "NSView")
end

module NSControl = struct
    (** A definition of the fundamental behavior for controls, which are specialized views
        that notify your app of relevant events by using the target-action design pattern.
     *)
    class virtual t ?wrap class_name = object
        inherit NSView.t ?wrap class_name
    end
end

module NSButton = struct
    class t ?wrap class_name = object
        inherit NSControl.t ?wrap class_name

        method setTitle' (title : NSString.t) =
            msgSend' obj (selector "setTitle:") ~a:(id, title#obj) ~ret:void

    end
    let () = register_wrap_cb "NSButton" (fun o -> new t ~wrap:(id_from_addr o) "NSButton")
    let class_ = getClass "NSButton"
    let button_ ~(title : NSString.t) ~(target : NSObject.t) ~action =
        let b = msgSend3 class_ (selector "buttonWithTitle:target:action:")
            ~a:(id, title#obj)
            ~b:(id, target#proxy)
            ~c:(_SEL, action)
            ~ret:id in
        new t ~wrap:b "NSButton"
end

module NSWindow = Nswindow

module NSMenuItem = struct
    class t = Appkit_internal.menu_item
    let () = register_wrap_cb "NSMenuItem" (fun o -> new t ~wrap:(id_from_addr o) ())
end

module NSMenu = struct
    class t = Appkit_internal.menu
    let () = register_wrap_cb "NSMenu" (fun o -> new t ~wrap:(id_from_addr o) ())
end

module NSMenuDelegate = struct
    class t class_name = object
        inherit Base.custom_object class_name "NSObject" ["NSMenuDelegate"]
    end
end

module NSApplication = struct
    module ActivationPolicy = struct
        let t = int
        let regular = 0
        let accessory = 1
        let prohibited = 2
    end

    module ActivationOptions = struct
        let t = uint
        let activateAllWindows = UInt.(shift_left one 0)
        let activateIgnoringOtherApps = UInt.(shift_left one 1)
    end

    class virtual delegate class_name = object
        inherit Base.custom_object class_name "NSObject" ["NSApplicationDelegate"]
    end

    class t ?wrap () = object
        inherit Base.standard_object ?wrap "NSApplication"

        method setDelegate' (delegate : delegate) =
            msgSend' obj (selector "setDelegate:") ~a:(id, delegate#proxy) ~ret:void

        method setActivationPolicy' policy =
            msgSend' obj (selector "setActivationPolicy:") ~a:(ActivationPolicy.t, policy) ~ret:bool

        method mainMenu =
            let m = msgSend obj (selector "mainMenu") ~ret:id in
            if is_null (coerce id (ptr void) m) then None
            else Some (new NSMenu.t ~wrap:m ())

        method setMainMenu' (menu : NSMenu.t) =
            msgSend' obj (selector "setMainMenu:") ~a:(id, menu#obj) ~ret:void

        method activateIgnoringOtherApps' opt =
            msgSend' obj (selector "activateIgnoringOtherApps:") ~a:(bool, opt) ~ret:void

        method activateWithOptions' options =
            msgSend' obj (selector "activateWithOptions:") ~a:(ActivationOptions.t, options) ~ret:bool

        method run =
            msgSend obj (selector "run") ~ret:void
    end

    let sharedApplication =
        new t ~wrap:(msgSend ~ret:id (getClass "NSApplication") (selector "sharedApplication")) ()

    let () = register_wrap_cb "NSApplication" (fun o -> new t ~wrap:(id_from_addr o) ())
end
