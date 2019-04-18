#import "AgentAppDel.h"
#import "AgentWorker.h"

@interface AgentAppDel ()

//@property (weak) IBOutlet NSWindow *window;
@property (strong) NSXPCListener* xpcListener;
@property (strong) AgentWorker* agentWorker;
@end

@implementation AgentAppDel

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    /* LaunchServices automatically registers a mach service of the same
     name as our bundle identifier.  So, we create a listener to that same
     identifier. */
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSXPCListener *xpcListener = [[NSXPCListener alloc] initWithMachServiceName:bundleId];
    self.xpcListener = xpcListener;

	/* Our xpc listener will delegate received jobs to its delegate. */
    AgentWorker* agentWorker = [AgentWorker new];
    self.agentWorker = agentWorker;
    xpcListener.delegate = agentWorker;

    /* Depending on how an XPC listener is configured, the following method
     may or may not ever return.  With our configuration, this method *does*
     return. */
    [xpcListener resume];
}

/*!
 @details  This method does *not* run when the GUI app calls
 SMLoginItemEnable(NO), presumably because that call kills its process with a
 rude signal of some kind. */
- (void)applicationWillTerminate:(NSNotification *)notification {
    /* Do not put any code here because it will never run. */
}

@end
