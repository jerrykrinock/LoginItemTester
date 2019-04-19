//  Converted to Swift 5 by Swiftify v5.0.24084 - https://objectivec2swift.com/
import Foundation

public class AgentProxy: NSObject, NSSecureCoding {
    var text = ""
    var characterCount: Int = 0
    var timestamp: Date?

    class var supportsSecureCoding: Bool {
        return true
    }

    func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "answer")
        coder.encode(characterCount, forKey: "characterCount")
        coder.encode(timestamp, forKey: "timestamp")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        text = aDecoder.decodeObjectOfClass(String.self, forKey: "answer") as? String ?? ""
        characterCount = aDecoder.decodeInteger(forKey: "characterCount")
        timestamp = aDecoder.decodeObjectOfClass(Date.self, forKey: "timestamp") as? Date
    }
}

