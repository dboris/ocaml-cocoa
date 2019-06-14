open Objc
open Foundation

class menu ?wrap () = object (self : 'a)
    inherit Base.standard_object ?wrap "NSMenu"

    method initWithTitle' (title : NSString.t) =
        obj <- msgSend' obj (selector "initWithTitle:") ~a:(id, title#obj) ~ret:id;
        self

    method init_ ~title =
        self#initWithTitle' (NSString.make title)

    method addItem' (item : menu_item) =
        msgSend' obj (selector "addItem:") ~a:(id, item#obj) ~ret:void

    method addItemWithTitle'action'keyEquivalent' (title : NSString.t) action (key : NSString.t) =
        let m =
            msgSend3 obj (selector "addItemWithTitle:action:keyEquivalent:")
                ~a:(id, title#obj)
                ~b:(_SEL, action)
                ~c:(id, key#obj)
                ~ret:id in
        new menu_item ~wrap:m ()

    method addItem_ ~title ~action ~keyEquivalent =
        self#addItemWithTitle'action'keyEquivalent'
            (NSString.make title)
            action
            (NSString.make keyEquivalent)

    (** Assigns a menu to be a submenu of the menu controlled by a given menu item. *)
    method setSubmenu'forItem' (menu : 'a) (item : menu_item) =
        msgSend2 obj (selector "setSubmenu:forItem:")
            ~a:(id, menu#obj)
            ~b:(id, item#obj)
            ~ret:void

    method setSubmenu submenu ~(forItem : menu_item) =
        self#setSubmenu'forItem' submenu forItem

    method setDelegate' (delegate : NSObject.t) =
        msgSend' obj (selector "setDelegate:") ~a:(id, delegate#proxy) ~ret:void

    method numberOfItems =
        msgSend obj (selector "numberOfItems") ~ret:int

    method itemAtIndex' index =
        let m = msgSend' obj (selector "itemAtIndex:") ~a:(int, index) ~ret:id in
        new menu_item ~wrap:m ()
end

and menu_item ?wrap () = object (self)
    inherit Base.standard_object ?wrap "NSMenuItem"

    method initWithTitle'action'keyEquivalent' (title : NSString.t) action (key : NSString.t) =
        obj <- msgSend3 obj (selector "initWithTitle:action:keyEquivalent:")
            ~a:(id, title#obj)
            ~b:(_SEL, action)
            ~c:(id, key#obj)
            ~ret:id;
        self

    method initWith ~title ~action ~keyEquivalent =
        self#initWithTitle'action'keyEquivalent' title action keyEquivalent

    method setSubmenu' (menu : menu) =
        msgSend' obj (selector "setSubmenu:") ~a:(id, menu#obj) ~ret:void

    method setTarget' (target : NSObject.t) =
        msgSend' obj (selector "setTarget:") ~a:(id, target#obj) ~ret:void

    method isEnabled =
        msgSend obj (selector "isEnabled") ~ret:bool

    method hasSubmenu =
        msgSend obj (selector "hasSubmenu") ~ret:bool
end

class virtual nsresponder ?wrap class_name = object
    inherit Base.standard_object ?wrap class_name
end

class nsview ?wrap class_name = object (self)
    inherit nsresponder ?wrap class_name

    method initWithFrame' (frame : NSRect.t structure) =
        obj <- msgSend' obj (selector "initWithFrame:") ~a:(NSRect.t, frame) ~ret:id;
        self

    method frame =
        print_endline "frame start"; flush stdout;
        let f = Objc_api.objc_msgSend (id @-> _SEL @-> returning NSRect.t) obj (selector "frame") in
        print_endline "frame end"; flush stdout;
        f

    method bounds =
        msgSend obj (selector "bounds") ~ret:NSRect.t

    method setFrame' (frame : NSRect.t structure) =
        msgSend' obj (selector "setFrame:") ~a:(NSRect.t, frame) ~ret:void

    method addSubview' (view : nsview) =
        msgSend' obj (selector "addSubview:") ~a:(id, view#obj) ~ret:void
end
