#import <Foundation/Foundation.h>
#import <caml/mlvalues.h>

@interface CamlProxy : NSProxy

@property (retain) id targetObject;
@property (assign) value *camlObject;

- (id)initWithTargetObject:(id)object camlObjectCallbackId:(char *)callbackId;

@end