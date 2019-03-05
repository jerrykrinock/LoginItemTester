#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // The following returns whether it "cancelled OK".
    // I'm not sure that means.  But I don't need it now, anyhow.
    CFUserNotificationDisplayAlert (
                                    0,  // no timeout
                                    kCFUserNotificationPlainAlertLevel,
                                    NULL,
                                    NULL,
                                    NULL,
                                    (CFStringRef)@"LoginItemTestAgent process has launched",
                                    (CFStringRef)[[NSDate date] description],
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL) ;
}

/*!
 @details  This method never runs, presumably because when the system gets a
 command to disable the agent, it kills our process with a rude signal. */
- (void)applicationWillTerminate:(NSNotification *)notification {
    CFUserNotificationDisplayAlert (
                                    0,  // no timeout
                                    kCFUserNotificationPlainAlertLevel,
                                    NULL,
                                    NULL,
                                    NULL,
                                    (CFStringRef)@"LoginItemTestAgent process will termintate",
                                    (CFStringRef)[[NSDate date] description],
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL) ;
}

@end
