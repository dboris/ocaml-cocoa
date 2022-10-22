#import <AppKit/AppKit.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <caml/callback.h>
#import <caml/memory.h>
#import <caml/alloc.h>

#import "CamlProxy.h"

@implementation CamlProxy

@synthesize targetObject;
@synthesize camlObject;

- (id)initWithTargetObject:(id)object camlObjectCallbackId:(char *)callbackId {
    [self setTargetObject:object];
    [self setCamlObject:caml_named_value(callbackId)];
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    CAMLparam0();
    CAMLlocal2(methClosure, result);

    NSMethodSignature *ms = [self.targetObject methodSignatureForSelector:sel];
    if (ms == nil) {
        value camlObj = *[self camlObject];
        methClosure = caml_get_public_method(camlObj, caml_hash_variant("methodSignatureForSelector'"));
        NSAssert(methClosure != 0, @"camlObj does not implement methodSignatureForSelector' method");
        result = caml_callback2(methClosure, camlObj, caml_copy_string([NSStringFromSelector(sel) UTF8String]));
        return [NSMethodSignature signatureWithObjCTypes:String_val(result)];
    }
    else {
        return ms;
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation camlMethodClosure:(value)methClosure {
    CAMLparam0();
    CAMLlocal2(argCamlObj, result);

    value camlObj = *[self camlObject];
    SEL sel = [invocation selector];
    NSString *methodName = NSStringFromSelector(sel);
    NSMethodSignature *sig = [self methodSignatureForSelector:sel];
    int implicitMethodArgsCount = 2;  // self, _cmd
    NSUInteger argsCount = [sig numberOfArguments] - implicitMethodArgsCount;
    const char *returnType = [sig methodReturnType];
    // NSLog(@">>> %@ with %lu args and returnType='%s'", methodName, argsCount, returnType);
    void *arg;  // Out param

    // Call back Caml method implementation. Provide param as Caml value.
    switch (argsCount) {
        case 0:
            result = caml_callback(methClosure, camlObj);
            break;
        case 1:
            [invocation getArgument:&arg atIndex:implicitMethodArgsCount];
            const char *argType = [[invocation methodSignature] getArgumentTypeAtIndex:implicitMethodArgsCount];
            if (strcmp(argType, "*") == 0 || strcmp(argType, ":") == 0) {
                // string arg -- call with Caml string value
                result = caml_callback2(methClosure, camlObj, caml_copy_string((char *)arg));
            }
            else if (strcmp(argType, "@") == 0) {
                // arg is an id, i.e. a plain NS object, or a Proxy wrapped object
                id argObj = (id)arg;
                if ([[argObj class] isSubclassOfClass:[self class]]) {
                    // get the associated caml object from the proxy
                    result = caml_callback2(methClosure, camlObj, *[argObj camlObject]);
                }
                else {
                    // plain NS object, must wrap it in appropriate Caml object
                    NSString *argClassName = NSStringFromClass([argObj class]);
                    if ([argObj isKindOfClass:[NSNotification class]]) {
                        // Override NSConcreteNotification
                        argClassName = @"NSNotification";
                    }
                    NSString *wrapClosureName = [NSString stringWithFormat:@"wrap%@", argClassName];
                    const value *wrapClosure = caml_named_value([wrapClosureName UTF8String]);
                    NSAssert(wrapClosure != NULL, @"wrapClosure for %@ not found", argClassName);
                    result = caml_callback2(
                        methClosure,
                        camlObj,
                        caml_callback(*wrapClosure, caml_copy_nativeint((unsigned long)arg))
                    );
                }
            }
            else {
                NSString *expReason = [NSString stringWithFormat:@"%s type arg not implemented", argType];
                // Throw Caml exception?
                @throw [NSException exceptionWithName:@"ProxyArgImplException" reason:expReason userInfo:nil];
            }
            break;
        default:
            // Throw Caml exception?
            @throw [NSException
                exceptionWithName:@"ProxyArgImplException"
                reason:[NSString stringWithFormat:@"pass %lu args not implemented", argsCount]
                userInfo:nil];
    }

    // Set return value of invocation (completes the invocation)
    if (strcmp(returnType, "@") == 0) {
        [invocation setReturnValue:&result];
    }
    else if (strcmp(returnType, "v") == 0) {
        // Void return value, we are done
        [invocation setTarget:nil];
        [invocation invoke];
    }
    else if (strcmp(returnType, "c") == 0) {
        char ret = Bool_val(result);
        [invocation setReturnValue:&ret];
    }
    else {
        NSString *expReason = [NSString stringWithFormat:@"set return value for %s not implemented", returnType];
        // Throw Caml exception?
        @throw [NSException exceptionWithName:@"ProxyArgImplException" reason:expReason userInfo:nil];
    }
    CAMLreturn0;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    CAMLparam0();
    CAMLlocal1(methClosure);

    SEL sel = [invocation selector];
    NSString *methodName = NSStringFromSelector(sel);
    NSString *camlMethodName = [methodName stringByReplacingOccurrencesOfString:@":" withString:@"'"];
    value camlObj = *[self camlObject];
    methClosure = caml_get_public_method(camlObj, caml_hash_variant([camlMethodName UTF8String]));
    bool camlObjectOverridesMethod = methClosure != 0;

    // Proxy receives `forwardInvocation:` from C-side. Must route it to either camlObject or targetObject.
    if (camlObjectOverridesMethod) {
        // camlObject overrides method - forward to camlObject
        [self forwardInvocation:invocation camlMethodClosure:methClosure];
    }
    else if ([methodName isEqualToString:@"respondsToSelector:"]) {
        SEL selArg;
        [invocation getArgument:&selArg atIndex:2];
        NSString *camlMethodName = [NSStringFromSelector(selArg) stringByReplacingOccurrencesOfString:@":" withString:@"'"];
        methClosure = caml_get_public_method(camlObj, caml_hash_variant([camlMethodName UTF8String]));
        bool camlObjectOverridesSelectorArg = methClosure != 0;

        if (camlObjectOverridesSelectorArg) {
            // Method is `respondsToSelector:` and camlObject overrides the selector param, answer YES straight away
            bool ret = true;
            [invocation setReturnValue:&ret];
        }
        else {
            [invocation invokeWithTarget:[self targetObject]];
            // [self protectProxyWithInvocation:invocation];
        }
    }
    else {
        [invocation invokeWithTarget:[self targetObject]];
        // [self protectProxyWithInvocation:invocation];
    }
    CAMLreturn0;
}

// FIXME Causes call to dealloc
// - (void)protectProxyWithInvocation:(NSInvocation *)invocation {
//     // Protect the proxy if return value is the target object
//     const char *returnType = [[self methodSignatureForSelector:[invocation selector]] methodReturnType];
//     if (strcmp(returnType, "@") == 0) {
//         id returnValue;
//         [invocation getReturnValue:&returnValue];
//         if ([self targetObject] == returnValue) {
//             // Substitute target object pointer with proxy pointer
//             void *newValue = (__bridge void *)(self);
//             [invocation setReturnValue:&newValue];
//         }
//     }
// }

- (NSString *)description {
    NSMethodSignature *ms = [NSObject methodSignatureForSelector:_cmd];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
    [inv setSelector:_cmd];
    [self forwardInvocation:inv];
    // FIXME Is this needed?
    NSString *ret;
    [inv getReturnValue:&ret];
    return ret;
}

- (void)dealloc {
    [[self targetObject] release];
    [super dealloc];
}

+ (void)doesNotRecognizeSelector:(SEL)sel {
    // Don't remove next line in order to load this protocol object in runtime.
    Protocol *p = @protocol(NSApplicationDelegate);
    NSLog(@"TODO: doesNotRecognizeSelector:<<%@>>", NSStringFromSelector(sel));
}

// Fixes error when setting up app menu
+ (void)_recursivelyRegisterMenuForKeyEquivalentUniquing:(id)arg1 {
    [[[arg1 targetObject] class] _recursivelyRegisterMenuForKeyEquivalentUniquing:arg1];
}

@end