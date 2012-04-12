#import "BNRAppController.h"

// This class extension declares a "private" property of a set that holds the
// countries that were clicked on.  Undecorated properties are strong references
// under ARC

@interface BNRAppController ()
@property  NSMutableSet *selectedCountries;
@end // BNRAppController


@implementation BNRAppController

// Use underscores to disambiguate instance variable access from self.property name.
// Contrary to popular opinion, Apple does not reserve leading underscores for ivars.
@synthesize window = _window;
@synthesize worldMap = _worldMap;
@synthesize selectedCountries = _selectedCountries;


// The object graph from the nib file has been loaded and all the connections
// set up, but nothing has been made visible to the user yet.  Set up our
// delegate relationship.  We are the world map's delegate, and we, the AppDelegate,
// will provide the map with information (country color) and respond to map
// activity (country clicks)

- (void) awakeFromNib {
    self.worldMap.delegate = self;
    self.selectedCountries = [NSMutableSet set];
} // awakeFromNib


#pragma mark WorldMap delegate methods

// Give the map the color to use for countries.
// OBTW, Finland has the highest metal band density, per capita.
// http://www.theatlanticwire.com/entertainment/2012/03/world-map-metal-band-population-density/50521/

- (NSColor *) worldMap: (BNRWorldMapView *) map  colorForCountryCode: (NSString *) code {

    if ([code isEqualToString: @"FI"]) {
        // Finland is red, because it is awesome.
        return [NSColor redColor];
    } else {

        if ([self.selectedCountries member: code]) {
            // Clicked-on countries turn orange.
            return [NSColor orangeColor];

        } else {
            // Otherwise default to a soothing yellow color.
            return [NSColor yellowColor];
        }
    }
} // colorForCountryCode


// React to countries being clicked - toggle their selected state.

- (void) worldMap: (BNRWorldMapView *) map  selectedCountryCode: (NSString *) code {

    // If the country code is in the set of selected countries, remove it, otherwise
    // add it.
    if ([self.selectedCountries member: code]) {
        [self.selectedCountries removeObject: code];
    } else {
        [self.selectedCountries addObject: code];
    }

    // Force a redraw.
    [self.worldMap setNeedsDisplay: YES];

} // selectedCountryCode

@end // BNRAppController
