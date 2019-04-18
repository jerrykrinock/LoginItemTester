#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Worker.h"

@interface AgentWorker : NSObject <NSXPCListenerDelegate, Worker>

@end
