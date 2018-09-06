#import "MojaveAccessTester.h"

@implementation MojaveAccessTester

+ (void)test {
    NSError* error = nil;
    NSData* data = nil;
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Safari/Bookmarks.plist"];
	if (path) {
        data = [NSData dataWithContentsOfFile:path];
        if (!data) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                error = [NSError errorWithDomain:@"MojaveAccessErrorDomain"
                                            code:666
                                        userInfo:@{
                                                   NSLocalizedDescriptionKey : @"Looks like we've been denied."
                                                   }];
            }
        }
    }

    NSString* message;
    if (data.length > 0) {
        message = [NSString stringWithFormat:@"Got %ld bytes of Safari data", (long)data.length];
    } else if (error) {
        message = [error localizedDescription];
    } else {
        message = @"Unreported error";
    }

    NSArray<NSString *> *args = [[NSProcessInfo processInfo] arguments];
    NSString* executablePath = [args objectAtIndex:0];
    message = [message stringByAppendingFormat:
               @"\n\nPath of this Executable is:\n\n%@",
               executablePath];

    CFOptionFlags response ;
    // The following returns whether it "cancelled OK".
    // I don't know what that means.  But I don't need it now, anyhow.
    CFUserNotificationDisplayAlert (
                                    0,  // no timeout
                                    0,
                                    NULL,
                                    NULL,
                                    NULL,
                                    (CFStringRef)@"Test Result",
                                    (CFStringRef)message,
                                    (CFStringRef)@"OK",
                                    NULL,  // 2nd button title
                                    NULL,  // 3rd button title
                                    &response);
}


@end
