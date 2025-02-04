import Foundation

class MappableObject: NSObject {
    func toMap() -> [String: Any] {
        return [:]
    }
    
    static func fromMap(_ map: [String: Any]) -> Self {
        fatalError("fromMap must be implemented by subclass")
    }
    
    func update(from map: [String: Any]) {
        fatalError("update must be implemented by subclass")
    }
} 