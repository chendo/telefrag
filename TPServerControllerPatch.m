//
//  TPServerController.m
//  Telefrag
//
//  Created by chendo on 17/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TFServerController.h"


@implementation TFServerController : NSObject

+ (void)hook_startControlWithInfoDict:(id)arg1 {
  NSLog(@"HOOK CALLED: %@", arg1);
  [self hook_startControlWithInfoDict:arg1];
}

@end
