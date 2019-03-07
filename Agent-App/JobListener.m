#import "JobListener.h"
#import "Job.h"

@implementation JobListener

- (BOOL)          listener:(NSXPCListener *)listener
 shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    [newConnection setExportedInterface: [NSXPCInterface interfaceWithProtocol:@protocol(Worker)]];
    [newConnection setExportedObject: self];

    [newConnection resume];

    return YES;
}

- (void)doWorkOn:(NSString *)textIn
          thenDo:(void (^)(Job *))thenDo {

    // Simulate actual work
    [NSThread sleepForTimeInterval:0.3];

    NSString* answer;
    if ([textIn.lowercaseString isEqualToString:@"kill"]) {
        exit(97);
    } else {

        NSMutableString* mutant = [NSMutableString new];
        for (NSInteger i=0; i<textIn.length; i++) {
            unichar aChar = [textIn characterAtIndex:i];
            NSString* aCharString = [NSString stringWithCharacters:&aChar
                                                            length:1];
            [mutant insertString:aCharString
                         atIndex:0];
        }
        answer = [mutant copy];

    }

    Job *job = nil;
    job = [Job new];
    job.answer = [answer copy];
    /* We hard code the agentVersion here.  Change it to verify that the
     newest version of the agent is being launched by macOS.  Note that
     this code (JobListener) is only built into the Agent-App, not the
     GUI-App.  */
    job.agentVersion = 1001;
    thenDo(job);
}

@end
