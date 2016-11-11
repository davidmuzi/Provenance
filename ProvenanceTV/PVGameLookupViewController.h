//
//  PVGameLookupViewController.h
//  Provenance
//
//  Created by David Muzi on 2016-11-09.
//  Copyright © 2016 James Addyman. All rights reserved.
//

#import "PVBaseSearchViewController.h"
#import "PVGameImporter.h"
#import "PVGame.h"

@class PVGameLookupViewController;

@protocol PVGameLookupDelegate <NSObject>

- (void)gameLookupController:(PVGameLookupViewController *)controller didChooseGame:(PVGame *)game;

@end

@interface PVGameLookupViewController : PVBaseSearchViewController <UISearchResultsUpdating>

@property (nonatomic, strong) PVGameImporter *gameImporter;
@property (nonatomic, strong) PVGame *game;

@property (nonatomic, weak) id <PVGameLookupDelegate> delegate;

@end
