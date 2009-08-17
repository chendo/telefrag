#import "MethodSwizzle.h"
#import <stdlib.h>
#import <string.h>
#import <objc/objc-runtime.h>
#import <objc/objc-class.h>
#import <uuid/uuid.h>

static BOOL _PerformSwizzle(Class klass, SEL origSel, SEL altSel, BOOL forInstance);

BOOL ClassMethodSwizzle(Class klass, SEL origSel, SEL altSel) {
	return _PerformSwizzle(klass, origSel, altSel, NO);
}

BOOL MethodSwizzle(Class klass, SEL origSel, SEL altSel) {
	return _PerformSwizzle(klass, origSel, altSel, YES);
}

// if the origSel isn't present in the class, pull it up from where it exists
// then do the swizzle
BOOL _PerformSwizzle(Class klass, SEL origSel, SEL altSel, BOOL forInstance) {
  // First, make sure the class isn't nil
	if (klass != nil) {
		Method origMethod = NULL, altMethod = NULL;
    
		// Next, look for the methods
		Class iterKlass = (forInstance ? klass : klass->isa);
		void *iterator = NULL;
		struct objc_method_list *mlist = class_nextMethodList(iterKlass, &iterator);
		while (mlist != NULL) {
			int i;
			for (i = 0; i < mlist->method_count; ++i) {
				if (mlist->method_list[i].method_name == origSel) {
					origMethod = &mlist->method_list[i];
					break;
				}
				if (mlist->method_list[i].method_name == altSel) {
					altMethod = &mlist->method_list[i];
					break;
				}
			}
			mlist = class_nextMethodList(iterKlass, &iterator);
		}
    
		if (origMethod == NULL || altMethod == NULL) {
			// one or both methods are not in the immediate class
			// try searching the entire hierarchy
			// remember, iterKlass is the class we care about - klass || klass->isa
			// class_getInstanceMethod on a metaclass is the same as class_getClassMethod on the real class
			BOOL pullOrig = NO, pullAlt = NO;
			if (origMethod == NULL) {
				origMethod = class_getInstanceMethod(iterKlass, origSel);
				pullOrig = YES;
			}
			if (altMethod == NULL) {
				altMethod = class_getInstanceMethod(iterKlass, altSel);
				pullAlt = YES;
			}
      
			// die now if one of the methods doesn't exist anywhere in the hierarchy
			// this way we won't make any changes to the class if we can't finish
			if (origMethod == NULL || altMethod == NULL) {
				return NO;
			}
      
			// we can safely assume one of the two methods, at least, will be pulled
			// pull them up
			size_t listSize = sizeof(struct objc_method_list);
			if (pullOrig && pullAlt) listSize += sizeof(struct objc_method); // need 2 methods
			struct objc_method_list *mlist = malloc(listSize);
			mlist->obsolete = NULL;
			int i = 0;
			if (pullOrig) {
				memcpy(&mlist->method_list[i], origMethod, sizeof(struct objc_method));
				origMethod = &mlist->method_list[i];
				i++;
			}
			if (pullAlt) {
				memcpy(&mlist->method_list[i], altMethod, sizeof(struct objc_method));
				altMethod = &mlist->method_list[i];
				i++;
			}
			mlist->method_count = i;
			class_addMethods(iterKlass, mlist);
		}
    
		// now swizzle
		IMP temp = origMethod->method_imp;
		origMethod->method_imp = altMethod->method_imp;
		altMethod->method_imp = temp;
    
		return YES;
	}
	return NO;
}