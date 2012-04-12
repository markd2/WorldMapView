// WorldMap - Sample code for a Big Nerd Ranch Weblog posting about delegation .
// This is a very simple Xcode-generated AppDelegate / AppController class, which
// has a reference to the world map, and is a delegate for the map to provide
// it color information and to react to clicks on countries.

#import <Cocoa/Cocoa.h>

// Pull in the header so we can get the protocol definition.
// You can adopt the protocol in the class extension and keep the header file
// cleaner - that's for another posting.
#import "BNRWorldMapView.h"

// Adopt the BNRWorldMapViewDelegate to tell the world that we're prepared to
// act as a delegate for the map view
@interface BNRAppController : NSObject <NSApplicationDelegate, BNRWorldMapViewDelegate>

// Can't have weak references to NSWindows, so it's unsafe_unretained.
@property (unsafe_unretained) IBOutlet NSWindow *window;

// Current Apple guidelines is weak references for user interface objects.
@property (weak) IBOutlet BNRWorldMapView *worldMap;

@end // BNRAppController
