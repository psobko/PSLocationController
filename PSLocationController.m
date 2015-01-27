//
//  PSLocationController.m
//
//  Created by Peter Sobkowski on 2015-01-21.
//  Copyright (c) 2015 psobko. All rights reserved.
//

#import "PSLocationController.h"

NSString *const kLocationUpdatedNotification = @"kLocationUpdatedNotification";
NSString *const kLocationAuthorzationStatusChangedNotification = @"kLocationAuthorzationStatusChangedNotification";
NSString *const kLocationErrorNotification = @"kLocationErrorNotification";

NSString *const kLocationLocationUserInfoKey = @"kLocationLocationUserInfoKey";
NSString *const kLocationErrorUserInfoKey = @"kLocationErrorUserInfoKey";

/**
 * 'NSLocationAlwaysUsageDescription' or 'NSLocationWhenInUseUsageDescription' keys
 * and values are required in the app Info.plist. The message will be displayed
 * when authorization status cannot be determined.
 *
 * Enabling this will allow the application to use location data while in the 
 * background.
 */
#define LOCATION_ALWAYS_REQUIRED 0

@implementation PSLocationController

#pragma mark - Initialization

static PSLocationController *sharedLocationController = nil;

+ (PSLocationController *)sharedInstance
{
    static dispatch_once_t _locationControllerOnceToken;
    dispatch_once(&_locationControllerOnceToken, ^{
        sharedLocationController = [[super allocWithZone:NULL] init];//[[PSLocationController alloc] init];
    });
    
    return sharedLocationController;
}

- (id)init
{
    if (self = [super init])
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.activityType = CLActivityTypeOther;
        _locationManager.distanceFilter = (CLLocationDistance)5.0;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - Accessors

-(CLLocationDegrees)longitude
{
    return self.location.coordinate.longitude;
}

-(CLLocationDegrees)latitude
{
    return self.location.coordinate.latitude;
}

-(CLAuthorizationStatus)authorizationStatus
{
    return [CLLocationManager authorizationStatus];
}

-(BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

#pragma mark - Public Methods

- (BOOL)checkLocationServicesAuthorizationStatus
{
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusNotDetermined:
            [self requestLocationServicesUseAuthorization];
            return NO;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            return YES;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        default:
            return NO;
    }
}

- (void)requestLocationServicesAuthorization NS_AVAILABLE_IOS(8_0)
{
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:settingsURL];
}

- (void)requestLocationServicesUseAuthorization NS_AVAILABLE_IOS(8_0)
{
#if LOCATION_ALWAYS_REQUIRED
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
    }
#else
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
#endif
}

- (void)getCurrentLocationPlacemarkWithCompletion:(void (^)(CLPlacemark* placemark, NSError *error))completion
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.locationManager.location
                   completionHandler:^(NSArray *placemarks, NSError *error)
    {
         CLPlacemark *placemark = [placemarks firstObject];
         _placemark = placemark;
         
         if(completion)
         {
             completion(placemark, error);
         }
     }];
}

- (void)startUpdatingLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if([locations lastObject])
    {
        _location = [locations lastObject];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdatedNotification
                                                        object:self
                                                      userInfo:_location ? @{kLocationLocationUserInfoKey:_location} : nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationErrorNotification
                                                        object:self
                                                      userInfo:error ? @{kLocationErrorUserInfoKey:error} : nil];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAuthorzationStatusChangedNotification
                                                        object:self];
    
    if([CLLocationManager locationServicesEnabled] && [self checkLocationServicesAuthorizationStatus])
    {
        [self.locationManager startUpdatingLocation];
    }
}
@end
