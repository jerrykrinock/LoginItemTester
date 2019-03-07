#import "AgentAppDel.h"
#import "JobListener.h"

@interface AgentAppDel ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AgentAppDel

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    /* An XPCService should use this singleton instance of serviceListener.
     It is preconfigured to listen on the name advertised by this XPCService's
     Info.plist. */
    NSXPCListener *listener = [NSXPCListener serviceListener];

    JobListener* delegate = [JobListener new];
    listener.delegate = delegate;

    /* This method never returns.  It will wait for incoming connections using
     CFRunLoop or a dispatch queue, as appropriate. */
    [listener resume];
}

/*!
 @details  This method never runs, presumably because when the system gets a
 command to disable the agent, it kills its process with a rude signal. */
- (void)applicationWillTerminate:(NSNotification *)notification {
}

@end
