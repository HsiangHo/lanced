//
//  main.m
//  lanced2
//
//  Created by Jovi on 5/11/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RunScript.h"
#import "LDSuperProtector.h"

#define EXEC_PATH           [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/MacOS/lanced2"]

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        uid_t uid = geteuid();
        if(0 == uid){
            setuid(0);
            if (1 == argc) {
                [[LDSuperProtector sharedInstance] start];
                CFRunLoopRun();
            }else if (2 <= argc) {
                int nFlag = atoi(argv[1]);
                switch (nFlag) {
                    case 0:
                        [[LDSuperProtector sharedInstance] loadProtector];
                        break;
                    case 1:
                        [[LDSuperProtector sharedInstance] unloadProtector];
                        break;
                    case 2:
                        [[LDSuperProtector sharedInstance] installProtector];
                        break;
                    case 3:
                        [[LDSuperProtector sharedInstance] uninstallProtector];
                        break;
                    default:
                        break;
                }
            }
        }else{
            char * const * p = NULL;
            if (1 < argc) {
                p = (char * const *)&argv[1];
            }
            [RunScript RunTool:EXEC_PATH whithArguments:p];
        }
    }
    return 0;
}

