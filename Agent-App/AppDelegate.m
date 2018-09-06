#import "AppDelegate.h"
#import "MojaveAccessTester.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    sleep(2);
    [MojaveAccessTester test];
}

@end
