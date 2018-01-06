//
//  LDFileKeeper.m
//  lanced
//
//  Created by Jovi on 1/6/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import "LDFileKeeper.h"
#import "VDKQueue.h"

static LDFileKeeper    *instance;
@implementation LDFileKeeper{
    VDKQueue        *_queue;
    NSMutableArray  *_arrayFilePaths;
}

#pragma mark - Public methods

+(instancetype)sharedInstance{
    @synchronized (self) {
        if (nil == instance) {
            instance = [[LDFileKeeper alloc] init];
        }
        return instance;
    }
}

-(void)addFile:(NSString *)filePath{
    if(nil != filePath && 0 == access([filePath UTF8String], F_OK)){
        [self __protectOneFile:filePath withFlag:YES];
        [_arrayFilePaths addObject:filePath];
        [_queue addPath:filePath];
    }
}

-(void)removeFile:(NSString *)filePath{
    if(nil != filePath){
        [_queue removePath:filePath];
        [_arrayFilePaths removeObject:filePath];
        [self __protectOneFile:filePath withFlag:NO];
    }
}

-(void)removeAllFiles{
    [_queue removeAllPaths];
    [self __protectAllFiles:NO];
    [_arrayFilePaths removeAllObjects];
}

#pragma mark - Private methods

-(void)__initializeLDFileKeeper{
    _arrayFilePaths = [[NSMutableArray alloc] init];
    _queue = [[VDKQueue alloc] init];
    [_queue setDelegate:(id<VDKQueueDelegate>)self];
}

-(void)__protectOneFile:(NSString *)filePath withFlag:(BOOL)bFlag{
    NSError * error;
    NSDictionary *attributes =  [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    [dict setObject:[NSNumber numberWithBool:bFlag] forKey:NSFileImmutable];
    [[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:filePath error:&error];
}

-(void)__protectAllFiles:(BOOL)bFlag{
    NSArray *arrayFilePaths = [_arrayFilePaths copy];
    for (NSString *path in arrayFilePaths) {
        [self __protectOneFile:path withFlag:bFlag];
    }
}

#pragma mark - Override methods

-(instancetype)init{
    if (self = [super init]) {
        [self __initializeLDFileKeeper];
    }
    return self;
}

#pragma mark - Delegate methods

-(void) VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath{
    [self __protectOneFile:fpath withFlag:YES];
}

@end
