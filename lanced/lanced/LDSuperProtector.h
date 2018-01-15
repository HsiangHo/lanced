//
//  LDSuperProtector.h
//  lanced
//
//  Created by Jovi on 1/15/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDSuperProtector : NSObject

+(instancetype)sharedInstance;
-(void)start;
-(void)stop;
-(BOOL)isRunning;

@end
