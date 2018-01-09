//
//  LDProcessKeeper.h
//  lanced
//
//  Created by Jovi on 1/9/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDProcessKeeper : NSObject

@property (nonatomic,getter=isRunning)      BOOL        running;

+(instancetype)sharedInstance;
-(void)addProcess:(NSString *)processName withPath:(NSString *)processPath;
-(void)removeProcess:(NSString *)processName;
-(void)removeAllProcesses;
-(NSArray *)arrayProcesses;

@end
