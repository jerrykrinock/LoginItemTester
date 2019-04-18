#import "GUIAppDel.h"
#import <ServiceManagement/ServiceManagement.h>
#import "Constants.h"
#import "ProcessActivityChecker.h"

@interface GUIAppDel ()
@property (retain) NSDateFormatter* dateFormatter;
@end

@implementation GUIAppDel

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSDateFormatter* dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:SS"];
    self.dateFormatter = dateFormatter;

    [self refreshActivityDisplay];
}

- (NSBundle*)agentBundle {
    NSString* path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByAppendingPathComponent:@"Contents"];
    path = [path stringByAppendingPathComponent:@"Library"];
    path = [path stringByAppendingPathComponent:@"LoginItems"];
    path = [path stringByAppendingPathComponent:@"LoginItemTesterAgent.app"];
    return [NSBundle bundleWithPath:path];
}

- (NSString*)agentBundleIdentifier {
    return [[self agentBundle] bundleIdentifier];
}

- (void)loginItemSwitchOn:(BOOL)on {
    /* Before actually doing it, blank the result text momentarily */
    self.enDisAbleResult.stringValue = @"";
    dispatch_queue_t mainQueue = dispatch_get_main_queue() ;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), mainQueue, ^{
        /* The following method almost always returns YES.  I don't even know
         how to make it return NO. */
        BOOL ok = SMLoginItemSetEnabled(
                                        (__bridge CFStringRef)[self agentBundleIdentifier],
                                        on ? true : false
                                        );

        NSString* message = [NSString stringWithFormat:
                             @"SMLoginItemSetEnabled(name,%@) returned %@",
                             on ? @"true" : @"false",
                             ok ? @"YES" : @"NO"];
        self.enDisAbleResult.stringValue = message;
    });
}

- (IBAction)loginAgentOn:(id)sender {
    [self loginItemSwitchOn:YES];
}

- (IBAction)loginAgentOff:(id)sender {
    [self loginItemSwitchOn:NO];
}

- (IBAction)startConnection:(id)sender {
    self.connection = [[NSXPCConnection alloc] initWithMachServiceName:[self agentBundleIdentifier]
                                                               options:0];
    [self.connection setRemoteObjectInterface: [NSXPCInterface interfaceWithProtocol: @protocol(Worker)]];
    [self.connection resume];
    self.connectionResult.stringValue = [[NSString alloc] initWithFormat:
                                         @"Created and resumed:\n%@",
                                         self.connection ];


    self.agentProxy = [self.connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        /* UI access must be on main thread. */
        dispatch_queue_t mainQueue = dispatch_get_main_queue() ;
        dispatch_sync(mainQueue, ^{
            NSString* errorNarrative = [[NSString alloc] initWithFormat:
                                        @"Got error sending to:\n   %@\nTime: %@\n%@ Error %ld:\n%@",
                                        [self agentBundleIdentifier],
                                        [self.dateFormatter stringFromDate:[NSDate date]],
                                        error.domain,
                                        (long)error.code,
                                        error.localizedDescription];
            self.textOutField.stringValue = errorNarrative;
        }) ;
    }];
}

- (IBAction)endConnection:(id)sender {
    /* If we did invalidate the connection, then the next time the user clicked
     "Reverse that string", the new connection would fail with
     NSCocoaErrorDomain Error 4099.  This is because the old connection would
     still be connected to the disabled login item, and so the port name would
     be already in use.  Remember, XPC is a fancy wrapper around Mach ports,
     and Mach port names on the system must be unique. */
    [self.connection invalidate];
    self.connectionResult.stringValue = [[NSString alloc] initWithFormat:
                                         @"Invalidated\n%@",
                                         self.connection ];
    self.connection = nil;
    self.agentProxy = nil;
}

- (IBAction)doWork:(id)sender {
    NSString* textIn = [self.textInField stringValue];
 
    if (self.agentProxy) {
        [self.agentProxy getVersionThenDo:^(NSInteger version) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue() ;
            dispatch_sync(mainQueue, ^{
                self.textOutField.stringValue = @"Waiting for Agent…";
            });
            [self.agentProxy doWorkOn:textIn
                               thenDo: ^(AgentProxy* agentProxy) {
                                   NSString* versionVerdict = (version == constAgentVersion) ? @"correct" : @"WRONG";
                                   /* UI access must be on main thread. */
                                   dispatch_queue_t mainQueue = dispatch_get_main_queue();
                                   dispatch_sync(mainQueue, ^{
                                       self.textOutField.stringValue = [NSString stringWithFormat:
                                                                        @"Answer from Agent version %ld (is %@ version):\n   text: %@\n   character count: %ld\n   timestamp: %@",
                                                                        (long)version,
                                                                        versionVerdict,
                                                                        agentProxy.text,
                                                                        (long)agentProxy.characterCount,
                                                                        [self.dateFormatter stringFromDate:agentProxy.timestamp]];
                                   }) ;
                               }
             ];

        }];
    } else {
        self.textOutField.stringValue = @"No agent proxy.\nStart Connection and then try again.";
    }
}

#pragma mark Agent Process Activity Status Blinker - only for this demo

- (void)refreshActivityDisplay {
    /* Oddly, for this Service Manager Login Item, the "command" printed by
     the unix `ps` command is the bundle identifier instead of the path to the
     executable.  I'm not sure why launchd does this, but it does. */
    NSString* agentProcessCommandName = [self agentBundleIdentifier];
    pid_t pid = [ProcessActivityChecker pidOfMyRunningProcessWithCommandName:agentProcessCommandName];
    if (pid > 0) {
        self.processActivityTextField.stringValue = [[NSString alloc] initWithFormat:
                                                     @"%@\nis running with pid %ld",
                                                     agentProcessCommandName,
                                                     (long)pid];
    } else {
        self.processActivityTextField.stringValue = [[NSString alloc] initWithFormat:
                                                     @"%@\nis not running",
                                                     agentProcessCommandName];
    }

    self.blinker.alphaValue = 1;
    [self performSelector:@selector(blinkActivityDisplay)
               withObject:nil
               afterDelay:0.2];
}

- (void)blinkActivityDisplay {
    self.blinker.alphaValue = 0;
    [self performSelector:@selector(refreshActivityDisplay)
               withObject:nil
               afterDelay:0.5];
}

@end
