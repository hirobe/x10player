//
//  HRBDetailViewController.m
//  x10Player
//
//  Created by Hirobe Kazuya on 6/5/14.
//  Copyright (c) 2014 Kazuya Hirobe. All rights reserved.
//

#import "HRBDetailViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HRBPathManager.h"

#define BUTTON_PADDING_LEFT (13.0f)
#define BUTTON_PADDING_RIGHT (13.0f)
#define BUTTON_PADDING_TOP (10.0f)
#define BUTTON_PADDING_BOTTOM (10.0f)
#define BUTTON_X_SPACE (10.0f)
#define BUTTON_Y_SPACE (10.0f)


@interface HRBDetailViewController () {
    CGFloat _currentSpeedRate;
}
@property (nonatomic) MPMoviePlayerController *moviePlayer;
@property (nonatomic) CGRect defaultFrame;
@property (nonatomic) UIButton *speedButton;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic) UIControl *speedPanelBackView;
@property (nonatomic) UIView *speedPanel;
- (void)configureView;
@end

@implementation HRBDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

#pragma mark -

- (void)configureView {
    if (self.detailItem ) {
        NSString *path = [[HRBPathManager sharedInstance] pathFromRelativePath:  self.detailItem[@"relativePath"]];

        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter removeObserver:self];
        [defaultCenter addObserver:self
                          selector:@selector(didEnterFullScreen:)
                              name:MPMoviePlayerDidEnterFullscreenNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(willExitFullScreen:)
                              name:MPMoviePlayerWillExitFullscreenNotification object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(playBackStateDidChanged:)
                              name:MPMoviePlayerPlaybackStateDidChangeNotification
                            object:nil];
        
        //create a player
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
        self.moviePlayer.view.frame  = self.view.bounds;
        self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.moviePlayer.view.autoresizesSubviews = YES;
        
        [self.view addSubview:self.moviePlayer.view];
        
        if (self.speedButton) {
            [self.speedButton removeFromSuperview];
            self.speedButton = nil;
        }
        self.speedButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.speedButton.frame = CGRectMake(0,60,88,44);
        [self.moviePlayer.view addSubview:self.speedButton];
        [self.speedButton setTitle:@"x1.0" forState:UIControlStateNormal];
        [self.speedButton addTarget:self action:@selector(speedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.moviePlayer setFullscreen:YES animated:YES];
        
        _currentSpeedRate = 1.0f;
        [self setPlaySpeed:1.0f];
    }
    
}

- (void)didEnterFullScreen:(NSNotification*)note {
    [self hideSelectSpeedPanel:nil];
    
    if (self.speedButton) {
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        UIView * videoView = [[window subviews] lastObject];
        
        [videoView addSubview:self.speedButton];
    }
}
- (void)willExitFullScreen:(NSNotification*)note {
    [self hideSelectSpeedPanel:nil];

    if (self.speedButton) {
        [self.moviePlayer.view addSubview:self.speedButton];
    }
}

- (void)recordProgress {
    CGFloat progress = 0;
    if (self.moviePlayer.duration >0) {
        progress = self.moviePlayer.currentPlaybackTime / self.moviePlayer.duration *100;
        
        NSNumber *oldProgress = self.detailItem[@"progress"];
        if (oldProgress && [oldProgress floatValue]>progress) {
            // do nothing
        }else {
            self.detailItem[@"progress"] = [NSNumber numberWithInt:progress];
            if ([self.delegate respondsToSelector:@selector(movieViewControllerProgressDidChanged:)]) {
                [self.delegate movieViewControllerProgressDidChanged:self];
            }
        }
    }
}

- (void)playBackStateDidChanged:(NSNotification*)note {
    // restore speed rate when user pause the movie and start playing.
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        if (_currentSpeedRate != self.moviePlayer.currentPlaybackRate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setPlaySpeed:_currentSpeedRate];
            });
        }
        [self recordProgress];
    }else if (self.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
        [self recordProgress];
    }else if (self.moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
        [self recordProgress];
    }
}

- (void)speedButtonTapped:(id)sender {
    [self showSelectSpeedPanel];
}

- (void)hideSelectSpeedPanel:(id)sender {
    self.speedButton.frame = CGRectMake(0,60,88,44);
    [self.speedPanel setHidden:YES];
    [self.speedPanel removeFromSuperview];
}

- (void)showSelectSpeedPanel {
    NSArray *speedRates = @[@(-1.0f),@1.0f,@0.5f,@0.8f,@1.2f,@1.5f,@1.8f,@2.0f,@2.5f,@3.0f,@4.0f,@5.0f,@8.0f,@10.0f,@20.0f];
    
    self.speedPanel = [[UIView alloc] initWithFrame:CGRectMake(0,0,220,300)];
    self.speedPanel.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.5f];
    self.speedPanel.backgroundColor = [UIColor lightGrayColor];
    self.speedPanel.alpha = 0.5f;
    [self.speedButton addSubview:self.speedPanel];
    self.speedButton.frame = CGRectMake(self.speedButton.frame.origin.x,
                                        self.speedButton.frame.origin.y,
                                        self.speedPanel.bounds.size.width,
                                        self.speedPanel.bounds.size.height);
    
    // show buttons
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:15.0f],
                                 };
    CGFloat left = 0.0f;
    CGFloat top = 0.0f;
    for (NSNumber *speedRate in speedRates) {
        NSString *title = [NSString stringWithFormat:@"x%.1f",[speedRate floatValue]];
        if ([speedRate floatValue]<0.0f) {
            title = @"Cancel";
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:textAttributes] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(speedPanelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = (NSInteger) ([speedRate floatValue]*100);
        
        CGSize size = [title sizeWithAttributes:textAttributes];
        CGSize buttonSize = CGSizeMake(size.width + BUTTON_PADDING_LEFT+BUTTON_PADDING_RIGHT,
                                       size.height + BUTTON_PADDING_TOP+BUTTON_PADDING_BOTTOM);
        
        if (left + buttonSize.width + BUTTON_X_SPACE*2 > self.speedPanel.bounds.size.width && left>0.0f) {
            left = 0.0f;
            top += buttonSize.height + BUTTON_Y_SPACE;
        }
        
        button.frame = CGRectMake(left+BUTTON_X_SPACE,top+BUTTON_Y_SPACE,buttonSize.width,buttonSize.height);
        
        left += buttonSize.width + BUTTON_X_SPACE;
        
        [self.speedPanel addSubview:button];
    }
}

- (void)speedPanelButtonTapped:(id)sender {
    UIButton *button = (UIButton*)sender;
    CGFloat rate = ((CGFloat)button.tag)/100.0f;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideSelectSpeedPanel:sender];
        if (rate>0.0f) {
            [self setPlaySpeed:rate];
        }
    });
}

- (void)setPlaySpeed:(CGFloat)rate {
    _currentSpeedRate = rate;
    self.moviePlayer.currentPlaybackRate = rate;
    
    NSString *title = [NSString stringWithFormat:@"x%.1f",rate];
    [self.speedButton setTitle:title forState:UIControlStateNormal];
}

- (void)moviToFullScreen {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [window addSubview:self.speedButton];
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
