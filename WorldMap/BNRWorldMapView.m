#import "BNRWorldMapView.h"

// Handy utility class to convert SVG stuff into an NSBezierPath.
// Thanks to martin Haywood for making this.
// http://ponderwell.net/2011/05/converting-svg-paths-to-objective-c-paths/
#import "SvgToBezier.h"

// A mapping of country codes to NSBezierPath objects.
static NSDictionary *g_countryPaths;


@implementation BNRWorldMapView
@synthesize delegate = _delegate;

// This gets called when the first object of this class is created, so lazy-load
// the map paths.
// Tha map-paths were created by browsing wikipedia for a world map.  Found a nice one at
// http://en.wikipedia.org/wiki/File:World_map_-_low_resolution.svg, by Al MacDonald
// I stripped off all the surounding XML goop, so I just got a path name and svg
// instructions for the path's outline, turning it into a nice trivial-to-process
// text file.  The country paths really aren't the point of this exercise, so "crude
// but effective" is the guiding principle

+ (void) initialize {

    // Check the class to make sure we do this work only once.  Without it, a subclass
    // would cause the path loading code to be run again.
    if (self == [BNRWorldMapView class]) {
        
        // A place to accumulate the paths and the country codes.
        NSMutableDictionary *countryPaths = [NSMutableDictionary dictionary];

        // map-paths.txt is included in our application bundle.
        NSURL *mapPathURL = [[NSBundle mainBundle] URLForResource: @"map-paths"
                                                   withExtension: @"txt"];
        NSError *error;
        NSString *allPaths = [[NSString alloc] initWithContentsOfURL: mapPathURL
                                               encoding: NSUTF8StringEncoding
                                               error: &error];
        // Always check the return value of the call, NEVER EVER EVER look at the
        // value of the NSError to decide happiness or failure.  NEVER NEVER NEVER!
        if (allPaths == nil) {
            NSLog (@"error loading world paths.  Error: %@", error);
            return;
        }

        // Split on the newline, so each line is a string.
        NSArray *splitPaths = [allPaths componentsSeparatedByString: @"\n"];

        // Process the file line by line
        for (NSString *splitPath in splitPaths) {

            // Skip empty strings or comments.
            if (splitPath.length == 0) continue;
            if ([splitPath characterAtIndex: 0] == '#') continue;

            // Split each line on a space.  This should give us the country code
            // in the zeroth position, and the blob of SVG stuffage in the oneth
            // position
            NSArray *components = [splitPath componentsSeparatedByString: @" "];
            NSString *key = [components objectAtIndex: 0];
            NSString *svgPath = [components objectAtIndex: 1];

            // Turn into an NSBezierPath, because those are easy to draw and
            // hit-test.
            SvgToBezier *converter =
                [[SvgToBezier alloc] initFromSVGPathNodeDAttr: svgPath
                                     rect: CGRectMake(0.0, 0.0, 950.0, 620.0)];
            
            if (converter.bezier == nil) {
                NSLog (@"could not convert path for %@", key);
            } else {
                [countryPaths setObject: converter.bezier  forKey: key];
            }
        }
        
        // The country paths dict we used is mutable.  No reason to leave a loaded
        // gun like that lying around, so make a copy to strip off the mutability,
        // and stash it into the global
        g_countryPaths = [countryPaths copy];
    }

} // initialize


// This is the first place where the delegate gets used : it's used to get the color
// for a country.
//
// The drawing algoirthm is pretty simple:
//    - loop through all the country paths.  These will come in arbitrary order, but
//      that's ok
//    - Ask the delegate for the color.  If there's no color, use white
//    - Fill the path with that color, and then stroke it.
//
// A fun exercise for the reader is to have the map resize as the view resizes.
// Right now it draws at 950x620, no matter the size of the map view

- (void) drawRect: (CGRect) rect {
    [[NSColor darkGrayColor] setStroke];

    for (NSString *countryCode in g_countryPaths) {
        NSBezierPath *path = [g_countryPaths objectForKey: countryCode];

        // Ask the delegate.
        NSColor *fillColor = [self.delegate worldMap: self
                                  colorForCountryCode: countryCode];
        if (fillColor == nil) fillColor = [NSColor whiteColor];

        [fillColor setFill];
        [path fill];

        [path stroke];
    }

} // drawRect


// This is the second place where the delegate gets used : it's used to tell someone
// else that a country was clicked.

- (void) mouseDown: (NSEvent *) event {
    NSPoint mouse = [self convertPoint: event.locationInWindow  fromView: nil];

    // Loop through all of the countries and see if any were hit.
    // You can get fancier data structures that reduce the number of hit-tests if 
    // measurement shows this to be a bottleneck
    for (NSString *countryCode in g_countryPaths) {

        // Get the path and hit-test it
        NSBezierPath *path = [g_countryPaths objectForKey: countryCode];
        if ([path containsPoint: mouse]) {

            NSLog (@"clicked in %@", countryCode);

            // If the delegate responds to the selector, tell it that this country
            // was clicked.
            if ([self.delegate 
                     respondsToSelector: @selector(worldMap:selectedCountryCode:)]) {
                [self.delegate worldMap: self  selectedCountryCode: countryCode];
            }

            // And then do any additional work.
        }
    }
    
} // mouseDown


// We're aflippa da bits!  Move the origin to the upper-left, otherwise the
// world will draw Australia-style.

- (BOOL) isFlipped {
    return YES;
} // isFlipped

@end // BNRWorldMapView
