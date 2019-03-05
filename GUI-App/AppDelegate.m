#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)loginItemSwitchOn:(BOOL)on {
    NSString* agentID = @"com.sheepsystems.LoginItemTesterAgent";
    BOOL ok = SMLoginItemSetEnabled(
                                    (__bridge CFStringRef)agentID,
                                    on ? true : false
                                    );

    NSString* message = [NSString stringWithFormat:
                         @"SMLoginItemSetEnabled() returned that switching %@ %@",
                         on ? @"ON" : @"OFF",
                         ok ? @"succeeded" : @"failed"];
    NSAlert* alert = [NSAlert new];
    alert.messageText = message;
    alert.informativeText = agentID;
    alert.alertStyle = ok ? NSAlertStyleInformational : NSAlertStyleCritical;
    [alert runModal];
}

- (IBAction)loginAgentOn:(id)sender {
    [self loginItemSwitchOn:YES];
}

- (IBAction)loginAgentOff:(id)sender {
    [self loginItemSwitchOn:NO];
}

@end
