//  Converted to Swift 5 by Swiftify v5.0.24084 - https://objectivec2swift.com/
import Cocoa

@NSApplicationMain
class AgentAppDel: NSObject, NSApplicationDelegate {
    //@property (weak) IBOutlet NSWindow *window;
    private var xpcListener: NSXPCListener?
    private var agentWorker: AgentWorker?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /* LaunchServices automatically registers a mach service of the same
         name as our bundle identifier.  So, we create a listener to that same
         identifier. */
        let bundleId = Bundle.main.bundleIdentifier
        let xpcListener = NSXPCListener(machServiceName: bundleId ?? "")
        self.xpcListener = xpcListener

        // Our xpc listener will delegate received jobs to its delegate.
        let agentWorker = AgentWorker()
        self.agentWorker = agentWorker
        xpcListener.delegate = agentWorker

        /* Depending on how an XPC listener is configured, the following method
         may or may not ever return.  With our configuration, this method *does*
         return. */
        xpcListener.resume()
    }

    /*!
     @details  This method does *not* run when the GUI app calls
     SMLoginItemEnable(NO), presumably because that call kills its process with a
     rude signal of some kind. */
    func applicationWillTerminate(_ notification: Notification) {
        // Do not put any code here because it will never run.
    }
}

