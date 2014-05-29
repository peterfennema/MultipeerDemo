//
//  PFPeerConnector.m
//  MultipeerDemo
//
//  Created by Peter Fennema on 28/04/14.
//  Copyright (c) 2014 Peter Fennema. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "PFPeerConnector.h"
#import "PFLoggingConsole.h"

NSString *const kServiceType = @"pf-connector";

@interface PFPeerConnector () <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>

@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCPeerID *peerId;

@end

@implementation PFPeerConnector

#pragma mark - Lifecycle

- (instancetype)initWithDisplayName:(NSString*)name
{
    self = [super init];
    if (self) {
        self.displayName = name;
        self.peerId = [[MCPeerID alloc] initWithDisplayName:self.displayName];
    }
    return self;
}
#pragma mark - Public

- (void) connect
{
    NSAssert(self.displayName != nil, @"You must set a displayname");
    NSAssert(self.peerId != nil, @"self.peerId must not be nil");
    
    NSLog(@"Peer %@ is connecting", self.displayName);
    
    self.session = [[MCSession alloc] initWithPeer:self.peerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
    self.session.delegate = self;
    
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerId discoveryInfo:nil serviceType:kServiceType];
    self.advertiser.delegate = self;
    [self.advertiser startAdvertisingPeer];
    
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerId serviceType:kServiceType];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
}

- (void) disconnect
{
    NSLog(@"Peer %@ is disonnecting", self.displayName);
    
    [self.advertiser stopAdvertisingPeer];
    self.advertiser.delegate = nil;
    self.advertiser = nil;
    
    [self.browser stopBrowsingForPeers];
    self.browser.delegate = nil;
    self.browser = nil;
    
    [self.session disconnect];
    self.session.delegate = nil;
    self.session = nil;
}

#pragma mark - Private

- (void) logPeers
{
    NSArray *peers = self.session.connectedPeers;
    NSMutableArray *displayNames = [[NSMutableArray alloc]init];
    for (MCPeerID *peer in peers) {
        [displayNames addObject:peer.displayName];
    }
    NSLog(@"%@ peers: %@", self.peerId.displayName, displayNames);
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnecting) {
        NSLog(@"%@ received MCSessionStateConnecting for %@", self.peerId.displayName, peerID.displayName);
    }
    else if (state == MCSessionStateConnected) {
        NSLog(@"%@ received MCSessionStateConnected for %@", self.peerId.displayName, peerID.displayName);
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"%@ received MCSessionStateNotConnected for %@", self.peerId.displayName, peerID.displayName);
    }
    [self logPeers];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"Advertiser %@ did not start advertising with error: %@", self.peerId.displayName, error.localizedDescription);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    NSLog(@"Advertiser %@ received an invitation from %@", self.peerId.displayName, peerID.displayName);
    invitationHandler(YES, self.session);
    NSLog(@"Advertiser %@ accepted invitation from %@", self.peerId.displayName, peerID.displayName);
    [self logPeers];
}


#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Browser %@ did not start browsing with error: %@", self.peerId.displayName, error.localizedDescription);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"Browser %@ found %@", self.peerId.displayName, peerID.displayName);
    
    // Should I invite the peer or should the peer invite me? Let the decision be based on the lexical ordering of the peer name.
    BOOL shouldInvite = ([self.peerId.displayName compare:peerID.displayName] == NSOrderedAscending);
    if (shouldInvite) {
        // I will invite the peer, the remote peer will NOT invite me.
        NSLog(@"Browser %@ invites %@ to connect", self.peerId.displayName, peerID.displayName);
        [self.browser invitePeer:peerID toSession:self.session withContext:nil timeout:10];
    } else {
        // I will NOT invite the peer, the remote peer will invite me.
        NSLog(@"Browser %@ does not invite %@ to connect", self.peerId.displayName, peerID.displayName);
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"Browser %@ lost %@", self.peerId.displayName, peerID.displayName);
    [self logPeers];
}


@end
