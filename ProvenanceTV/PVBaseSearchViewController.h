//
//  PVBaseSearchViewController.h
//  Provenance
//
//  Created by David Muzi on 2016-11-11.
//  Copyright © 2016 James Addyman. All rights reserved.
//

@import UIKit;

@interface PVBaseSearchViewController : UICollectionViewController <UISearchResultsUpdating>

- (UINavigationController *)navigationControllerWrapper;

@end
