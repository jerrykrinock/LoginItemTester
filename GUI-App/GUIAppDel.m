#import "GUIAppDel.h"
#import <ServiceManagement/ServiceManagement.h>
#import "Constants.h"
#import "ProcessActivityChecker.h"


@implementation GUIAppDel

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.connection = [[NSXPCConnection alloc] initWithServiceName: constAgentID];
    [self.connection setRemoteObjectInterface: [NSXPCInterface interfaceWithProtocol: @protocol(Worker)]];
    [self.connection resume];

    self.job = [self.connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        /* UI access must be on main thread. */
        dispatch_queue_t mainQueue = dispatch_get_main_queue() ;
        dispatch_sync(mainQueue, ^{
            self.textOutField.stringValue = [[NSString alloc] initWithFormat:
                                             @"%@:\n%@ %ld:\n%@",
                                             [NSDate date],
                                             error.domain,
                                             (long)error.code,
                                             error.localizedDescription];
        }) ;
    }];

    [self refreshActivityDisplay];
}

- (void)refreshActivityDisplay {
    NSString* agentProcessExecutableName = [constAgentID lastPathComponent];
    pid_t pid = [ProcessActivityChecker pidOfMyRunningExecutableName:agentProcessExecutableName];
    if (pid > 0) {
        self.processActivityTextField.stringValue = [[NSString alloc] initWithFormat:
                                                   @"%@\nis running with pid %ld",
                                                   agentProcessExecutableName,
                                                   (long)pid];
    } else {
        self.processActivityTextField.stringValue = [[NSString alloc] initWithFormat:
                                                   @"%@\nis not running",
                                                   agentProcessExecutableName];
    }

    self.blinker.integerValue = 1;
    [self performSelector:@selector(blinkActivityDisplay)
               withObject:nil
               afterDelay:0.2];
}

- (void)blinkActivityDisplay {
    self.blinker.integerValue = 0;
    [self performSelector:@selector(refreshActivityDisplay)
               withObject:nil
               afterDelay:0.5];
}

- (void)loginItemSwitchOn:(BOOL)on {
    self.enDisAbleResult.stringValue = @"";

    BOOL ok = SMLoginItemSetEnabled(
                                    (__bridge CFStringRef)constAgentID,
                                    on ? true : false
                                    );

    NSString* message = [NSString stringWithFormat:
                         @"SMLoginItemSetEnabled() returned %@\nwhen called to %@able\n%@\n%@",
                         ok ? @"YES" : @"NO",
                         on ? @"EN" : @"DIS",
                         constAgentID,
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
                        self.textOutField.stringValue = [NSString stringWithFormat:
                                                         @"Answer from Agent version %ld:\n%@",
                                                         job.agentVersion,
                                                         job.answer];
                    }) ;
                }];
}

@end
