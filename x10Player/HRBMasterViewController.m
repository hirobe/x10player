//
//  HRBMasterViewController.m
//  x10Player
//
//  Created by Hirobe Kazuya on 6/5/14.
//  Copyright (c) 2014 Kazuya Hirobe. All rights reserved.
//

#import "HRBMasterViewController.h"
#import "HRBDetailViewController.h"
#import "HRBPathManager.h"

@interface HRBMasterViewController () {
    NSMutableArray *_objects;
    NSMutableDictionary *_infos;
}
@end

@implementation HRBMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.detailViewController = (HRBDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self loadInfos];
    _objects = [self findFiles];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshRequested:) forControlEvents:UIControlEventValueChanged];

}

- (void)refreshRequested:(id)sender {
    [self.refreshControl beginRefreshing];
    
    _objects = [self findFiles];
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark files

- (NSString*)pathFromRelativePath:(NSString*)relativePath {
    return [[HRBPathManager sharedInstance] pathFromRelativePath:relativePath];
}

- (BOOL)isMovieFile:(NSString*)filePath {
    
    if ([filePath hasSuffix:@".mov"]) {
        return YES;
    }
    if ([filePath hasSuffix:@".mp4"]) {
        return YES;
    }
    if ([filePath hasSuffix:@".m4v"]) {
        return YES;
    }
    if ([filePath hasSuffix:@".3gp"]) {
        return YES;
    }
    
    return NO;
}


- (void)removeFile:(NSString*)relativePath {
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSError *error;
    NSString *path = [self pathFromRelativePath:relativePath];
    [fileManager removeItemAtPath:path error:&error ];
}

- (NSMutableArray*)findFiles {
    NSMutableArray *array = [NSMutableArray array];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSString *baseFolderPath = [self pathFromRelativePath:nil];
    
    NSError *error;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:baseFolderPath
                                                      error:&error];
    for (NSString *relativePath in files) {
        NSString *path = [self pathFromRelativePath:relativePath];
        if (![self isMovieFile:path]) {
            continue;
        }
        
        [array addObject:relativePath];
    }
    return array;
}
#pragma mark - info json file 

- (void)loadInfos {
    NSString *path = [self pathFromRelativePath:@"info.json"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _infos = [NSMutableDictionary dictionary];
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    //NSLog(@"load:%@",mutableDic);
    _infos = mutableDic;
}

- (void)saveInfos {
    NSError *error = nil;
    NSData *data = nil;
    if([NSJSONSerialization isValidJSONObject:_infos]){
        data = [NSJSONSerialization dataWithJSONObject:_infos options:NSJSONWritingPrettyPrinted error:&error];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *path = [self pathFromRelativePath:@"info.json"];
        [string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        //NSLog(@"save:%@",string);
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *progressLaebl = (UILabel *)[cell viewWithTag:2];
    UILabel *commentLabel = (UILabel *)[cell viewWithTag:3];

    //progressLaebl.transform = CGAffineTransformTranslate( CGAffineTransformMakeRotation(0.55f), -16, -30);
    
    NSString *relativePath = _objects[indexPath.row];
    titleLabel.text = relativePath;
    
    NSDictionary *info = _infos[relativePath];
    
    if (!info) {
        progressLaebl.text = @"New!!";
        progressLaebl.alpha = 0.8f;
        progressLaebl.hidden = NO;
        commentLabel.text = @"";
    }else {
        NSNumber *displayProgress= info[@"progress"];
        if ([displayProgress isEqualToNumber:[NSNumber numberWithInt:100]]) {
            progressLaebl.hidden = YES;
        }else {
            progressLaebl.text = [NSString stringWithFormat:@"%d%%",[displayProgress intValue]];
            progressLaebl.alpha = 0.5f;
            progressLaebl.hidden = NO;
        }
        commentLabel.text = @"";
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeFile:_objects[indexPath.row]];
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSString *relativePath = _objects[indexPath.row];
        NSDictionary *detailItem = _infos[relativePath];
        if (!detailItem) {
            detailItem = @{};
        }
        NSMutableDictionary *mutableDetailItem = [[NSMutableDictionary alloc] initWithDictionary:detailItem];
        mutableDetailItem[@"relativePath"] = relativePath;
        
        self.detailViewController.delegate = self;
        self.detailViewController.detailItem = mutableDetailItem;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *object = _objects[indexPath.row];
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark HRBDetailViewControllerDelegate

- (void)movieViewControllerProgressDidChanged:(HRBDetailViewController*)controller {
    NSMutableDictionary *detailItem = controller.detailItem;
    _infos[detailItem[@"relativePath"]] = detailItem;
    
    //NSLog(@"%@",_infos);
    [self saveInfos];
    [self.tableView reloadData];
}

@end
