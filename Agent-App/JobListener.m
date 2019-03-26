#import "JobListener.h"
#import "Job.h"
#import "Constants.h"

@implementation JobListener

- (BOOL)          listener:(NSXPCListener *)listener
 shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(Worker)];
    newConnection.exportedInterface = interface;
    /* Next line is necessary because we pass a custom class (Job) via XPC.
     Note that, because ofReply=YES, the argumentIndex 0 is the position of
     the Job object in the *reply* block, not the position in
     the request selector -doWorkOn:thenDo: */
    [interface setClasses:[NSSet setWithObjects: [NSArray class], [NSString class], [NSDate class], [Job class], nil]
              forSelector:@selector(doWorkOn:thenDo:)
            argumentIndex:0
                  ofReply:YES];
    newConnection.exportedInterface = interface;
    newConnection.exportedObject = self;

    [newConnection resume];

    /* Start processing incoming messages */
    return YES;
}

- (void)getVersionThenDo:(void (^)(NSInteger))thenDo {
    thenDo(constAgentVersion);
}

- (void)doWorkOn:(NSString *)textIn
          thenDo:(void (^)(Job *))thenDo {

    // Pretend we are doing something difficult
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
    job.characterCount = answer.length;
    thenDo(job);
}

@end
