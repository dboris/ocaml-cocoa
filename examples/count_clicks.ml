open Cocoa
open Objc
open Foundation
open Appkit

let app = NSApplication.sharedApplication

let main_menu =
    let menubar = (new NSMenu.t ())#init_ ~title:"MainMenu" in
    let app_menu = (new NSMenu.t ())#init_ ~title:"Application" in
    menubar#setSubmenu
        app_menu
        ~forItem:(menubar#addItem_ ~title:"Application" ~action:nil_sel ~keyEquivalent:"");
    app_menu#addItem_ ~title:"Quit" ~action:(selector "terminate:") ~keyEquivalent:"q"
    |> ignore;
    menubar

class app_delegate () = object (self)
    inherit NSApplication.delegate "AppDelegate"

    val window = NSWindow.(
        (new t ())#init_
            ~contentRect:(NSRect.make ~x:0. ~y:0. ~width:400. ~height:300.)
            ~styleMask:StyleMask.[titled; closable; resizable]
            ~backing:BackingStoreType.buffered
            ~defer:false)

    val mutable count = 0

    method applicationShouldTerminateAfterLastWindowClosed' (_ : NSNotification.t) =
        true

    method applicationWillFinishLaunching' (_ : NSNotification.t) =
        app#setMainMenu' main_menu;
        window#setTitle' (NSString.make "Hello world");
        window#cascadeTopLeftFromPoint' (NSPoint.make ~x:20. ~y:20.)

    method methodSignatureForSelector' selector =
        if selector = "increment" then method_signature ~args:[Id] ~ret:Void
        else failwith ("Selector not recognised: " ^ selector)

    method increment (sender : NSButton.t) =
        count <- count + 1;
        NSString.make (Printf.sprintf "Click me! (%d)" count)
        |> sender#setTitle'

    method applicationDidFinishLaunching' (_ : NSNotification.t) =
        let button = NSButton.button_
            ~title:(NSString.make "Click me! (0)")
            ~target:(self :> NSObject.t)
            ~action:(selector "increment") in
        button#setFrame' (NSRect.make ~x:16. ~y:256. ~width:120. ~height:32.);
        window#contentView#addSubview' (button :> NSView.t);
        window#makeKeyAndOrderFront' nil_id
end

let () =
    assert NSApplication.(app#setActivationPolicy' ActivationPolicy.regular);
    app#setDelegate' ((new app_delegate ())#init :> NSApplication.delegate);
    app#run;
    app#activateIgnoringOtherApps' true
