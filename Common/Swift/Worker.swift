//  Converted to Swift 5 by Swiftify v5.0.24084 - https://objectivec2swift.com/
import Foundation

protocol Worker: class {
    func getVersionThenDo(_ thenDo: @escaping (_ version: Int) -> Void)
    func doWork(on textIn: String?, thenDo: @escaping (_ agentProxy: AgentProxy?) -> Void)
}

