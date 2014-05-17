//
//  PFPeerNameViewController.m
//  MultipeerDemo
//
//  Created by Peter Fennema on 06/05/14.
//  Copyright (c) 2014 Peter Fennema. All rights reserved.
//

#import "PFPeerNameViewController.h"

@interface PFPeerNameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *peerNameTextField;

- (IBAction)didClickDone:(UIButton *)sender;

@end

@implementation PFPeerNameViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.peerName) {
        self.peerNameTextField.text = self.peerName;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)didClickDone:(UIButton *)sender {
    if (!self.delegate) {
        return;
    }
    [self.delegate peerNameViewController:self didClickDoneWithName:self.peerNameTextField.text];
}

@end
