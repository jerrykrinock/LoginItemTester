#import "ProcessActivityChecker.h"

NSString* const ProcessActivityCheckerErrorDomain = @"ProcessActivityCheckerErrorDomain" ;
NSString* const ProcessActivityCheckerKeyPid = @"pid" ;
NSString* const ProcessActivityCheckerKeyUser = @"user" ;
NSString* const ProcessActivityCheckerKeyEtime = @"etime" ;
NSString* const ProcessActivityCheckerKeyExecutable = @"executable" ;

@implementation ProcessActivityChecker

+ (NSArray*)pidsExecutablesFull:(BOOL)fullExecutablePath {
    // Run unix task "ps" and get results as an array, with each element containing process command and user
    // The invocation to be constructed is: ps -xa[c]awww -o pid -o user -o command
    // -ww is required for long command path strings!!
    NSData* stdoutData ;
    NSString* options = fullExecutablePath ? @"-xaww" : @"-xacww" ;
    NSString* command = @"/bin/ps";
    NSArray* args = [[NSArray alloc] initWithObjects:options, @"-o", @"pid=", @"-o", @"etime=", @"-o", @"user=", @"-o", @"comm=", nil] ;
    // In args, the "=" say to omit the column headers

    NSTask* task;
    NSPipe* pipeStdout = nil ;
    NSFileHandle* fileStdout = nil ;

    task = [[NSTask alloc] init] ;

    [task setLaunchPath:command] ;
    [task setArguments: args] ;

    pipeStdout = [[NSPipe alloc] init] ;
    fileStdout = [pipeStdout fileHandleForReading] ;
    [task setStandardOutput:pipeStdout ] ;
    [task launch];
    [task waitUntilExit];
    stdoutData = [fileStdout readDataToEndOfFile] ;

    NSMutableArray* processInfoDics = nil ;
    if (stdoutData) {
        NSString* processInfosString = [[NSString alloc] initWithData:stdoutData encoding:[NSString defaultCStringEncoding]] ;
        NSArray* processInfoStrings = [processInfosString componentsSeparatedByString:@"\n"] ;
        /* We must now parse processInfoStrings which looks like this (with fullExecutablePath = NO):
         *     1 root           launchd
         *    10 root           kextd
         *     …
         *    82 jk             loginwindow
         *    84 root           KernelEventAgent
         *     …
         * 30903 jk             CrashReporter
         * 32814 b              Google Chrome
         *     …
         * 48329 jk             Google Chrome Helper
         * 48330 jk             Google Chrome Helper EH
         *     …
         * 50253 root           activitymonitord
         * 53399 jk             CocoaMySQL
         * 53410 jk             mdworker
         * 53642 jk             gdb-i386-apple-darwin
         * 53651 jk             BookMacster
         *     …
         */

        processInfoDics = [[NSMutableArray alloc] init] ;
        NSScanner* scanner = nil ;
        for (NSString* processInfoString in processInfoStrings) {
            NSInteger pid ;
            NSString* user = nil ;
            NSString* etimeString = nil ;
            NSString* command ;
            BOOL ok ;

            scanner = [[NSScanner alloc] initWithString:processInfoString] ;
            [scanner setCharactersToBeSkipped:nil] ;

            // Scan leading whitespace, if any
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]
                                intoString:NULL] ;

            // Scan pid
            ok = [scanner scanInteger:&pid] ;
            if (!ok) {
                continue ;
            }

            // Scan whitespace between pid and etime
            ok = [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]
                                     intoString:NULL] ;
            if (!ok) {
                continue ;
            }

            /*
             Scan process elapsed time.  I would have preferred to get the
             start time using lstart or start rather than etime, but after a
             half hour of research, decided that their formats were too
             unpredictable to be parseable.
             */
            [scanner scanCharactersFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
                                intoString:&etimeString] ;

            // Scan whitespace between etime and user
            ok = [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]
                                     intoString:NULL] ;
            if (!ok) {
                continue ;
            }

            // Scan user.  Fortunately, short user names in macOS cannot contain whitespace
            [scanner scanCharactersFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
                                intoString:&user] ;

            // Scan whitespace between user and command
            ok = [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]
                                     intoString:NULL] ;
            if (!ok) {
                continue ;
            }

            // Get command which is the remainder of the string
            NSInteger commandBeginsAt = [scanner scanLocation] ;
            scanner = nil ;
            command = [processInfoString substringFromIndex:commandBeginsAt] ;

            NSDictionary* processInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInteger:pid], ProcessActivityCheckerKeyPid,
                                            user, ProcessActivityCheckerKeyUser,
                                            etimeString, ProcessActivityCheckerKeyEtime,
                                            command, ProcessActivityCheckerKeyExecutable,
                                            nil ] ;
            [processInfoDics addObject:processInfoDic] ;
        }
    }

    return [processInfoDics copy] ;
}


+ (pid_t)pidOfMyRunningExecutableName:(NSString*)executableName {
    pid_t pid = 0 ;  // not found
    NSString* targetUser = NSUserName() ;

    for (NSDictionary* processInfoDic in [self pidsExecutablesFull:NO]) {
        NSString* user = [processInfoDic objectForKey:ProcessActivityCheckerKeyUser] ;
        NSString* command = [processInfoDic objectForKey:ProcessActivityCheckerKeyExecutable] ;
        if ([targetUser isEqualToString:user] && [executableName isEqualToString:command]) {
            pid = (pid_t)[[processInfoDic objectForKey:ProcessActivityCheckerKeyPid] integerValue] ;
            break ;
        }
    }

    return pid ;
}

@end
