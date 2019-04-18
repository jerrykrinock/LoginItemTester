#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @details  This class is an artifact of the demo only.  It is the thing which
 finds whether or not the agent process is running.  It has nothing to do with
 Service Manager Login Items or XPC.  If your purpose is to learn about
 Service Manager Login Items or XPC, ignore this class.
 */
@interface ProcessActivityChecker : NSObject

/*!
 @brief    If there is running a user's process with a given name, returns
 is process identifier (pid); otherwise returns 0
 */

+ (pid_t)pidOfMyRunningProcessWithCommandName:(NSString*)executableName;

@end

NS_ASSUME_NONNULL_END
