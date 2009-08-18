//
//  Telefrag.h
//  Telefrag
//
//  Created by chendo on 17/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/objc-class.h>

@interface TPEventTapsController

@end

@interface Telefrag : NSObject {

}

+ (int) getMappedKeycode:(int) keyCode;
+ (void) loadKeymap;
+ (void) load;

@end
