#import "AppDelegate.h"
#import "MojaveAccessTester.h"
#import <ServiceManagement/ServiceManagement.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)loginItemSwitchOn:(BOOL)on {
    BOOL ok = SMLoginItemSetEnabled(
                                    (CFStringRef)@"com.sheepsystems.MojaveAccessTesterAgent",
                                    on ? true : false
                                    );

    NSString* message = [NSString stringWithFormat:
                         @"Switching login item to %hhd succeeded=%hhd",
                         on,
                         ok];
    CFOptionFlags response ;
    // The following returns whether it "cancelled OK".
    // I don't know what that means.  But I don't need it now, anyhow.
    CFUserNotificationDisplayAlert (
                                    0,  // no timeout
                                    0,
                                    NULL,
                                    NULL,
                                    NULL,
                                    (CFStringRef)@"Setting Login Item  Result",
                                    (CFStringRef)message,
                                    (CFStringRef)@"OK",
                                    NULL,  // 2nd button title
                                    NULL,  // 3rd button title
                                    &response);

}

- (IBAction)loginAgentOn:(id)sender {
    [self loginItemSwitchOn:YES];
}

- (IBAction)loginAgentOff:(id)sender {
    [self loginItemSwitchOn:NO];
}

- (IBAction)testAccess:(id)sender {
    [MojaveAccessTester test];
}

@end
