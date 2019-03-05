#import "GUIAppDel.h"
#import <ServiceManagement/ServiceManagement.h>
#import "Constants.h"


@implementation GUIAppDel

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.connection = [[NSXPCConnection alloc] initWithServiceName: constAgentID];
    [self.connection setRemoteObjectInterface: [NSXPCInterface interfaceWithProtocol: @protocol(Worker)]];
    [self.connection resume];

    /*SSYDBL*/ NSLog(@"Resumed %@", self.connection) ;
    self.job = [self.connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        /* UI access must be on main thread. */
        dispatch_queue_t mainQueue = dispatch_get_main_queue() ;
        dispatch_sync(mainQueue, ^{
            self.textOutField.stringValue = [[NSString alloc] initWithFormat:
                                             @"%@: Error %ld: %@",
                                             [NSDate date],
                                             (long)error.code,
                                             error.localizedDescription];
        }) ;
    }];
}

- (void)loginItemSwitchOn:(BOOL)on {
    self.enDisAbleResult.stringValue = @"";

    BOOL ok = SMLoginItemSetEnabled(
                                    (__bridge CFStringRef)constAgentID,
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

- (IBAction)doWork:(id)sender {
    self.textOutField.stringValue = @"Waiting for Worker…";
    [self.job doWorkOn:[self.textInField stringValue]
                thenDo: ^(Job *job) {
                    /* UI access must be on main thread. */
                    dispatch_queue_t mainQueue = dispatch_get_main_queue() ;
                    dispatch_sync(mainQueue, ^{
                        self.textOutField.stringValue = job.answer;
                    }) ;
                }];
}

@end
