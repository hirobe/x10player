//
//  HRBDetailViewController.h
//  x10Player
//
//  Created by Hirobe Kazuya on 6/5/14.
//  Copyright (c) 2014 Kazuya Hirobe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRBDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) id delegate;
@end

@protocol HRBDetailViewControllerDelegate <NSObject>

- (void)movieViewControllerProgressDidChanged:(HRBDetailViewController*)controller;

@end