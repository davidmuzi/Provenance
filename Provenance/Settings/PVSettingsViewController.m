//
//  PVSettingsViewController.m
//  Provenance
//
//  Created by James Addyman on 21/08/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

#import "PVSettingsViewController.h"
#import "PVSettingsModel.h"
#import "PVMediaCache.h"
#import "UIAlertView+BlockAdditions.h"
#import "PVGameLibraryViewController.h"
#import "PVConflictViewController.h"
#import "PViCadeControllerViewController.h"

@interface PVSettingsViewController ()

@end

@implementation PVSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Settings";
		
	PVSettingsModel *settings = [PVSettingsModel sharedInstance];
	
	[self.autoSaveSwitch setOn:[settings autoSave]];
	[self.autoLoadSwitch setOn:[settings autoLoadAutoSaves]];
	[self.opacitySlider setValue:[settings controllerOpacity]];
	[self.autoLockSwitch setOn:[settings disableAutoLock]];
    [self.opacityValueLabel setText:[NSString stringWithFormat:@"%.0f%%", self.opacitySlider.value * 100]];
    [self.versionLabel setText:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
    [self.vibrateSwitch setOn:[settings buttonVibration]];
#if DEBUG
    [self.modeLabel setText:@"DEBUG"];
#else
    [self.modeLabel setText:@"RELEASE"];
#endif
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    PVSettingsModel *settings = [PVSettingsModel sharedInstance];
    [self.iCadeControllerSetting setText:kIcadeControllerSettingToString([settings iCadeControllerSetting])];
}

- (IBAction)done:(id)sender
{
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)toggleAutoSave:(id)sender
{
	[[PVSettingsModel sharedInstance] setAutoSave:[self.autoSaveSwitch isOn]];
}

- (IBAction)toggleAutoLoadAutoSaves:(id)sender
{
	[[PVSettingsModel sharedInstance] setAutoLoadAutoSaves:[self.autoLoadSwitch isOn]];
}

- (IBAction)controllerOpacityChanged:(id)sender
{
    self.opacitySlider.value = floor(self.opacitySlider.value / 0.05) * 0.05;
    [self.opacityValueLabel setText:[NSString stringWithFormat:@"%.0f%%", self.opacitySlider.value * 100]];
    
	[[PVSettingsModel sharedInstance] setControllerOpacity:self.opacitySlider.value];
}

- (IBAction)toggleAutoLock:(id)sender
{
	[[PVSettingsModel sharedInstance] setDisableAutoLock:[self.autoLockSwitch isOn]];
}

- (IBAction)toggleVibration:(id)sender
{
    [[PVSettingsModel sharedInstance] setButtonVibration:[self.vibrateSwitch isOn]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0)
    {
        PViCadeControllerViewController *iCadeControllerViewController = [[PViCadeControllerViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:iCadeControllerViewController];
        [self presentViewController:navController animated:YES completion:NULL];
    }
    else if(indexPath.section == 3 && indexPath. row == 0) {
        // import/export roms and game saves button
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
        
        // Check to see if we are connected to WiFi. Cannot continue otherwise.
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if (status != ReachableViaWiFi)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Unable to start web server!"
                                                            message: @"Your device needs to be connected to a WiFi network to continue!"
                                                           delegate: nil
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        } else {
            // connected via wifi, let's continue
            
            // start web transfer service
            [[PVWebServer sharedInstance] startServer];
            
            // get the IP address of the device
            NSString *ipAddress = [[PVWebServer sharedInstance] getIPAddress];
            
#if TARGET_IPHONE_SIMULATOR
            ipAddress = [ipAddress stringByAppendingString: @":8080"];
#endif
            
            NSString *message = [NSString stringWithFormat: @"Start transferring data by visiting this website on your computer:\nhttp://%@/", ipAddress];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Web server started!"
                                                            message: message
                                                           delegate: self
                                                  cancelButtonTitle: @"Stop Web Server"
                                                  otherButtonTitles: nil];
            
            [alert PV_setCompletionHandler:^(NSUInteger buttonIndex) {
                [[PVWebServer sharedInstance] stopServer];
            }];
            
            [alert show];
        }
        
    }
    else if (indexPath.section == 4 && indexPath.row == 0)
    {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Refresh Game Library?"
                                                        message:@"Attempt to get artwork and title information for your library. This can be a slow process, especially for large libraries. Only do this if you really, really want to try and get more artwork. Please be patient, as this process can take several minutes."
                                                       delegate:nil
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert PV_setCompletionHandler:^(NSUInteger buttonIndex) {
            if (buttonIndex != [alert cancelButtonIndex])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshLibraryNotification
                                                                    object:nil];
            }
        }];
        [alert show];
    }
	else if (indexPath.section == 4 && indexPath.row == 1)
	{
		[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty Image Cache?"
														message:@"Empty the image cache to free up disk space. Images will be redownload on demand."
													   delegate:nil
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
		[alert PV_setCompletionHandler:^(NSUInteger buttonIndex) {
			if (buttonIndex != [alert cancelButtonIndex])
			{
				[PVMediaCache emptyCache];
			}
		}];
		[alert show];
	}
    else if (indexPath.section == 4 && indexPath.row == 2)
    {
        PVConflictViewController *conflictViewController = [[PVConflictViewController alloc] initWithGameImporter:self.gameImporter];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:conflictViewController];
        [self presentViewController:navController animated:YES completion:NULL];
    }
}


@end
