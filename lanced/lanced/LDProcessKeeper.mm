//
//  LDProcessKeeper.m
//  lanced
//
//  Created by Jovi on 1/9/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import "LDProcessKeeper.h"
#import <Cocoa/Cocoa.h>
#include <sys/sysctl.h>
#include <libproc.h>

@interface LDProcessObject : NSObject

@property (nonatomic,strong)        NSString                    *processName;
@property (nonatomic,strong)        NSString                    *processPath;
@property (nonatomic,assign)        pid_t                       pid;

@end

@implementation LDProcessObject{
    NSString                  *_processName;
    NSString                  *_processPath;
    pid_t                     _pid;
}

@end

static LDProcessKeeper    *instance;
@implementation LDProcessKeeper{
    BOOL                    _isRunning;
    BOOL                    _keepWatcherThreadRunning;
    NSMutableDictionary     *_processMap;
    kinfo_proc              *_pProcessList;
    size_t                  _nCount;
}

#pragma mark - Public methods

+(instancetype)sharedInstance{
    @synchronized (self) {
        if (nil == instance) {
            instance = [[LDProcessKeeper alloc] init];
        }
        return instance;
    }
}

-(void)dealloc{
    if (NULL != _pProcessList) {
        free(_pProcessList);
        _pProcessList = NULL;
    }
    _keepWatcherThreadRunning = NO;
}

-(void)addProcess:(NSString *)processName withPath:(NSString *)processPath{
    if(nil == processName || [processName isEqualToString:@""] || nil == processPath || [processPath isEqualToString:@""]){
        return;
    }
    LDProcessObject *obj = [_processMap objectForKey:processName];
    if(nil == obj){
        obj = [[LDProcessObject alloc] init];
        [_processMap setValue:obj forKey:processName];
    }
    [obj setProcessName:processName];
    [obj setProcessPath:processPath];
    if(!_keepWatcherThreadRunning){
        _keepWatcherThreadRunning = YES;
        [NSThread detachNewThreadSelector:@selector(__watcherThread:) toTarget:self withObject:nil];
    }
}
-(void)removeProcess:(NSString *)processName{
    if(nil == processName || [processName isEqualToString:@""]){
        return;
    }
    [_processMap setValue:nil forKey:processName];
}
-(void)removeAllProcesses{
    [_processMap removeAllObjects];
}

-(NSArray *)arrayProcesses{
    return [_processMap allKeys];
}

-(BOOL)isRunning{
    return _isRunning;
}

-(void)setRunning:(BOOL)bValue{
    _isRunning = bValue;
}

#pragma mark - Private methods

-(void)__initializeLDProcessKeeper{
    _isRunning = YES;
    _keepWatcherThreadRunning = NO;
    _processMap = [[NSMutableDictionary alloc] init];
    _pProcessList = NULL;
    _nCount = 0;
}

-(void)__ProcessesValidatorAction{
    if(!_isRunning){
        return;
    }
    NSArray *arrayProcess = [_processMap allValues];
    for(LDProcessObject *obj in arrayProcess){
        if(![self __validateProcessObject:obj]){
            [self __updateProcessList];
            if(![self __updateProcessObject:obj]){
                [self __keepProcess:obj];
            }
        }
    }
}

-(void)__keepProcess:(LDProcessObject *)obj{
    //restart process
    [[NSWorkspace sharedWorkspace] launchApplication:[obj processPath]];
}

-(BOOL)__updateProcessObject:(LDProcessObject *)obj{
    BOOL bRtn = NO;
    if (NULL != _pProcessList && 0 != _nCount ){
        for (int i = 0; i < _nCount; i++){
            struct kinfo_proc *currentProcess = &_pProcessList[i];
            if(0 == strcmp(currentProcess->kp_proc.p_comm, [[obj processName] UTF8String])){
                char pathbuf[PROC_PIDPATHINFO_MAXSIZE] = { 0 };
                int rlst = proc_pidpath (currentProcess->kp_proc.p_pid, pathbuf, sizeof(pathbuf));
                if(rlst > 0){
                    NSString *path = [NSString stringWithUTF8String:pathbuf];
                    bRtn = [path isEqualToString:[obj processPath]];
                    if(bRtn){
                        [obj setPid:currentProcess->kp_proc.p_pid];
                        break;
                    }
                }
            }
        }
    }
    return bRtn;
}

-(BOOL)__validateProcessObject:(LDProcessObject *)obj{
    BOOL bRtn = NO;
    if((pid_t)0 == [obj pid]){
        return bRtn;
    }
    char pathbuf[PROC_PIDPATHINFO_MAXSIZE] = { 0 };
    int rlst = proc_pidpath ([obj pid], pathbuf, sizeof(pathbuf));
    if(rlst > 0){
        NSString *path = [NSString stringWithUTF8String:pathbuf];
        bRtn = [path isEqualToString:[obj processPath]];
    }else{
        [obj setPid:0];
    }
    return bRtn;
}

-(void)__updateProcessList{
    if (NULL != _pProcessList) {
        free(_pProcessList);
        _pProcessList = NULL;
    }
    
    int                 err;
    kinfo_proc *        result;
    bool                done;
    static const int    name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    size_t              length;
    _nCount = 0;
    
    result = NULL;
    done = false;
    do {
        length = 0;
        err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                     NULL, &length,
                     NULL, 0);
        if (err == -1) {
            err = errno;
        }
        if (err == 0) {
            result = (kinfo_proc *)malloc(length);
            if (result == NULL) {
                err = ENOMEM;
            }
        }
        if (err == 0) {
            err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                         result, &length,
                         NULL, 0);
            if (err == -1) {
                err = errno;
            }
            if (err == 0) {
                done = true;
            } else if (err == ENOMEM) {
                assert(result != NULL);
                free(result);
                result = NULL;
                err = 0;
            }
        }
    } while (err == 0 && ! done);
    if (err != 0 && result != NULL) {
        free(result);
        result = NULL;
    }
    _pProcessList = result;
    if (err == 0) {
        _nCount = length / sizeof(kinfo_proc);
    }
}

- (void)__watcherThread:(id)sender{
    while(_keepWatcherThreadRunning){
        [self __ProcessesValidatorAction];
        sleep(1);
    }
}

#pragma mark - Override methods

-(instancetype)init{
    if (self = [super init]) {
        [self __initializeLDProcessKeeper];
    }
    return self;
}

@end
