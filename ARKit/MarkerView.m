//
//  CoordinateView.m
//  ARKitDemo
//
//  Modified by Niels W Hansen on 12/31/11.
//  Modified by Ed Rackham (a1phanumeric) 2013
//

#import "ARViewProtocol.h"
#import "ARGeoCoordinate.h"
#import "MarkerView.h"

#define LABEL_HEIGHT        20
#define LABEL_MARGIN        5
#define DISCLOSURE_MARGIN   10

@implementation MarkerView{
    BOOL                    _allowsCallout;
    UIImage                 *_bgImage;
    UILabel                 *_lblDistance;
    id<ARMarkerDelegate>    _delegate;
    ARGeoCoordinate         *_coordinateInfo;
}

- (id)initForCoordinate:(ARGeoCoordinate *)coordinate withDelgate:(id<ARMarkerDelegate>)aDelegate{
    return [self initForCoordinate:coordinate withDelgate:aDelegate allowsCallout:YES];
}

- (id)initForCoordinate:(ARGeoCoordinate *)coordinate withDelgate:(id<ARMarkerDelegate>)aDelegate allowsCallout:(BOOL)allowsCallout{
    
    _coordinateInfo = coordinate;
    _delegate       = aDelegate;
    _allowsCallout  = allowsCallout;
    _bgImage        = [UIImage imageNamed:@"bgCallout.png"];
    
    UIImage *disclosureImage    = [UIImage imageNamed:@"bgCalloutDisclosure.png"];
    CGSize calloutSize          = _bgImage.size;
	CGRect theFrame             = CGRectMake(0, 0, calloutSize.width, calloutSize.height);
	
    
	if(self = [super initWithFrame:theFrame]){
        
        [self setContentMode:UIViewContentModeScaleAspectFit];
        [self setAutoresizesSubviews:YES];
        
        if(_allowsCallout){
            [self setUserInteractionEnabled:YES];
        }
    
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:_bgImage];
        [self addSubview:bgImageView];
        
        CGSize labelSize = CGSizeMake(calloutSize.width - (LABEL_MARGIN * 2), LABEL_HEIGHT);
        if(_allowsCallout){
            labelSize.width -= disclosureImage.size.width + (DISCLOSURE_MARGIN * 2);
        }
        
        UILabel *titleLabel	= [[UILabel alloc] initWithFrame:CGRectMake(LABEL_MARGIN, LABEL_MARGIN, labelSize.width, labelSize.height)];
		[titleLabel setBackgroundColor: [UIColor clearColor]];
		[titleLabel setTextColor:		[UIColor whiteColor]];
		[titleLabel setTextAlignment:	NSTextAlignmentCenter];
        [titleLabel setFont:            [UIFont fontWithName:@"Helvetica-Bold" size:17.0]];
		[titleLabel setText:			[coordinate title]];
        [self addSubview:titleLabel];
        
        NSLocale *locale = [NSLocale currentLocale];
        _usesMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];

        
        _lblDistance = [[UILabel alloc] initWithFrame:CGRectMake(0, LABEL_HEIGHT + LABEL_MARGIN, labelSize.width, labelSize.height)];
		[_lblDistance setBackgroundColor:    [UIColor clearColor]];
		[_lblDistance setTextColor:          [UIColor whiteColor]];
		[_lblDistance setTextAlignment:      NSTextAlignmentCenter];
        [_lblDistance setFont:               [UIFont fontWithName:@"Helvetica" size:13.0]];
		if(_usesMetric == YES){
            [_lblDistance setText:[NSString stringWithFormat:@"%.2f km", [_coordinateInfo distanceFromOrigin]/1000.0f]];
        } else {
            [_lblDistance setText:[NSString stringWithFormat:@"%.2f mi", ([_coordinateInfo distanceFromOrigin]/1000.0f) * 0.621371]];
        }
        [self addSubview:_lblDistance];
        
		
        if(_allowsCallout){
            UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(calloutSize.width - disclosureImage.size.width - DISCLOSURE_MARGIN, DISCLOSURE_MARGIN, disclosureImage.size.width, disclosureImage.size.height)];
            [disclosureImageView setImage:[UIImage imageNamed:@"bgCalloutDisclosure.png"]];
            [self addSubview:disclosureImageView];
        }
        
        
        [self setBackgroundColor:[UIColor clearColor]];
	}
	
    return self;
    
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if(_usesMetric == YES){
        [_lblDistance setText:[NSString stringWithFormat:@"%.2f km", [_coordinateInfo distanceFromOrigin]/1000.0f]];
    } else {
        [_lblDistance setText:[NSString stringWithFormat:@"%.2f mi", ([_coordinateInfo distanceFromOrigin]/1000.0f) * 0.621371]];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_delegate didTapMarker:_coordinateInfo];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect theFrame = CGRectMake(0, 0, _bgImage.size.width, _bgImage.size.height);
    if(CGRectContainsPoint(theFrame, point))
        return YES; // touched the view;
    
    return NO;
}

@end
