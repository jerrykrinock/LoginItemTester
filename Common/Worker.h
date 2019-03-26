#import <Foundation/Foundation.h>
#import "Job.h"

@protocol Worker

- (void)getVersionThenDo:(void (^)(NSInteger version))thenDo;

- (void)doWorkOn:(NSString*)textIn
          thenDo:(void (^)(Job *job))thenDo;

@end
