#import "GUIAppDel.h"
#import <ServiceManagement/ServiceManagement.h>
#import "Constants.h"
#import "ProcessActivityChecker.h"


@implementation GUIAppDel

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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
    self.connection = [[NSXPCConnection alloc] initWithMachServiceName:constAgentID
                                                               options:0];
    [self.connection setRemoteObjectInterface: [NSXPCInterface interfaceWithProtocol: @protocol(Worker)]];
    [self.connection resume];

    self.job = [self.connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
        /* UI access must be on main thread. */
        dispatch_queue_t mainQueue = dispatch_get_main_queue() ;
        dispatch_sync(mainQueue, ^{
            NSString* errorNarrative = [[NSString alloc] initWithFormat:
                                        @"Got error sending to:\n   %@\nTime: %@\n%@ Error %ld:\n%@",
                                        constAgentID,
                                        [NSDate date],
                                        error.domain,
                                        (long)error.code,
                                        error.localizedDescription];
            /*SSYDBL*/ NSLog(@"Failed:\n%@", errorNarrative) ;
            self.textOutField.stringValue = errorNarrative;
        }) ;
    }];
    
    /*SSYDBL*/ NSLog(@"Asking agent to send its its version");
    [self.job getVersionThenDo:^(NSInteger version) {
        NSLog(@"Received from agent version %ld", (long)version);
    }];
    
    self.textOutField.stringValue = @"Waiting for Worker…";
    /*SSYDBL*/ NSLog(@"Sending actual work to agent");
    [self.job doWorkOn:[self.textInField stringValue]
                thenDo: ^(Job *job) {
                    NSString* versionVerdict = (job.agentVersion == constAgentVersion) ? @"as expected" : @"WRONG!";
                    /* UI access must be on main thread. */
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_sync(mainQueue, ^{
                        self.textOutField.stringValue = [NSString stringWithFormat:
                                                         @"From Agent version %ld (%@)\n\nAnswer:\n%@",
                                                         job.agentVersion,
                                                         versionVerdict,
                                                         job.answer];
                    }) ;
                }
     ];
}

@end
