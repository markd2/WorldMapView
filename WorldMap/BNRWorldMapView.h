// WorldMap - Sample code for a Big Nerd Ranch Weblog posting about delegation .
// This class displays a world map, using a delegate to provide the map with color
// information, and also (optionally), someone to inform when the user clicks on
// a country.

#import <Cocoa/Cocoa.h>

// Forward-declare the protocol so it can be used in the delegate property declaration
@protocol BNRWorldMapViewDelegate;


@interface BNRWorldMapView : NSView

// Always make delegate pointers weak (under ARC) or assign (manual memory management)
// so you dont get retain cycles.
// A bit about the type.  It's an |id|, so the delegate can point to any object.
// The id is decorated with the protocol name, so only objects that explicitly
// adopt this protocol can be assigned to this proeprty without compiler complaint.
@property (weak) id<BNRWorldMapViewDelegate> delegate;

@end // BNRWorldMapView


// Now for the protocol.  The protocol itself can adopt protocols.  In this case,
// someone who adopts BNRWorldMapViewDelegate must also implement all the methods
// declared in the NSObject protocol.  We're mainly interested in -respondsToSelector:
// so we can check for the existence of the optional method before calling it.
// Objects that inhert from NSObject (the class) automatically adopt NSObject (the
// protocol).  Folks who are wanting to use a proxy object have more work to do.
@protocol BNRWorldMapViewDelegate <NSObject>

// Given a world map, return a color for the given country code.
- (NSColor *) worldMap: (BNRWorldMapView *) map  colorForCountryCode: (NSString *) code;

@optional
// Someone clicked, in this world map, a particular country.  Go do something with
// that information.  Or not.  Up to you.  Not like I really care.  I'm just
// a map.  That responds to clicks.
- (void) worldMap: (BNRWorldMapView *) map  selectedCountryCode: (NSString *) code;

@end // BNRWorldMapViewDelegate
