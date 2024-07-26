//
//  Created by Santos, Ricardo Patricio dos on 14/02/2023.
//

#import <Foundation/Foundation.h>

@interface CPPWrapper : NSObject
+ (void) disable_gdb;
+ (void) crash;
+ (void) crash_if_debugged;
@end
