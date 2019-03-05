#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)loginItemSwitchOn:(BOOL)on {
    self.enDisAbleResult.stringValue = @"";

    NSString* agentID = @"com.sheepsystems.LoginItemTesterAgent";
    BOOL ok = SMLoginItemSetEnabled(
                                    (__bridge CFStringRef)agentID,
                                    on ? true : false
                                    );

    NSString* message = [NSString stringWithFormat:
                         @"SMLoginItemSetEnabled() returned %@\n%@",
                         ok ? @"YES" : @"NO",
                         [NSDate date]];
    self.enDisAbleResult.stringValue = message;
}

- (IBAction)loginAgentOn:(id)sender {
    [self loginItemSwitchOn:YES];
}

- (IBAction)loginAgentOff:(id)sender {
    [self loginItemSwitchOn:NO];
}

@end
