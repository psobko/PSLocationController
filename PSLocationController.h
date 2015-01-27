//
//  PSLocationController.h
//
//  Created by Peter Sobkowski on 2015-01-21.
//  Copyright (c) 2015 psobko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

extern NSString *const kLocationUpdatedNotification;
extern NSString *const kLocationAuthorzationStatusChangedNotification;
extern NSString *const kLocationErrorNotification;

extern NSString *const kLocationLocationUserInfoKey;
extern NSString *const kLocationErrorUserInfoKey;

@interface PSLocationController : NSObject <CLLocationManagerDelegate>

@property (strong, readonly, nonatomic) CLLocationManager *locationManager;
@property (readonly, nonatomic) CLLocation *location;
@property (readonly, nonatomic) CLLocationDegrees longitude;
@property (readonly, nonatomic) CLLocationDegrees latitude;
@property (readonly, nonatomic) CLPlacemark *placemark;
@property (readonly, nonatomic) CLAuthorizationStatus authorizationStatus;
@property (readonly, nonatomic) BOOL locationServicesEnabled;

/**
 Returns the location controller singleton
 */
+ (PSLocationController *)sharedInstance;

/**
 Checks the status of location services authorization on the device
 */
- (BOOL)checkLocationServicesAuthorizationStatus;

/**
 Request location services authorization
 */
- (void)requestLocationServicesAuthorization NS_AVAILABLE_IOS(8_0);

/**
 Returns the location controller singleton
 */
- (void)getCurrentLocationPlacemarkWithCompletion:(void (^)(CLPlacemark* placemark, NSError *error))completion;

/**
 Starts updating device location
 */
- (void)startUpdatingLocation;

/**
 Stops updating device location
 */
- (void)stopUpdatingLocation;


@end
