//
//  ARViewController.h
//  ARKitDemo
//
//  Modified by Niels W Hansen on 12/31/11.
//  Modified by Ed Rackham (a1phanumeric) 2013
//

#import <UIKit/UIKit.h>
#import "ARLocationDelegate.h"
#import "ARViewProtocol.h"

@class AugmentedRealityController;

@interface ARViewController : UIViewController<ARMarkerDelegate, ARDelegate>

@property (nonatomic, assign) id<ARLocationDelegate> delegate;
@property (assign, nonatomic) BOOL showsCloseButton;

@property (assign, nonatomic, setter = setDebugMode:)                       BOOL debugMode;
@property (assign, nonatomic, setter = setShowsRadar:)                      BOOL showsRadar;
@property (assign, nonatomic, setter = setScaleViewsBasedOnDistance:)       BOOL scaleViewsBasedOnDistance;
@property (assign, nonatomic, setter = setMinimumScaleFactor:)              float minimumScaleFactor;
@property (assign, nonatomic, setter = setRotateViewsBasedOnPerspective:)   BOOL rotateViewsBasedOnPerspective;
@property (strong, nonatomic, setter = setRadarPointColour:)                UIColor *radarPointColour;
@property (strong, nonatomic, setter = setRadarBackgroundColour:)           UIColor *radarBackgroundColour;
@property (strong, nonatomic, setter = setRadarViewportColour:)             UIColor *radarViewportColour;
@property (assign, nonatomic, setter = setRadarRange:)                      float radarRange;
@property (assign, nonatomic, setter = setOnlyShowItemsWithinRadarRange:)   BOOL onlyShowItemsWithinRadarRange;

- (id)initWithDelegate:(id<ARLocationDelegate>)aDelegate;

@end

