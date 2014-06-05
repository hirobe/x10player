//
//  HRBMasterViewController.m
//  x10Player
//
//  Created by Hirobe Kazuya on 6/5/14.
//  Copyright (c) 2014 Kazuya Hirobe. All rights reserved.
//

#import "HRBMasterViewController.h"
#import "HRBDetailViewController.h"

@interface HRBMasterViewController () {
    NSMutableArray *_objects;
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

- (NSString*)baseFolderPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
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

- (void)removeFile:(NSString*)filePath {
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSError *error;
    [fileManager removeItemAtPath:filePath error:&error ];
}

- (NSMutableArray*)findFiles {
    NSMutableArray *array = [NSMutableArray array];
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSString *baseFolderPath = [self baseFolderPath];
    
    NSError *error;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:baseFolderPath
                                                      error:&error];
    for (NSString *filename in files) {
        NSString *path = [baseFolderPath stringByAppendingPathComponent:filename];
        if (![self isMovieFile:path]) {
            continue;
        }
        [array addObject:@{@"filename":filename,@"path":path}];
    }
    return array;
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

    NSDictionary *dictionary = _objects[indexPath.row];
    cell.textLabel.text = dictionary[@"filename"];
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
        [self removeFile:_objects[indexPath.row][@"path"]];
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
