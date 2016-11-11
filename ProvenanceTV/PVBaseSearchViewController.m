//
//  PVBaseSearchViewController.m
//  Provenance
//
//  Created by David Muzi on 2016-11-11.
//  Copyright © 2016 James Addyman. All rights reserved.
//

#import "PVBaseSearchViewController.h"

@interface PVBaseSearchViewController ()

@end

@implementation PVBaseSearchViewController

- (instancetype)init {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setSectionInset:UIEdgeInsetsMake(20, 0, 20, 0)];
    
    return [self initWithCollectionViewLayout:flowLayout];
}

- (UINavigationController *)navigationControllerWrapper
{
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:self];
    searchController.searchResultsUpdater = self;
    
    UISearchContainerViewController *searchContainerController = [[UISearchContainerViewController alloc] initWithSearchController:searchController];
    [searchContainerController setTitle:@"Search"];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:searchContainerController];
    
    return navController;
}

// MARK: UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(250, 360);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 88;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 30;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(40, 40, 120, 40);
}

// MARK: UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSAssert(false, @"Must be implemented by subclass");
}

@end
