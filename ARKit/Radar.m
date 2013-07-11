//
//  Radar.m
//  ARKitDemo
//
//  Created by Ed Rackham (a1phanumeric) 2013
//  Based on mixare's implementation.
//

#import "Radar.h"

@implementation Radar{
    float _range;
}

@synthesize pois    = _pois;
@synthesize radius  = _radius;

- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor    = [UIColor clearColor];
        _radarBackgroundColour  = [UIColor colorWithRed:14.0/255.0 green:140.0/255.0 blue:14.0/255.0 alpha:0.2];
        _pointColour            = [UIColor whiteColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, _radarBackgroundColour.CGColor);
    
    // Draw a radar and the view port 
    CGContextFillEllipseInRect(contextRef, CGRectMake(0.5, 0.5, RADIUS*2, RADIUS*2)); 
    CGContextSetRGBStrokeColor(contextRef, 0, 255, 0, 0.5);
    
    _range = _radius *1000;
    float scale = _range / RADIUS;
    if (_pois != nil) {
        for (ARGeoCoordinate *poi in _pois) {
            float x, y;
            //case1: azimiut is in the 1 quadrant of the radar
            if (poi.azimuth >= 0 && poi.azimuth < M_PI / 2) {
                x = RADIUS + cosf((M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale);
                y = RADIUS - sinf((M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale);
            } else if (poi.azimuth > M_PI / 2 && poi.azimuth < M_PI) {
                //case2: azimiut is in the 2 quadrant of the radar
                x = RADIUS + cosf(poi.azimuth - (M_PI / 2)) * (poi.radialDistance / scale);
                y = RADIUS + sinf(poi.azimuth - (M_PI / 2)) * (poi.radialDistance / scale);
            } else if (poi.azimuth > M_PI && poi.azimuth < (3 * M_PI / 2)) {
                //case3: azimiut is in the 3 quadrant of the radar
                x = RADIUS - cosf((3 * M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale);
                y = RADIUS + sinf((3 * M_PI / 2) - poi.azimuth) * (poi.radialDistance / scale);
            } else if(poi.azimuth > (3 * M_PI / 2) && poi.azimuth < (2 * M_PI)) {
                //case4: azimiut is in the 4 quadrant of the radar
                x = RADIUS - cosf(poi.azimuth - (3 * M_PI / 2)) * (poi.radialDistance / scale);
                y = RADIUS - sinf(poi.azimuth - (3 * M_PI / 2)) * (poi.radialDistance / scale);
            } else if (poi.azimuth == 0) {
                x = RADIUS;
                y = RADIUS - poi.radialDistance / scale;
            } else if(poi.azimuth == M_PI/2) {
                x = RADIUS + poi.radialDistance / scale;
                y = RADIUS;
            } else if(poi.azimuth == (3 * M_PI / 2)) {
                x = RADIUS;
                y = RADIUS + poi.radialDistance / scale;
            } else if (poi.azimuth == (3 * M_PI / 2)) {
                x = RADIUS - poi.radialDistance / scale;
                y = RADIUS;
            } else {
                //If none of the above match we use the scenario where azimuth is 0
                x = RADIUS;
                y = RADIUS - poi.radialDistance / scale;
            }
            //drawing the radar point
            CGContextSetFillColorWithColor(contextRef, _pointColour.CGColor);
            if (x <= RADIUS * 2 && x >= 0 && y >= 0 && y <= RADIUS * 2) {
                CGContextFillEllipseInRect(contextRef, CGRectMake(x, y, 2, 2)); 
            }
        }
    }
}
@end
