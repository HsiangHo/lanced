//
//  LDLocalConfigure.h
//  lanced
//
//  Created by Jovi on 1/10/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDLocalConfigure : NSObject

+(instancetype)sharedInstance;
-(void)registerDaemon;
-(void)unregisterDaemon;
-(void)loadDaemon;
-(void)unloadDaemon;

-(NSArray *)protectedFileList;
-(NSDictionary *)protectedProcessDict;

@end
