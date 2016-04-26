//
//  LocationManager.h
//  CDVVisit
//
//  Created by Adrian Vatchinsky on 4/26/15.
//  Copyright (c) 2016 Adrian Vatchinsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface CDVVisit : CDVPlugin

@property (strong, nonatomic) NSString* callbackId;

- (void)startMonitoring:(CDVInvokedUrlCommand*)command;
// - (void)stopMonitoring:(CDVInvokedUrlCommand*)command;

@end