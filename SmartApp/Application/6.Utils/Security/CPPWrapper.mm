//
//  Created by Santos, Ricardo Patricio dos on 14/02/2023.
//

#import <Foundation/Foundation.h>
#import "CPPWrapper.h"

#include <stdio.h>
#import <dlfcn.h>
#import <sys/types.h>
#include <sys/sysctl.h>
#include <unistd.h>
#import <dlfcn.h>
#import <sys/types.h>

@implementation CPPWrapper

+ (void) disable_gdb {
    // Only on devices, and release apps
#if DEBUG
#else
    #ifdef __arm64__
        __asm__("mov X0, #31\n"
                "mov X1, #0\n"
                "mov X2, #0\n"
                "mov X3, #0\n"
                "mov X16, #26\n"
                "svc #0x80\n"
                );
    #endif
#endif
}

+ (void) crash {
    __builtin_trap();          // Crash V1
}

+ (void) crash_if_debugged {
    // Only on devices, and release apps
#if DEBUG
#else
    #ifdef __arm64__
        int name[4];
        struct kinfo_proc info;
        size_t info_size = sizeof(info);
        info.kp_proc.p_flag = 0;
        name[0] = CTL_KERN;
        name[1] = KERN_PROC;
        name[2] = KERN_PROC_PID;
        name[3] = getpid();
        
        if(sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
            __builtin_trap();          // Crash V1
            //kill(getpid(), SIGABRT); // Crash V2
            //abort();                 // Crash V3
            //strcpy(0, "");           // Crash V4
        }
        if ((info.kp_proc.p_flag & P_TRACED) != 0) {
            __builtin_trap();          // Crash V1
            //kill(getpid(), SIGABRT); // Crash V2
            //abort();                 // Crash V3
            //strcpy(0, "");           // Crash V4
        }
    #endif
#endif
}

@end
