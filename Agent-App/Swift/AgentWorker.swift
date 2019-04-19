//  Converted to Swift 5 by Swiftify v5.0.24084 - https://objectivec2swift.com/
import Cocoa


class AgentWorker: NSObject, NSXPCListenerDelegate, Worker {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let interface = NSXPCInterface(with: Worker)
        newConnection.exportedInterface = interface
        /* Next line is necessary because we pass a custom class (AgentProxy) via XPC.
         Note that, because ofReply=YES, the argumentIndex 0 is the position of
         the AgentProxy object in the *reply* block, not the position in
         the request selector -doWorkOn:thenDo: */
        interface.setClasses(Set<AnyHashable>([AgentProxy.self]), for: #selector(AgentWorker.doWork(on:thenDo:)), argumentIndex: 0, ofReply: true)
        newConnection.exportedInterface = interface
        newConnection.exportedObject = self

        // Begin accepting incoming messages
        newConnection.resume()

        return true
    }

    func getVersionThenDo(_ thenDo: @escaping (Int) -> Void) {
        thenDo(constAgentVersion)
    }

    @objc func doWork(on textIn: String?, thenDo: @escaping (AgentProxy?) -> Void) {

        guard let textIn = textIn else {
            return
        }

        // Pretend we are doing something substantial.
        Thread.sleep(forTimeInterval: 0.1)

        var answer: String
        if (textIn.lowercased() == "kill") {
            exit(97)
        } else {

            var mutant = ""
            for i in 0..<(textIn.count) {
                let aCharString = textIn[textIn.index(textIn.startIndex, offsetBy:i)]
                mutant.insert(aCharString, at: mutant.index(mutant.startIndex, offsetBy: 0))
            }
            answer = mutant
        }

        let agentProxy = AgentProxy()
        agentProxy.text = answer
        agentProxy.characterCount = answer.count
        agentProxy.timestamp = Date()
        thenDo(agentProxy)
    }
}

