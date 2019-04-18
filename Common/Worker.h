#import <Foundation/Foundation.h>
#import "AgentProxy.h"

@protocol Worker

- (void)getVersionThenDo:(void (^)(NSInteger version))thenDo;

- (void)doWorkOn:(NSString*)textIn
          thenDo:(void (^)(AgentProxy *agentProxy))thenDo;

@end
