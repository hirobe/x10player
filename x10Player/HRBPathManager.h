//
//  HRBPathManager.h
//  x10Player
//
//  Created by Hirobe Kazuya on 6/5/14.
//  Copyright (c) 2014 Kazuya Hirobe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRBPathManager : NSObject
+ (HRBPathManager *)sharedInstance;
- (NSString*)pathFromRelativePath:(NSString*)relativePath;
@end
