//
//  PFAppDelegate.m
//  MultipeerDemo
//
//  Created by Peter Fennema on 28/04/14.
//  Copyright (c) 2014 Peter Fennema. All rights reserved.
//

#import "PFAppDelegate.h"
#import "PFPeerConnector.h"
#import "PFPeerNameViewController.h"

// Adding this import lets the NSLog calls log to the iPhone screen
#import "PFLoggingConsole.h"

// The NSUserDefaults key for the peer name.
static NSString *PFPeerName = @"PFPeerName";

@interface PFAppDelegate () <PFPeerNameViewControllerDelegate>

/**
 The peerConnector manages the multipeer advertising, browsing, and the session
 */
@property (strong, nonatomic) PFPeerConnector *peerConnector;

@property (strong, nonatomic) UIViewController *storyboardRootViewController;

@end

@implementation PFAppDelegate

#pragma mark - Private

/**
 Adds the logging console as a subview of the rootViewController.view.
 */
- (void) addLoggingConsole
{
    PFLoggingConsole *loggingConsole = [PFLoggingConsole getInstance];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    loggingConsole.frame = CGRectMake(20, 30, screenWidth - 40, screenHeight - 50);
    loggingConsole.layer.borderWidth = 1.0;
    loggingConsole.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.window.rootViewController.view addSubview:loggingConsole];
}

- (void)setupPeerNameViewController
{
    PFPeerNameViewController *peerNameViewController = [[PFPeerNameViewController alloc]initWithNibName:@"PFPeerNameViewController" bundle:[NSBundle mainBundle]];
    NSAssert(peerNameViewController != nil, @"peerNameViewController must not be nil");
    // use the name of the current device as the default peer name
    [peerNameViewController setPeerName:[UIDevice currentDevice].name];
    [peerNameViewController setDelegate:self];
    self.window.rootViewController = peerNameViewController;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    
    self.storyboardRootViewController = self.window.rootViewController;
    
    NSString *defaultPeerName = [[NSUserDefaults standardUserDefaults] stringForKey:PFPeerName];
    if (!defaultPeerName) {
        [self setupPeerNameViewController];
    } else {
        self.window.rootViewController = self.storyboardRootViewController;
        [self addLoggingConsole];
        self.peerConnector = [[PFPeerConnector alloc]initWithDisplayName:defaultPeerName];
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
    [self.peerConnector disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    if (self.peerConnector) {
        [self.peerConnector connect];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark - PFPeerNameDelegate

- (void)peerNameViewController:(PFPeerNameViewController *)viewController didClickDoneWithName:(NSString *)name
{
    [[NSUserDefaults standardUserDefaults]setObject:name forKey:PFPeerName];
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ self.window.rootViewController = self.storyboardRootViewController; }
                    completion:^ (BOOL finished) {
                        [self addLoggingConsole];
                        self.peerConnector = [[PFPeerConnector alloc]initWithDisplayName:name];
                        [self.peerConnector connect];
                    }
     ];
}

@end
