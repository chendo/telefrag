//
//  MethodSwizzle.h
//  Telefrag
//
//  Created by chendo on 17/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <objc/objc.h>

BOOL ClassMethodSwizzle(Class klass, SEL origSel, SEL altSel);
BOOL MethodSwizzle(Class klass, SEL origSel, SEL altSel);
