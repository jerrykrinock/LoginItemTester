#import "AgentAppDel.h"
#import "JobListener.h"

@interface AgentAppDel ()

//@property (weak) IBOutlet NSWindow *window;
@property (strong) NSXPCListener* xpcListener;
@property (strong) JobListener* jobListener;
@end

@implementation AgentAppDel

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // LaunchServices automatically registers a mach service of the same
    // name as our bundle identifier.
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSXPCListener *xpcListener = [[NSXPCListener alloc] initWithMachServiceName:bundleId];
    self.xpcListener = xpcListener;

    JobListener* jobListener = [JobListener new];
    self.jobListener = jobListener;
    xpcListener.delegate = jobListener;

    /* This method never returns.  It will wait for incoming connections using
     CFRunLoop or a dispatch queue, as appropriate. */
    [xpcListener resume];
}

/*!
 @details  This method never runs, presumably because when the system gets a
 command to disable the agent, it kills its process with a rude signal. */
- (void)applicationWillTerminate:(NSNotification *)notification {
}

@end
