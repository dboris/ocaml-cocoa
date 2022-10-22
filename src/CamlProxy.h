#import <Foundation/Foundation.h>

#define CAML_NAME_SPACE

#import <caml/mlvalues.h>


@interface CamlProxy : NSProxy

@property (retain) id targetObject;
@property (assign) const value *camlObject;

- (id)initWithTargetObject:(id)object camlObjectCallbackId:(char *)callbackId;

@end