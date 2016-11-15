//
//  PVGameLookupViewController.m
//  Provenance
//
//  Created by David Muzi on 2016-11-09.
//  Copyright © 2016 James Addyman. All rights reserved.
//

#import "PVGameLookupViewController.h"
#import "PVGameLibraryCollectionViewCell.h"
#import "PVGame.h"

@interface PVGameLookupViewController ()
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) PVGameImporter *gameImporter;
@end

@implementation PVGameLookupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [(UICollectionViewFlowLayout *)self.collectionViewLayout setSectionInset:UIEdgeInsetsMake(20, 0, 20, 0)];
    [self.collectionView registerClass:[PVGameLibraryCollectionViewCell class] forCellWithReuseIdentifier:@"SearchResultCell"];
    [self.collectionView setContentInset:UIEdgeInsetsMake(40, 80, 40, 80)];
    
    self.gameImporter = [[PVGameImporter alloc] initWithCompletionHandler:nil];

    __weak PVGameLookupViewController *welf = self;
    self.gameImporter.finishedArtworkHandler = ^(NSString *url) {
        
        NSIndexPath *indexPath = [welf indexPathForURL:url];
        if (indexPath) {
            [welf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    };
}

- (NSIndexPath *)indexPathForURL:(NSString *)url {
    
    __block NSUInteger row = NSNotFound;
    
    [self.searchResults enumerateObjectsUsingBlock:^(NSDictionary   * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj[@"boxImageURL"] isEqualToString:url]) {
            row = idx;
            *stop = YES;
        }
    }];
    
    if (row == NSNotFound) return nil;
    
    return [NSIndexPath indexPathForRow:row inSection:0];
}

// MARK: UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = searchController.searchBar.text;
    self.searchResults = [self.gameImporter searchDatabaseWithFileName:searchString systemID:self.game.systemIdentifier error:nil];

    [self.collectionView reloadData];
}

// MARK: UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PVGameLibraryCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    
    NSDictionary *dictionary = self.searchResults[indexPath.row];
    PVGame *game = [[PVGame alloc] init];
    game.title = dictionary[@"gameTitle"];
    game.originalArtworkURL = dictionary[@"boxImageURL"];
    game.systemIdentifier = self.game.systemIdentifier;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.gameImporter getArtworkFromURL:game.originalArtworkURL];
    });
    [cell setupWithGame:game];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = self.searchResults[indexPath.row];
    
    PVGame *game = [[PVGame alloc] init];
    game.title = dictionary[@"gameTitle"];
    game.customArtworkURL = dictionary[@"boxImageURL"];
    game.systemIdentifier = self.game.systemIdentifier;
    
    [self.delegate gameLookupController:self didChooseGame:game];
}

@end
