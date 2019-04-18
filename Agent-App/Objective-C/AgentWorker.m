#import "AgentWorker.h"
#import "AgentProxy.h"
#import "Constants.h"

@implementation AgentWorker

- (BOOL)          listener:(NSXPCListener *)listener
 shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(Worker)];
    newConnection.exportedInterface = interface;
    /* Next line is necessary because we pass a custom class (AgentProxy) via XPC.
     Note that, because ofReply=YES, the argumentIndex 0 is the position of
     the AgentProxy object in the *reply* block, not the position in
     the request selector -doWorkOn:thenDo: */
    [interface setClasses:[NSSet setWithObjects:[AgentProxy class], nil]
              forSelector:@selector(doWorkOn:thenDo:)
            argumentIndex:0
                  ofReply:YES];
    newConnection.exportedInterface = interface;
    newConnection.exportedObject = self;

    /* Begin accepting incoming messages */
    [newConnection resume];

    return YES;
}

- (void)getVersionThenDo:(void (^)(NSInteger))thenDo {
    thenDo(constAgentVersion);
}

- (void)doWorkOn:(NSString *)textIn
          thenDo:(void (^)(AgentProxy *))thenDo {

    /* Pretend we are doing something substantial. */
    [NSThread sleepForTimeInterval:0.1];

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

    AgentProxy *agentProxy = [AgentProxy new];
    agentProxy.text = [answer copy];
    agentProxy.characterCount = answer.length;
    agentProxy.timestamp = [NSDate date];
    thenDo(agentProxy);
}

@end
