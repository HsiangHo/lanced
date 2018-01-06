//
//  LDFileKeeper.h
//  lanced
//
//  Created by Jovi on 1/6/18.
//  Copyright © 2018 Jovi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDFileKeeper : NSObject

+(instancetype)sharedInstance;
-(void)addFile:(NSString *)filePath;
-(void)removeFile:(NSString *)filePath;
-(void)removeAllFiles;

@end
