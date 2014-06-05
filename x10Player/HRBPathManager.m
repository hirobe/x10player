//
//  HRBPathManager.m
//  x10Player
//
//  Created by Hirobe Kazuya on 6/5/14.
//  Copyright (c) 2014 Kazuya Hirobe. All rights reserved.
//

#import "HRBPathManager.h"

@implementation HRBPathManager

+ (HRBPathManager *)sharedInstance
{
    static HRBPathManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HRBPathManager alloc] init];
    });
    return sharedInstance;
}

- (NSString*)pathFromRelativePath:(NSString*)relativePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:relativePath];
    return path;
}

@end
