//
//  Telefrag.m
//  Telefrag
//
//  Created by chendo on 17/08/09.
//  Copyright 2009 chendo. All rights reserved.
//

#import "Telefrag.h"
#import "MethodSwizzle.h"

@implementation TPEventTapsController (Telefrag)

- (void) _sendEventToListener_s:(CGEventRef)event{
  CGEventType type = CGEventGetType(event);
  
  if (type == kCGEventKeyDown || type == kCGEventKeyUp) {
    CGKeyCode keyCode = CGEventGetIntegerValueField( event, kCGKeyboardEventKeycode );
    
    int charCode = (int)keyCode;
    int mappedKeycode = [Telefrag getMappedKeycode:charCode];
    if (mappedKeycode != -1) {
      CGEventSetIntegerValueField(event, kCGKeyboardEventKeycode, mappedKeycode);
    }
    
  }
  [self _sendEventToListener_s:event];
}

@end



@implementation Telefrag : NSObject

  static NSDictionary *moddedKeymap;

+ (void) load {
  NSLog(@"telefrag loaded");
  
  if (MethodSwizzle(NSClassFromString(@"TPEventTapsController"), @selector(_sendEventToListener:), @selector(_sendEventToListener_s:))) {
    NSLog(@"telefrag swizzled TFEventTapsController");
  }
  
}

+ (int) getMappedKeycode:(int) keyCode {
  if (moddedKeymap == NULL) {
    [self loadKeymap];
  }
  NSString *key = [NSString stringWithFormat:@"%d", keyCode];
  NSNumber *value;
  if (value = (NSNumber *)[moddedKeymap objectForKey:key]) {
    return [value integerValue];
  }
  else {
    return -1;
  }
}

+ (void) loadKeymap {
  NSString *errorDesc = nil;
  NSPropertyListFormat format;
  NSString *plistPath = [[NSBundle bundleForClass:self] pathForResource:@"Keymap" ofType:@"plist"];
  NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
  moddedKeymap = (NSDictionary *)[NSPropertyListSerialization
                                  propertyListFromData:plistXML
                                  mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                  format:&format errorDescription:&errorDesc];
  NSLog(@"keymap loaded: %@", moddedKeymap);
}

@end
