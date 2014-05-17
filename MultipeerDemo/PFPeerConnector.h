//
//  PFPeerConnector.h
//  MultipeerDemo
//
//  Created by Peter Fennema on 28/04/14.
//  Copyright (c) 2014 Peter Fennema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFPeerConnector : NSObject

@property (strong, nonatomic) NSString *displayName;

- (instancetype)initWithDisplayName:(NSString*)name;

- (void)connect;

- (void)disconnect;

@end
