//
//  CoordinateView.h
//  AR Kit
//
//  Created by Niels W Hansen on 12/31/11.
//  Modified by Ed Rackham (a1phanumeric) 2013
//

#import <UIKit/UIKit.h>
#import "ARViewProtocol.h"

@class ARGeoCoordinate;

@interface MarkerView : UIView

@property (nonatomic) BOOL usesMetric;

- (id)initForCoordinate:(ARGeoCoordinate *)coordinate withDelgate:(id<ARMarkerDelegate>) aDelegate;
- (id)initForCoordinate:(ARGeoCoordinate *)coordinate withDelgate:(id<ARMarkerDelegate>)aDelegate allowsCallout:(BOOL)allowsCallout;
@end
