//
//  LocationManager.m
//  CDVVisit
//
//  Created by Adrian Vatchinsky on 4/26/15.
//  Copyright (c) 2016 Adrian Vatchinsky. All rights reserved.
//

#import "CDVVisit.h"
#import <CoreLocation/CoreLocation.h>
#import <Cordova/CDV.h>



@interface CDVVisit ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end



@implementation CDVVisit

- (void)pluginInitialize
{
    NSLog(@"- CDVVisit pluginInitialize");
     _locationManager = [[CLLocationManager alloc] init];    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
        
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
}

- (void)startMonitoring:(CDVInvokedUrlCommand*)command {
  NSLog(@"- CDVVisit startMonitoring");
  self.callbackId = command.callbackId;
  
  // start monitoring 
  [self.locationManager requestAlwaysAuthorization];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startMonitoringVisits];
            
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            NSLog(@"User has not given access to location data");
            
            if (self.callbackId) {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
            }
            
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            
            break;
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    /**
     *  Make sure that we can actually send the user local notifications before scheduling any
     */
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types & UIUserNotificationTypeAlert) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertTitle = @"Visit";
        localNotification.alertBody = [NSString stringWithFormat:@"From: %@\nTo: %@\nLocation: (%f, %f)",
                                       [self.dateFormatter stringFromDate:visit.arrivalDate],
                                       [self.dateFormatter stringFromDate:visit.departureDate],
                                       visit.coordinate.latitude,
                                       visit.coordinate.longitude];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];
        localNotification.category = @"GLOBAL"; // Lazy categorization
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    /**
     *  Store the visit event into the database so we can plot it later
     */
    // Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    // location.arrival = visit.arrivalDate;
    // location.departure = visit.departureDate;
    // location.latitude = @(visit.coordinate.latitude);
    // location.longitude = @(visit.coordinate.longitude);
    
    // [self.managedObjectContext save:nil];
    
    NSMutableDictionary *visitData = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [visitData setValue:[NSNumber numberWithInt:[visit.departureDate timeIntervalSince1970]] forKey:@"departureDate"];
    // if we have no arrival timestamp use the current timestamp instead
    if([visit.arrivalDate isEqualToDate:NSDate.distantPast]) {
        [visitData setValue:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:@"arrivalDate"];
    }
    else {
        [visitData setValue:[NSNumber numberWithInt:[visit.arrivalDate timeIntervalSince1970]] forKey:@"arrivalDate"];
    }
    [visitData setValue:[NSNumber numberWithFloat:visit.coordinate.latitude] forKey:@"latitude"];
    [visitData setValue:[NSNumber numberWithFloat:visit.coordinate.longitude] forKey:@"longitude"];

    
    NSDictionary *visitDict = [visitData copy];
    
    // Return results to JS
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:visitDict];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId]; 
}

@end
