//
//  ViewController.m
//  iPhone-AR-Demo
//
//  Created by Ed Rackham on 03/01/2013.
//  Copyright (c) 2013 edrackham.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    ARViewController    *_arViewController;
    NSArray             *_mapPoints;
}

@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAR:(id)sender {
    if([ARKit deviceSupportsAR]){
        _arViewController = [[ARViewController alloc] initWithDelegate:self];
        //[_arViewController setShowsRadar:YES];
        //[_arViewController setRadarBackgroundColour:[UIColor blackColor]];
        //[_arViewController setRadarViewportColour:[UIColor darkGrayColor]];
        //[_arViewController setRadarPointColour:[UIColor whiteColor]];
        [_arViewController setRadarRange:4000.0];
        [_arViewController setOnlyShowItemsWithinRadarRange:YES];
        [_arViewController setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:_arViewController animated:YES completion:nil];
    }
}

- (IBAction)startARWithoutCloseButton:(id)sender {
    if([ARKit deviceSupportsAR]){
        _arViewController = [[ARViewController alloc] initWithDelegate:self];
        _arViewController.showsCloseButton = false;
        [_arViewController setRadarRange:4000.0];
        [_arViewController setOnlyShowItemsWithinRadarRange:YES];
        [_arViewController setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:_arViewController animated:YES completion:nil];
    }
}

- (NSMutableArray *)geoLocations{
    
    NSMutableArray *locationArray = [[NSMutableArray alloc] init];
    ARGeoCoordinate *tempCoordinate;
    CLLocation       *tempLocation;
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:39.550051 longitude:-105.782067];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Denver"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:45.523875 longitude:-122.670399];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Portland"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:41.879535 longitude:-87.624333];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Chicago"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:30.268735 longitude:-97.745209];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Austin"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:51.500152 longitude:-0.126236];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"London"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:48.856667 longitude:2.350987];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Paris"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:55.676294 longitude:12.568116];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Copenhagen"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:52.373801 longitude:4.890935];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Amsterdam"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:19.611544 longitude:-155.665283];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Hawaii"];
    tempCoordinate.inclination = M_PI/30;
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:40.756054 longitude:-73.986951];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"New York City"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:42.35892 longitude:-71.05781];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Boston"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:49.817492 longitude:15.472962];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Czech Republic"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:53.41291 longitude:-8.24389];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Ireland"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:38.892091 longitude:-77.024055];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Washington, DC"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:45.545447 longitude:-73.639076];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Montreal"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:32.78 longitude:-117.15];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"San Diego"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:-40.900557 longitude:174.885971];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Munich"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:33.5033333 longitude:-117.126611];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Temecula"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:19.26 longitude:-99.8];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Mexico City"];
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:53.566667 longitude:-113.516667];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Edmonton"];
    tempCoordinate.inclination = 0.5;
    [locationArray addObject:tempCoordinate];
    
    
    tempLocation = [[CLLocation alloc] initWithLatitude:47.620973 longitude:-122.347276];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Seattle"];
    [locationArray addObject:tempCoordinate];

    tempLocation = [[CLLocation alloc] initWithLatitude:50.461921 longitude:-3.525315];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Torquay"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:50.43548 longitude:-3.561437];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Paignton"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:50.394304 longitude:-3.513823];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Brixham"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:50.4327 longitude:-3.686686];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Totnes"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:50.458061 longitude:-3.597078];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Marldon"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:50.528717 longitude:-3.606691];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Newton Abbot"];
    [locationArray addObject:tempCoordinate];
    
    
    return locationArray;
}


- (void)locationClicked:(ARGeoCoordinate *)coordinate{
    NSLog(@"%@", coordinate);
}
@end
