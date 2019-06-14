open Objc_types

let object_getClassName =
    Foreign.foreign "object_getClassName"
    (id @-> returning string)

let object_getInstanceVariable =
    Foreign.foreign "object_getInstanceVariable"
    (id @-> string @-> ptr (ptr void) @-> returning _Ivar)

let object_setInstanceVariable =
    Foreign.foreign "object_setInstanceVariable"
    (id @-> string @-> ptr void @-> returning _Ivar)

let object_getIvar =
    Foreign.foreign "object_getIvar"
    (id @-> _Ivar @-> returning id)

let sel_registerName =
    Foreign.foreign "sel_registerName"
    (string @-> returning _SEL)

let sel_getName =
    Foreign.foreign "sel_getName"
    (_SEL @-> returning string)

let property_copyAttributeValue =
    Foreign.foreign "property_copyAttributeValue"
    (objc_property_t @-> string @-> returning string)

let class_getName =
    Foreign.foreign "class_getName"
    (_Class @-> returning string)

let class_createInstance =
    Foreign.foreign "class_createInstance"
    (_Class @-> size_t @-> returning id)

let class_addMethod =
    Foreign.foreign "class_addMethod"
    (_Class @-> _SEL @-> _IMP @-> types @-> returning bool)

let class_replaceMethod =
    Foreign.foreign "class_replaceMethod"
    (_Class @-> _SEL @-> _IMP @-> types @-> returning _IMP)

let class_addIvar =
    Foreign.foreign "class_addIvar"
    (_Class @-> string @-> size_t @-> uint8_t @-> types @-> returning bool)

let class_getInstanceSize =
    Foreign.foreign "class_getInstanceSize"
    (_Class @-> returning size_t)

let objc_getClass =
    Foreign.foreign "objc_getClass"
    (string @-> returning _Class)

let objc_getClassList =
    Foreign.foreign "objc_getClassList"
    (ptr _Class @-> int @-> returning int)

let objc_allocateClassPair =
    Foreign.foreign "objc_allocateClassPair"
    (_Class @-> string @-> size_t @-> returning _Class)

let objc_registerClassPair =
    Foreign.foreign "objc_registerClassPair"
    (_Class @-> returning void)

let objc_getMetaClass =
    Foreign.foreign "objc_getMetaClass"
    (string @-> returning _Class)

let objc_msgSend ty =
    Foreign.foreign "objc_msgSend" ty

let objc_getProtocol =
    Foreign.foreign "objc_getProtocol"
    (string @-> returning _Protocol)

let class_addProtocol =
    Foreign.foreign "class_addProtocol"
    (_Class @-> _Protocol @-> returning bool)
