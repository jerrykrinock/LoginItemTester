#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @details  This class is for the demo only.  It has nothing to do with
 Service Manager Login Items or XPC.  If your purpose is to learn about
 Service Manager Login Items or XPC, ignore this class.
 */
@interface ProcessActivityChecker : NSObject

/*!
 @brief    If there is running a user's process with a given name, returns
 is process identifier (pid); otherwise returns 0
 */

+ (pid_t)pidOfMyRunningExecutableName:(NSString*)executableName;

@end

NS_ASSUME_NONNULL_END
