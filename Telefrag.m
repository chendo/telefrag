//
//  Telefrag.m
//  Telefrag
//
//  Created by chendo on 17/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Telefrag.h"
#import "MethodSwizzle.h"

@implementation TPEventTapsController (Telefrag)

- (void) _sendEventToListener_s:(id)event{
  //NSLog(@"hook called with %@", event);
  CGEventType type = CGEventGetType(event);
  
  if (1 || type == kCGEventKeyDown || type == kCGEventKeyUp) {
    CGEventFlags f = CGEventGetFlags( event );
    CGKeyCode keyCode = CGEventGetIntegerValueField( event, kCGKeyboardEventKeycode );
    int charCode = (int)keyCode;
    
    
    NSEvent *e = [NSEvent eventWithCGEvent:event];
    NSLog(@"e: %@", e);
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath = @"/Volumes/Data/Users/chendo/Code/Telefrag/build/Debug/Telefrag.bundle/Contents/Resources/Keymap.plist"; //[[NSBundle mainBundle] pathForResource:@"Keymap" ofType:@""];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format errorDescription:&errorDesc];
    
    NSString * k = [NSString stringWithFormat:@"%d", charCode];
    if ([temp objectForKey:k]) {
      NSInteger *value = [temp objectForKey:k];
      NSLog(@"%d => %@", charCode, (NSNumber *)[temp objectForKey:k]);

      CGEventSetIntegerValueField(event, kCGKeyboardEventKeycode, [value intValue]);
    }
  }
  //CFDataRef new_data = CGEventCreateData(NULL, event);
  [self _sendEventToListener_s:event];
}

@end

@implementation TPEventsController (Telefrag)

- (void) postEventWithEventData_s:(id)data {
  //NSLog(@"hook called with %@", event);
  CGEventRef event = CGEventCreateFromData(NULL, data);
  CGEventFlags f = CGEventGetFlags( event );
	CGKeyCode keyCode = CGEventGetIntegerValueField( event, kCGKeyboardEventKeycode );

  


  
  [self postEventWithEventData_s:event];
}

@end


@implementation Telefrag : NSObject

+ (void) load {
  NSLog(@"telefrag loaded");
  
  if (MethodSwizzle(NSClassFromString(@"TPEventTapsController"), @selector(_sendEventToListener:), @selector(_sendEventToListener_s:))) {
    NSLog(@"telefrag swizzled");
  }
  
  if (MethodSwizzle(NSClassFromString(@"TPEventsController"), @selector(postEventWithEventData:), @selector(postEventWithEventData_s:))) {
    NSLog(@"telefrag swizzled");
  }
}

@end
