//
//  PSLocationControllerExampleTests.m
//  PSLocationControllerExampleTests
//
//  Created by Peter Sobkowski on 2015-01-21.
//  Copyright (c) 2015 psobko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "PSLocationController.h"

@interface PSLocationControllerExampleTests : XCTestCase
{
    PSLocationController *testSubject;
    id mockTestSubject;
    id mockLocationManager;
    id mockLocationManagerClass;
    id mockObserver;
}
@end

@implementation PSLocationControllerExampleTests

- (void)setUp
{
    [super setUp];
    
    testSubject = [PSLocationController sharedInstance];
    mockTestSubject = [OCMockObject partialMockForObject:testSubject];
    mockLocationManager = [OCMockObject partialMockForObject:testSubject.locationManager];
    mockLocationManagerClass = [OCMockObject mockForClass:[CLLocationManager class]];
    mockObserver = [OCMockObject observerMock];

}

- (void)tearDown
{
    [[NSNotificationCenter defaultCenter] removeObserver:mockObserver];
    testSubject = nil;
    mockTestSubject = nil;
    mockLocationManager = nil;
    mockLocationManagerClass = nil;
    mockObserver = nil;
    [super tearDown];
}

#pragma mark - Helper Methods

- (void)_updateLocation:(CLLocation *)location
{
    [testSubject.locationManager.delegate locationManager:testSubject.locationManager
                                       didUpdateLocations:@[location]];
}

- (void)_updateLocationsWithFinalLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    [testSubject.locationManager.delegate locationManager:testSubject.locationManager
                                       didUpdateLocations:@[
                                                            [[CLLocation alloc] initWithLatitude:-79.4000
                                                                                       longitude:43.7000],
                                                            [[CLLocation alloc] initWithLatitude:-79.5000
                                                                                       longitude:43.8000],
                                                            [[CLLocation alloc] initWithLatitude:latitude
                                                                                       longitude:longitude]]];
}

- (void)_changeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [testSubject.locationManager.delegate locationManager:testSubject.locationManager
                             didChangeAuthorizationStatus:status];
}

- (void)_failWithError:(NSError *)error
{
    [testSubject.locationManager.delegate locationManager:testSubject.locationManager
                                         didFailWithError:error];
}

#pragma mark - Initialization

- (void)testClassInitializes
{
    XCTAssertNotNil(testSubject);
}

- (void)testSharedInstanceAlwaysReturned
{
    XCTAssertEqualObjects(testSubject, [[PSLocationController alloc] init]);
    XCTAssertEqualObjects(testSubject, [PSLocationController sharedInstance]);
}

#pragma mark - Accessors

- (void)testLongitudeReturnsWithLocation
{
    [self _updateLocationsWithFinalLatitude:111 longitude:222.222];
    XCTAssertEqual(testSubject.longitude, 222.222);
}


- (void)testLatitudeReturnsWithLocation
{
    [self _updateLocationsWithFinalLatitude:333.333 longitude:111];
    XCTAssertEqual(testSubject.latitude, 333.333);
}

-(void)testAuthorizationStatusReturns
{
    [[[mockLocationManagerClass stub] andReturnValue:OCMOCK_VALUE(kCLAuthorizationStatusDenied)] authorizationStatus];
    XCTAssertEqual([testSubject authorizationStatus], kCLAuthorizationStatusDenied);
}

- (void)testLocationServicesEnabledReturnsWhenEnabled
{
    [[[[mockLocationManagerClass stub] classMethod] andReturnValue:OCMOCK_VALUE(YES)] locationServicesEnabled];
    XCTAssertTrue([testSubject locationServicesEnabled]);
}

- (void)testLocationServicesEnabledReturnsWhenDisabled
{
    [[[[mockLocationManagerClass stub] classMethod] andReturnValue:OCMOCK_VALUE(NO)] locationServicesEnabled];
    XCTAssertFalse([mockTestSubject locationServicesEnabled]);
}

#pragma mark - Public Methods

-(void)testCheckLocationServicesAuthStatusReturnsTrueForCorrectStatuses
{
    [[[mockLocationManagerClass stub] andReturnValue:@(kCLAuthorizationStatusNotDetermined)] authorizationStatus];
    XCTAssertFalse([testSubject checkLocationServicesAuthorizationStatus]);

    mockLocationManagerClass = [OCMockObject mockForClass:[CLLocationManager class]];
    [[[mockLocationManagerClass stub] andReturnValue:@(kCLAuthorizationStatusAuthorizedWhenInUse)] authorizationStatus];
    XCTAssertTrue([mockTestSubject checkLocationServicesAuthorizationStatus]);
    
    mockLocationManagerClass = [OCMockObject mockForClass:[CLLocationManager class]];
    [[[mockLocationManagerClass stub] andReturnValue:@(kCLAuthorizationStatusAuthorizedAlways)] authorizationStatus];
    XCTAssertTrue([testSubject checkLocationServicesAuthorizationStatus]);
    
    mockLocationManagerClass = [OCMockObject mockForClass:[CLLocationManager class]];
    [[[mockLocationManagerClass stub] andReturnValue:@(kCLAuthorizationStatusRestricted)] authorizationStatus];
    XCTAssertFalse([testSubject checkLocationServicesAuthorizationStatus]);

    mockLocationManagerClass = [OCMockObject mockForClass:[CLLocationManager class]];
    [[[mockLocationManagerClass stub] andReturnValue:@(kCLAuthorizationStatusDenied)] authorizationStatus];
    XCTAssertFalse([testSubject checkLocationServicesAuthorizationStatus]);
}

- (void)testRequestLocationServicesAuthorization
{
    id mockApplication = [OCMockObject mockForClass:[UIApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    [[mockApplication expect] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    [testSubject requestLocationServicesAuthorization];
    [mockApplication verify];
    [mockApplication stopMocking];
}

- (void)testStartUpdatingLocation
{
    [[[[mockLocationManagerClass stub] classMethod] andReturnValue:OCMOCK_VALUE(YES)] locationServicesEnabled];
    [[mockLocationManager expect] startUpdatingLocation];
    [testSubject startUpdatingLocation];
    [mockLocationManager verify];
}

- (void)testStopUpdatingLocation
{
    [[[[mockLocationManagerClass stub] classMethod] andReturnValue:OCMOCK_VALUE(YES)] locationServicesEnabled];
    [[mockLocationManager expect] stopUpdatingLocation];
    [testSubject stopUpdatingLocation];
    [mockLocationManager verify];
}

#pragma mark - Current Location Placemark

- (void)testCurrentLocationPlacemarkCallsGeocoder
{
    XCTFail(@"Not implemented");
}

- (void)testCurrentLocationPlacemarkUpdatesPlacemarkProperty
{
    XCTFail(@"Not implemented");
}

- (void)testCurrentLocationPlacemarkCallsCompletionBlock
{
    XCTFail(@"Not implemented");
}

- (void)testCurrentLocationPlacemarkAcceptsNilCompletionBlock
{
    XCTFail(@"Not implemented");
}

#pragma mark - Location Updates

-(void)testLocationPropertyIsUpdatedWithMostRecentLocation
{
    [self _updateLocationsWithFinalLatitude:111.222 longitude:333.444];
    XCTAssertEqual(testSubject.location.coordinate.latitude, 111.222);
    XCTAssertEqual(testSubject.location.coordinate.longitude, 333.444);
    
    [self _updateLocationsWithFinalLatitude:-55.66 longitude:77.88];
    XCTAssertEqual(testSubject.location.coordinate.latitude, -55.66);
    XCTAssertEqual(testSubject.location.coordinate.longitude, 77.88);
}

-(void)testLocationPropertyIsNotUpdatedWithEmptyLocation
{
    [self _updateLocationsWithFinalLatitude:111.222 longitude:333.444];
    XCTAssertEqual(testSubject.location.coordinate.latitude, 111.222);
    XCTAssertEqual(testSubject.location.coordinate.longitude, 333.444);
    [testSubject.locationManager.delegate locationManager:testSubject.locationManager
                                       didUpdateLocations:nil];
    XCTAssertEqual(testSubject.location.coordinate.latitude, 111.222);
    XCTAssertEqual(testSubject.location.coordinate.longitude, 333.444);
    
}

-(void)testLocationNotification
{
    [[NSNotificationCenter defaultCenter] addMockObserver:mockObserver
                                                     name:kLocationUpdatedNotification
                                                   object:nil];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:-777.888
                                                      longitude:999.000];
    
    [[mockObserver expect] notificationWithName:kLocationUpdatedNotification
                                         object:testSubject
                                       userInfo:[OCMArg checkWithBlock:^BOOL(id obj) {
        return (obj[kLocationLocationUserInfoKey] == location);
    }]];

    [self _updateLocation:location];
    
    [mockObserver verify];
}

#pragma mark - Error Updates

-(void)testErrorNotification
{
    [[NSNotificationCenter defaultCenter] addMockObserver:mockObserver
                                                     name:kLocationErrorNotification
                                                   object:nil];
    NSError *someError = [NSError errorWithDomain:kCLErrorDomain code:1 userInfo:nil];

    [[mockObserver expect] notificationWithName:kLocationErrorNotification
                                         object:testSubject
                                       userInfo:[OCMArg checkWithBlock:^BOOL(id obj) {
        return (obj[kLocationErrorUserInfoKey] == someError);
    }]];

    [self _failWithError:someError];
    [mockObserver verify];
}

#pragma mark - Authorization Status Updates

- (void)testAuthorizationStatusUpdates
{
    XCTFail(@"Not implemented");
}


@end