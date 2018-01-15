//
//  LDSuperProtector.m
//  lanced
//
//  Created by Jovi on 1/15/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import "LDSuperProtector.h"
#import "LDFileKeeper.h"
#import "LDProcessKeeper.h"
#import "LDLocalConfigure.h"

static LDSuperProtector *instance;
@implementation LDSuperProtector{
    BOOL                        _isRunning;
}

#pragma mark - Public methods
+(instancetype)sharedInstance{
    @synchronized (self) {
        if (nil == instance) {
            instance = [[LDSuperProtector alloc] init];
        }
        return instance;
    }
}

-(void)start{
    if (_isRunning) {
        return;
    }
    _isRunning = YES;
    [[LDFileKeeper sharedInstance] setRunning:YES];
    [[LDProcessKeeper sharedInstance] setRunning:YES];
}

-(void)stop{
    if (!_isRunning) {
        return;
    }
    _isRunning = NO;
    [[LDFileKeeper sharedInstance] setRunning:NO];
    [[LDProcessKeeper sharedInstance] setRunning:NO];
}

-(BOOL)isRunning{
    return _isRunning;
}

#pragma mark - Private methods
-(void)__initializeLDSuperProtector{
    _isRunning = NO;
    [[LDLocalConfigure sharedInstance] registerDaemon];
    [self __loadingFromLocalConfigureFile];
}

-(void)__loadingFromLocalConfigureFile{
    NSArray *arrayFile = [[LDLocalConfigure sharedInstance] protectedFileList];
    NSDictionary *dictProcesses = [[LDLocalConfigure sharedInstance] protectedProcessDict];
    for (NSString *filePath in arrayFile) {
        [[LDFileKeeper sharedInstance] addFile:filePath];
    }
    NSArray *keys = [dictProcesses allKeys];
    for (NSString *key in keys) {
        [[LDProcessKeeper sharedInstance] addProcess:key withPath:[dictProcesses objectForKey:key]];
    }
}

#pragma mark - Override methods
-(instancetype)init{
    if (self = [super init]) {
        [self __initializeLDSuperProtector];
    }
    return self;
}

@end
