//
//  PFPeerNameViewController.h
//  MultipeerDemo
//
//  Created by Peter Fennema on 06/05/14.
//  Copyright (c) 2014 Peter Fennema. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFPeerNameViewController;

@protocol PFPeerNameViewControllerDelegate <NSObject>

- (void)peerNameViewController:(PFPeerNameViewController *)viewController didClickDoneWithName:(NSString *)name;

@end

@interface PFPeerNameViewController : UIViewController

@property (strong, nonatomic) id<PFPeerNameViewControllerDelegate>delegate;
@property (strong, nonatomic) NSString *peerName;

@end
