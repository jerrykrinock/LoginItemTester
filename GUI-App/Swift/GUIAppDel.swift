//  Converted to Swift 5 by Swiftify v5.0.24084 - https://objectivec2swift.com/
import Cocoa
import ServiceManagement

@NSApplicationMain
class GUIAppDel: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!
    @IBOutlet weak var textInField: NSTextField!
    @IBOutlet weak var textOutField: NSTextField!
    @IBOutlet weak var processActivityTextField: NSTextField!
    @IBOutlet weak var blinker: NSView!
    var connection: NSXPCConnection?
    var agentProxy: Worker?
    @IBOutlet weak var enDisAbleResult: NSTextField!
    @IBOutlet weak var connectionResult: NSTextField!
    private var dateFormatter: DateFormatter?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:SS"
        self.dateFormatter = dateFormatter

        refreshActivityDisplay()
    }

    func agentBundle() -> Bundle? {
        var path = Bundle.main.bundlePath
        path = URL(fileURLWithPath: path).appendingPathComponent("Contents").absoluteString
        path = URL(fileURLWithPath: path).appendingPathComponent("Library").absoluteString
        path = URL(fileURLWithPath: path).appendingPathComponent("LoginItems").absoluteString
        path = URL(fileURLWithPath: path).appendingPathComponent("LoginItemTesterAgent.app").absoluteString
        return Bundle(path: path)
    }

    func agentBundleIdentifier() -> String? {
        return agentBundle()?.bundleIdentifier
    }

    func loginItemSwitch(on: Bool) {
        // Before actually doing it, blank the result text momentarily
        enDisAbleResult.stringValue = ""
        let mainQueue = DispatchQueue.main
        mainQueue.asyncAfter(deadline: DispatchTime.now() + Double(0.05 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            /* The following method almost always returns YES.  I don't even know
             how to make it return NO. */
            let ok = SMLoginItemSetEnabled(self.agentBundleIdentifier() as CFString?, on ? true : false)

            let message = "SMLoginItemSetEnabled(name,\(on ? "true" : "false")) returned \(ok ? "YES" : "NO")"
            self.enDisAbleResult.stringValue = message
        })
    }

    @IBAction func loginAgent(on sender: Any) {
        loginItemSwitch(on: true)
    }

    @IBAction func loginAgentOff(_ sender: Any) {
        loginItemSwitch(on: false)
    }

    @IBAction func startConnection(_ sender: Any) {
        connection = NSXPCConnection(machServiceName: agentBundleIdentifier(), options: [])
        connection.remoteObjectInterface = NSXPCInterface(with: Worker)
        connection.resume()
        connectionResult.stringValue = "Created and resumed:\n\(connection)"


        agentProxy = connection.remoteObjectProxyWithErrorHandler({ error in
            // UI access must be on main thread.
            let mainQueue = DispatchQueue.main
            mainQueue.sync(execute: {
                let errorNarrative = String(format: "Got error sending to:\n   %@\nTime: %@\n%@ Error %ld:\n%@", self.agentBundleIdentifier(), self.dateFormatter.string(from: Date()), (error as NSError?)?.domain ?? "", Int(error?.code ?? 0), error?.localizedDescription ?? "")
                self.textOutField.stringValue = errorNarrative
            })
        })
    }

    @IBAction func endConnection(_ sender: Any) {
        /* If we did invalidate the connection, then the next time the user clicked
         "Reverse that string", the new connection would fail with
         NSCocoaErrorDomain Error 4099.  This is because the old connection would
         still be connected to the disabled login item, and so the port name would
         be already in use.  Remember, XPC is a fancy wrapper around Mach ports,
         and Mach port names on the system must be unique. */
        connection.invalidate()
        connectionResult.stringValue = "Invalidated\n\(connection)"
        connection = nil
        agentProxy = nil
    }

    @IBAction func doWork(_ sender: Any) {
        let textIn = textInField.stringValue

        if agentProxy {
            agentProxy.getVersionThenDo({ version in
                let mainQueue = DispatchQueue.main
                mainQueue.sync(execute: {
                    self.textOutField.stringValue = "Waiting for Agent…"
                })
                self.agentProxy.doWork(on: textIn, thenDo: { agentProxy in
                    let versionVerdict = (version == constAgentVersion) ? "correct" : "WRONG"
                    // UI access must be on main thread.
                    let mainQueue = DispatchQueue.main
                    mainQueue.sync(execute: {
                        if let timestamp = agentProxy?.timestamp, let text = agentProxy?.text {
                            self.textOutField.stringValue = String(format: "Answer from Agent version %ld (is %@ version):\n   text: %@\n   character count: %ld\n   timestamp: %@", version, versionVerdict, text, Int(agentProxy?.characterCount ?? 0), self.dateFormatter.string(from: timestamp))
                        }
                    })
                })

            })
        } else {
            textOutField.stringValue = "No agent proxy.\nStart Connection and then try again."
        }
    }

}

