import Foundation

/*!
 @details  This class is an artifact of the demo only.  It is the thing which
 finds whether or not the agent process is running.  It has nothing to do with
 Service Manager Login Items or XPC.  If your purpose is to learn about
 Service Manager Login Items or XPC, ignore this class.
 */


let ProcessActivityCheckerErrorDomain = "ProcessActivityCheckerErrorDomain"
let ProcessActivityCheckerKeyPid = "pid"
let ProcessActivityCheckerKeyUser = "user"
let ProcessActivityCheckerKeyEtime = "etime"
let ProcessActivityCheckerKeyExecutable = "executable"

class ProcessActivityChecker: NSObject {
    /*!
     @brief    If there is running a user's process with a given name, returns
     is process identifier (pid); otherwise returns 0
     */
    class func pidOfMyRunningProcess(withCommandName executableName: String?) -> pid_t {
        var pid = 0 as? pid_t // not found
        let targetUser = NSUserName()

        for processInfoDic in self.pidsExecutablesFull(false) {
            let user = processInfoDic[ProcessActivityCheckerKeyUser] as? String
            let command = processInfoDic[ProcessActivityCheckerKeyExecutable] as? String
            if (targetUser == user) && (executableName == command) {
                pid = processInfoDic[ProcessActivityCheckerKeyPid]?.intValue ?? 0 as? pid_t
                break
            }
        }

        return pid!
    }

    class func pidsExecutablesFull(_ fullExecutablePath: Bool) -> [Any]? {
        var stdoutData: Data?
        let options = fullExecutablePath ? "-xaww" : "-xacww"
        let command = "/bin/ps"
        let args = [options, "-o", "pid=", "-o", "etime=", "-o", "user=", "-o", "comm="]

        var task: Process?
        var pipeStdout: Pipe? = nil
        var fileStdout: FileHandle? = nil

        task = Process()

        task?.launchPath = command
        task?.arguments = args

        pipeStdout = Pipe()
        fileStdout = pipeStdout?.fileHandleForReading
        task?.standardOutput = pipeStdout
        task?.launch()
        task?.waitUntilExit()
        stdoutData = fileStdout?.readDataToEndOfFile()

        var processInfoDics: [AnyHashable]? = nil
        if stdoutData != nil {
            var processInfosString: String? = nil
            if let stdoutData = stdoutData {
                processInfosString = String(data: stdoutData, encoding: String.Encoding(NSString.defaultCStringEncoding))
            }
            let processInfoStrings = processInfosString?.components(separatedBy: "\n")

            processInfoDics = []
            let scanner: Scanner? = nil
        }

        for processInfoString in processInfoStrings {
            var pid: Int = 0
            var user: String? = nil
            var etimeString: String? = nil
            var command = ""
            var ok = false

            scanner = Scanner(string: processInfoString)
            scanner.charactersToBeSkipped = nil

            // Scan leading whitespace, if any
            scanner.scanCharacters(from: CharacterSet.whitespaces, into: nil)

            // Scan pid
            ok = scanner.scanInt(&pid)
            if !ok {
                continue
            }

            // Scan whitespace between pid and etime
            ok = scanner.scanCharacters(from: CharacterSet.whitespaces, into: nil)
            if !ok {
                continue
            }

            scanner.scanCharacters(from: CharacterSet.whitespaces.inverted, into: &etimeString)

            // Scan whitespace between etime and user
            ok = scanner.scanCharacters(from: CharacterSet.whitespaces, into: nil)
            if !ok {
                continue
            }

            // Scan user. Fortunately, short user names in macOS cannot contain whitespace
            scanner.scanCharacters(from: CharacterSet.whitespaces.inverted, into: &user)

            // Scan whitespace between user and command
            ok = scanner.scanCharacters(from: CharacterSet.whitespaces, into: nil)
            if !ok {
                continue
            }

            // Get command which is the remainder of the string
            var commandBeginsAt: Int = scanner.scanLocation
            scanner = nil
            command = (processInfoString as? NSString)?.substring(from: commandBeginsAt) ?? ""

            var processInfoDic = [
                ProcessActivityCheckerKeyPid : NSNumber(value: pid),
                ProcessActivityCheckerKeyUser : user ?? "",
                ProcessActivityCheckerKeyEtime : etimeString ?? "",
                ProcessActivityCheckerKeyExecutable : command
            ]
            processInfoDics.append(processInfoDic)
        }

        return processInfoDics
    }

}

