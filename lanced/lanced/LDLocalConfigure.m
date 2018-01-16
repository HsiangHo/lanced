//
//  LDLocalConfigure.m
//  lanced
//
//  Created by Jovi on 1/10/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import "LDLocalConfigure.h"

#define PLIST_NAME                      @"com.hyperartflow.lanced.plist"
#define LABEL                           @"com.hyperartflow.lanced"
#define CONFIGURE_FILE_PATH             [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/LDConfigure.plist"]

#define kFileList                       @"FileList"
#define kProcessDict                    @"ProcessDict"

static LDLocalConfigure *instance;
@implementation LDLocalConfigure

+(instancetype)sharedInstance{
    @synchronized (self) {
        if (nil == instance) {
            instance = [[LDLocalConfigure alloc] init];
        }
        return instance;
    }
}

-(void)registerDaemon{
    NSString *Path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/lanced"];
    NSMutableDictionary *plist = [[NSMutableDictionary alloc]init];
    NSString *lable = LABEL;
    BOOL bRunAtLaunch = TRUE;
    BOOL bEnableTransactions = TRUE;
    [plist setObject: lable forKey:@"Label"];
    [plist setObject:[NSNumber numberWithBool:bRunAtLaunch] forKey:@"RunAtLoad"];
    [plist setObject:[NSNumber numberWithBool:TRUE] forKey:@"KeepAlive"];
    [plist setObject:[NSNumber numberWithBool:bEnableTransactions] forKey:@"EnableTransactions"];
    [plist setObject:[NSArray arrayWithObjects:Path, nil] forKey:@"ProgramArguments"];
    NSString *daemonPath = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@",PLIST_NAME];
    [plist writeToFile:daemonPath atomically:YES];
}

-(void)unregisterDaemon{
    NSString *daemonPath = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@",PLIST_NAME];
    remove([daemonPath UTF8String]);
}

-(void)loadDaemon{
    NSString *daemonPath = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@",PLIST_NAME];
    NSString *cmd = [NSString stringWithFormat:@"sudo launchctl load %@",daemonPath];
    system([cmd UTF8String]);
}

-(void)unloadDaemon{
    NSString *daemonPath = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@",PLIST_NAME];
    NSString *cmd = [NSString stringWithFormat:@"sudo launchctl unload %@",daemonPath];
    system([cmd UTF8String]);
}

-(NSArray *)protectedFileList{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:CONFIGURE_FILE_PATH];
    return [dict valueForKey:kFileList];
}

-(NSDictionary *)protectedProcessDict{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:CONFIGURE_FILE_PATH];
    return [dict valueForKey:kProcessDict];
}

@end
