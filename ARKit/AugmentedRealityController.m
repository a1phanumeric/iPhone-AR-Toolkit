//
//  AugmentedRealityController.m
//  AR Kit
//
//  Modified by Niels W Hansen on 5/25/12.
//  Modified by Ed Rackham (a1phanumeric) 2013
//

#import "AugmentedRealityController.h"
#import "ARCoordinate.h"
#import "ARGeoCoordinate.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#define kFilteringFactor 0.05
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(x) ((x) * 180.0/M_PI)
#define M_2PI 2.0 * M_PI
#define BOX_WIDTH 150
#define BOX_HEIGHT 100
#define BOX_GAP 10
#define ADJUST_BY 30
#define DISTANCE_FILTER 2.0
#define HEADING_FILTER 1.0
#define INTERVAL_UPDATE 0.75
#define SCALE_FACTOR 1.0
#define HEADING_NOT_SET -1.0
#define DEGREE_TO_UPDATE 1


@interface AugmentedRealityController (Private)
- (void) updateCenterCoordinate;
- (void) startListening;
- (void) currentDeviceOrientation;

- (double) findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth betweenNorth:(BOOL*) isBetweenNorth;
- (CGPoint) pointForCoordinate:(ARCoordinate *)coordinate;
- (BOOL) shouldDisplayCoordinate:(ARCoordinate *)coordinate;

@end

@implementation AugmentedRealityController

@synthesize locationManager;
@synthesize accelerometerManager;
@synthesize displayView;
@synthesize cameraView;
@synthesize rootViewController;
@synthesize centerCoordinate;
@synthesize scaleViewsBasedOnDistance;
@synthesize rotateViewsBasedOnPerspective;
@synthesize maximumScaleDistance;
@synthesize minimumScaleFactor;
@synthesize maximumRotationAngle;
@synthesize centerLocation;
@synthesize coordinates;
@synthesize debugMode;
@synthesize captureSession;
@synthesize previewLayer;
@synthesize delegate;


- (id)initWithViewController:(UIViewController *)vc withDelgate:(id<ARDelegate>) aDelegate {
    
    if (!(self = [super init]))
		return nil;
    
    [self setDelegate:aDelegate];

    latestHeading   = HEADING_NOT_SET;
    prevHeading     = HEADING_NOT_SET;
    
	[self setRootViewController: vc];
    [self setMaximumScaleDistance: 0.0];
	[self setMinimumScaleFactor: SCALE_FACTOR];
	[self setScaleViewsBasedOnDistance: NO];
	[self setRotateViewsBasedOnPerspective: NO];
    [self setOnlyShowItemsWithinRadarRange:NO];
	[self setMaximumRotationAngle: M_PI / 6.0];
    [self setCoordinates:[NSMutableArray array]];
    [self currentDeviceOrientation];
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if (cameraOrientation == UIDeviceOrientationLandscapeLeft || cameraOrientation == UIDeviceOrientationLandscapeRight) {
        screenRect.size.width  = [[UIScreen mainScreen] bounds].size.height;
        screenRect.size.height = [[UIScreen mainScreen] bounds].size.width;
    }
    
	UIView *camView = [[UIView alloc] initWithFrame:screenRect];
    UIView *displayV= [[UIView alloc] initWithFrame:screenRect];
    
    [displayV setAutoresizesSubviews:YES];
    [camView setAutoresizesSubviews:YES];
    
    camView.autoresizingMask    = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    displayV.autoresizingMask   = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
	degreeRange = [camView bounds].size.width / ADJUST_BY;
    
    
	[vc setView:displayV];
    [[vc view] insertSubview:camView atIndex:0];
    

#if !TARGET_IPHONE_SIMULATOR
    
    AVCaptureSession *avCaptureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    
    if (videoInput) {
        [avCaptureSession addInput:videoInput];
    }
    else {
        // Handle the failure.
    }
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:avCaptureSession];

    [[camView layer] setMasksToBounds:NO];

    [newCaptureVideoPreviewLayer setFrame:[camView bounds]];
    
    if ([newCaptureVideoPreviewLayer.connection isVideoOrientationSupported]) {
        [newCaptureVideoPreviewLayer.connection setVideoOrientation:cameraOrientation];
    }
    
    [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [[camView layer] insertSublayer:newCaptureVideoPreviewLayer below:[[[camView layer] sublayers] objectAtIndex:0]];
    
    [self setPreviewLayer:newCaptureVideoPreviewLayer];
    
    [avCaptureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [avCaptureSession startRunning];
    
    [self setCaptureSession:avCaptureSession];
#endif

    CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:37.41711 longitude:-122.02528]; //TODO: We should get the latest heading here.
	
	[self setCenterLocation: newCenter];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	
    
	
	[self startListening];
    [self setCameraView:camView];
    [self setDisplayView:displayV];
    
    
  	return self;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (void)setShowsRadar:(BOOL)showsRadar{
    _showsRadar = showsRadar;
    
    [_radarView          removeFromSuperview];
    [_radarViewPort      removeFromSuperview];
    [radarNorthLabel    removeFromSuperview];
    
    _radarView       = nil;
    _radarViewPort   = nil;
    radarNorthLabel = nil;
    
    if(_showsRadar){
        
        CGRect displayFrame = [[[self rootViewController] view] frame];
        
        _radarView       = [[Radar alloc] initWithFrame:CGRectMake(displayFrame.size.width - 63, 2, 61, 61)];
        _radarViewPort   = [[RadarViewPortView alloc] initWithFrame:CGRectMake(displayFrame.size.width - 63, 2, 61, 61)];
        
        radarNorthLabel = [[UILabel alloc] initWithFrame:CGRectMake(displayFrame.size.width - 37, 2, 10, 10)];
        radarNorthLabel.backgroundColor = [UIColor clearColor];
        radarNorthLabel.textColor = [UIColor whiteColor];
        radarNorthLabel.font = [UIFont boldSystemFontOfSize:8.0];
        radarNorthLabel.textAlignment = NSTextAlignmentCenter;
        radarNorthLabel.text = @"N";
        radarNorthLabel.alpha = 0.8;
        
        
        _radarView.autoresizingMask         = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        _radarViewPort.autoresizingMask     = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        radarNorthLabel.autoresizingMask    = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        [self.displayView addSubview:_radarView];
        [self.displayView addSubview:_radarViewPort];
        [self.displayView addSubview:radarNorthLabel];
    }
}

-(void)unloadAV {
    [captureSession stopRunning];
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    [[self previewLayer] removeFromSuperlayer];
    [self setCaptureSession:nil];
    [self setPreviewLayer:nil];	
}

- (void)dealloc {
    [self stopListening];
    [self unloadAV];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    locationManager.delegate = nil;
    [UIAccelerometer sharedAccelerometer].delegate = nil;
}

#pragma mark -	
#pragma mark Location Manager methods
- (void)startListening {
	
	// start our heading readings and our accelerometer readings.
	if (![self locationManager]) {
		CLLocationManager *newLocationManager = [[CLLocationManager alloc] init];

        [newLocationManager setHeadingFilter: HEADING_FILTER];
        [newLocationManager setDistanceFilter:DISTANCE_FILTER];
		[newLocationManager setDesiredAccuracy: kCLLocationAccuracyNearestTenMeters];
		[newLocationManager startUpdatingHeading];
		[newLocationManager startUpdatingLocation];
		[newLocationManager setDelegate: self];
        
        [self setLocationManager: newLocationManager];
	}
			
	if (![self accelerometerManager]) {
		[self setAccelerometerManager: [UIAccelerometer sharedAccelerometer]];
		[[self accelerometerManager] setUpdateInterval: INTERVAL_UPDATE];
		[[self accelerometerManager] setDelegate: self];
	}
	
	if (![self centerCoordinate]) 
		[self setCenterCoordinate:[ARCoordinate coordinateWithRadialDistance:1.0 inclination:0 azimuth:0]];
}

- (void)stopListening {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
    if ([self locationManager]) {
       [[self locationManager] setDelegate: nil];
    }
    
    if ([self accelerometerManager]) {
       [[self accelerometerManager] setDelegate: nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    latestHeading = degreesToRadian(newHeading.magneticHeading);
    
    //Let's only update the Center Coordinate when we have adjusted by more than X degrees
    if (fabs(latestHeading-prevHeading) >= degreesToRadian(DEGREE_TO_UPDATE) || prevHeading == HEADING_NOT_SET) {
        prevHeading = latestHeading;
        [self updateCenterCoordinate];
        [[self delegate] didUpdateHeading:newHeading];
    }
    
    
    if(_showsRadar){
        int gradToRotate = newHeading.magneticHeading - 90 - 22.5;
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
            gradToRotate += 90;
        }
        if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
            gradToRotate -= 90;
        }
        if (gradToRotate < 0) {
            gradToRotate = 360 + gradToRotate;
        }
        
        _radarViewPort.referenceAngle = gradToRotate;
        [_radarViewPort setNeedsDisplay];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self setCenterLocation:newLocation];
    [[self delegate] didUpdateLocation:newLocation];
    
}

- (void)updateCenterCoordinate {
	
	double adjustment = 0;

    switch (cameraOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            adjustment = degreesToRadian(270); 
            break;
        case UIDeviceOrientationLandscapeRight:    
            adjustment = degreesToRadian(90);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            adjustment = degreesToRadian(180);
            break;
        default:
            adjustment = 0;
            break;
    }
	
	[[self centerCoordinate] setAzimuth: latestHeading - adjustment];
	[self updateLocations];
}

- (void)setCenterLocation:(CLLocation *)newLocation {
	centerLocation = newLocation;
	
	for (ARGeoCoordinate *geoLocation in [self coordinates]) {
		
		if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
			
            if(_onlyShowItemsWithinRadarRange){
                if(([geoLocation radialDistance] / 1000) > _radarRange){
                    continue;
                }
            }
            
			if ([geoLocation radialDistance] > [self maximumScaleDistance]) 
				[self setMaximumScaleDistance:[geoLocation radialDistance]];
		}
	}
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	switch (cameraOrientation) {
		case UIDeviceOrientationLandscapeLeft:
			viewAngle = atan2(acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationLandscapeRight:
			viewAngle = atan2(-acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationPortrait:
			viewAngle = atan2(acceleration.y, acceleration.z);
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			viewAngle = atan2(-acceleration.y, acceleration.z);
			break;	
		default:
			break;
	}
}

#pragma mark -	
#pragma mark Coordinate methods

- (void)addCoordinate:(ARGeoCoordinate *)coordinate {
	
	[[self coordinates] addObject:coordinate];
	
	if ([coordinate radialDistance] > [self maximumScaleDistance]) 
		[self setMaximumScaleDistance: [coordinate radialDistance]];
}

- (void)removeCoordinate:(ARGeoCoordinate *)coordinate {
	[[self coordinates] removeObject:coordinate];
}

- (void)removeCoordinates:(NSArray *)coordinateArray {	
	
	for (ARGeoCoordinate *coordinateToRemove in coordinateArray) {
		NSUInteger indexToRemove = [[self coordinates] indexOfObject:coordinateToRemove];
		
		//TODO: Error checking in here.
		[[self coordinates] removeObjectAtIndex:indexToRemove];
	}
}

#pragma mark -	
#pragma mark Location methods

-(double) findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth betweenNorth:(BOOL*) isBetweenNorth {

	if (*centerAzimuth < 0.0) 
		*centerAzimuth = M_2PI + *centerAzimuth;
	
	if (*centerAzimuth > M_2PI) 
		*centerAzimuth = *centerAzimuth - M_2PI;
	
	double deltaAzimuth = ABS(pointAzimuth - *centerAzimuth);
	*isBetweenNorth		= NO;

	// If values are on either side of the Azimuth of North we need to adjust it.  Only check the degree range
	if (*centerAzimuth < degreesToRadian(degreeRange) && pointAzimuth > degreesToRadian(360-degreeRange)) {
		deltaAzimuth	= (*centerAzimuth + (M_2PI - pointAzimuth));
		*isBetweenNorth = YES;
	}
	else if (pointAzimuth < degreesToRadian(degreeRange) && *centerAzimuth > degreesToRadian(360-degreeRange)) {
		deltaAzimuth	= (pointAzimuth + (M_2PI - *centerAzimuth));
		*isBetweenNorth = YES;
	}
			
	return deltaAzimuth;
}

- (BOOL)shouldDisplayCoordinate:(ARCoordinate *)coordinate {
	
	double currentAzimuth = [[self centerCoordinate] azimuth];
	double pointAzimuth	  = [coordinate azimuth];
	BOOL isBetweenNorth	  = NO;
	double deltaAzimuth	  = [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth betweenNorth:&isBetweenNorth];
	BOOL result			  = NO;
	
  //  NSLog(@"Current %f, Item %f, delta %f, range %f",currentAzimuth,pointAzimuth,deltaAzimith,degreesToRadian([self degreeRange]));
    
	if (deltaAzimuth <= degreesToRadian(degreeRange)){
		result = YES;
    }
    
    // Limit results to only those within radar range (if set)
    if(_onlyShowItemsWithinRadarRange){
        if(([coordinate radialDistance] / 1000) > _radarRange){
            result = NO;
        }
    }
    
	return result;
}

- (CGPoint)pointForCoordinate:(ARCoordinate *)coordinate {	
	
	CGPoint point;
	CGRect realityBounds	= [[self displayView] bounds];
	double currentAzimuth	= [[self centerCoordinate] azimuth];
	double pointAzimuth		= [coordinate azimuth];
	BOOL isBetweenNorth		= NO;
	double deltaAzimith		= [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth betweenNorth:&isBetweenNorth];
	
	if ((pointAzimuth > currentAzimuth && !isBetweenNorth) || 
        (currentAzimuth > degreesToRadian(360- degreeRange) && pointAzimuth < degreesToRadian(degreeRange))) {
		point.x = (realityBounds.size.width / 2) + ((deltaAzimith / degreesToRadian(1)) * ADJUST_BY);  // Right side of Azimuth
    }
	else
		point.x = (realityBounds.size.width / 2) - ((deltaAzimith / degreesToRadian(1)) * ADJUST_BY);	// Left side of Azimuth
	
	point.y = (realityBounds.size.height / 2) + (radianToDegrees(M_PI_2 + viewAngle)  * 2.0);
  	
	return point;
}

- (void)updateLocations {
	
    NSMutableArray *radarPointValues = [[NSMutableArray alloc] initWithCapacity:[self.coordinates count]];
    
	for (ARGeoCoordinate *item in [self coordinates]) {
        
        UIView *markerView = [item displayView];
        
		if ([self shouldDisplayCoordinate:item]) {
		
            CGPoint loc = [self pointForCoordinate:item];
            CGFloat scaleFactor = SCALE_FACTOR;
	
			if ([self scaleViewsBasedOnDistance]) {
				scaleFactor = scaleFactor - [self minimumScaleFactor]*([item radialDistance] / [self maximumScaleDistance]);
            }

			float width	 = [markerView bounds].size.width  * scaleFactor;
			float height = [markerView bounds].size.height * scaleFactor;

			[markerView setFrame:CGRectMake(loc.x - width / 2.0, loc.y, width, height)];
            [markerView setNeedsDisplay];
			
			CATransform3D transform = CATransform3DIdentity;
			
			// Set the scale if it needs it. Scale the perspective transform if we have one.
			if ([self scaleViewsBasedOnDistance]) 
				transform = CATransform3DScale(transform, scaleFactor, scaleFactor, scaleFactor);
		
			if ([self rotateViewsBasedOnPerspective]) {
				transform.m34 = 1.0 / 300.0;
		/*		
				double itemAzimuth		= [item azimuth];
				double centerAzimuth	= [[self centerCoordinate] azimuth];
				
				if (itemAzimuth - centerAzimuth > M_PI) 
					centerAzimuth += M_2PI;
				
				if (itemAzimuth - centerAzimuth < -M_PI) 
					itemAzimuth  += M_2PI;
		*/		
		//		double angleDifference	= itemAzimuth - centerAzimuth;
		//		transform				= CATransform3DRotate(transform, [self maximumRotationAngle] * angleDifference / 0.3696f , 0, 1, 0);
			}
			[[markerView layer] setTransform:transform];
			
			//if marker is not already set then insert it
			if (!([markerView superview])) {
				[[self displayView] insertSubview:markerView atIndex:1];
			}
		}else {
            if([markerView superview]){
                [markerView removeFromSuperview];
            }
        }
        
        [radarPointValues addObject:item];
        
	}
    
    if(_showsRadar){
        _radarView.pois      = radarPointValues;
        _radarView.radius    = _radarRange;
        [_radarView setNeedsDisplay];
    }
}

- (NSComparisonResult)LocationSortClosestFirst:(ARCoordinate *)s1 secondCoord:(ARCoordinate*)s2{
    
	if ([s1 radialDistance] < [s2 radialDistance]) 
		return NSOrderedAscending;
	else if ([s1 radialDistance] > [s2 radialDistance]) 
		return NSOrderedDescending;
	else 
		return NSOrderedSame;
}

#pragma mark -	
#pragma mark Device Orientation

- (void)currentDeviceOrientation {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
	if (orientation != UIDeviceOrientationUnknown && orientation != UIDeviceOrientationFaceUp && orientation != UIDeviceOrientationFaceDown) {
		switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
                cameraOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                cameraOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                cameraOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            case UIDeviceOrientationPortrait:
                cameraOrientation = AVCaptureVideoOrientationPortrait;
                break;
            default:
                break;
        }
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	
	prevHeading = HEADING_NOT_SET; 
    
    [self currentDeviceOrientation];
	
    [[self previewLayer].connection setVideoOrientation:cameraOrientation];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
    CGRect newFrame = [[UIScreen mainScreen] bounds];
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            newFrame.size.width     = [[UIScreen mainScreen] applicationFrame].size.height;
            newFrame.size.height    = [[UIScreen mainScreen] applicationFrame].size.width;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        default:
            break;
    }
    
    [previewLayer setFrame:[self.cameraView bounds]];
    
    if ([previewLayer.connection isVideoOrientationSupported]) {
        [previewLayer.connection setVideoOrientation:cameraOrientation];
    }
    
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //Last but not least we need to move the radar if we are displaying one
    if(_radarViewPort && _radarView)
    {
        [radarNorthLabel setFrame:CGRectMake(newFrame.size.width - 37, 2, 10, 10)];
        [_radarView setFrame:CGRectMake(newFrame.size.width - 63, 2, 61, 61)];
        [_radarViewPort setFrame:CGRectMake(newFrame.size.width - 63, 2, 61, 61)];
    }
}
@end
