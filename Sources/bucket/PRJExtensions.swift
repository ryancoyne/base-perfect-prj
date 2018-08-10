import PerfectHTTP
import Foundation

extension String {
    /// Create new instance with random numeric/alphabetic/alphanumeric String of given length.
    ///
    /// - Parameters:
    ///   - randommWithLength:      The length of the random String to create.
    ///   - allowedCharactersType:  The allowed characters type, see enum `AllowedCharacters`.
    public init?(randomWithLength length: Int, allowedCharactersType: AllowedCharacters) {
        let allowedCharsString: String = {
            switch allowedCharactersType {
            case .numeric:
                return "0123456789"
                
            case .alphabetic:
                return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                
            case .alphaNumeric:
                return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                
            case .allCharactersIn(let allowedCharactersString):
                return allowedCharactersString
            }
        }()
        
        self.init(allowedCharsString.sample(size: length)!)
    }
    
    /// - Returns: `true` if contains any cahracters other than whitespace or newline characters, else `no`.
    public var isBlank: Bool { return stripped().isEmpty }
    
    /// - Returns: The string stripped by whitespace and newline characters from beginning and end.
    public func stripped() -> String { return trimmingCharacters(in: .whitespacesAndNewlines) }
    
    /// Returns a random character from the String.
    ///
    /// - Returns: A random character from the String or `nil` if empty.
    public var sample: Character? {
        return isEmpty ? nil : self[index(startIndex, offsetBy: Int(randomBelow: count)!)]
    }
    
    /// Returns a given number of random characters from the String.
    ///
    /// - Parameters:
    ///   - size: The number of random characters wanted.
    /// - Returns: A String with the given number of random characters or `nil` if empty.
    public func sample(size: Int) -> String? {
        guard !isEmpty else { return nil }
        
        var sampleElements = String()
        size.times { sampleElements.append(sample!) }
        
        return sampleElements
    }
}

extension String {
    /// The type of allowed characters.
    ///
    /// - Numeric:          Allow all numbers from 0 to 9.
    /// - Alphabetic:       Allow all alphabetic characters ignoring case.
    /// - AlphaNumeric:     Allow both numbers and alphabetic characters ignoring case.
    /// - AllCharactersIn:  Allow all characters appearing within the specified String.
    public enum AllowedCharacters {
        case numeric
        case alphabetic
        case alphaNumeric
        case allCharactersIn(String)
    }
    
    var intValue : Int? {
        return Int(self)
    }
}

enum BucketAPIError: Error {
    case unparceableJSON(String)
}

extension HTTPRequest {
    func postBodyJSON() throws -> [String:Any]? {
        if let json = try? self.postBodyString?.jsonDecode() as? [String:Any], json.isNotNil {
            return json
        } else if let str = self.postBodyString {
            throw BucketAPIError.unparceableJSON(str)
        } else {
            return nil
        }
    }
}

extension HTTPResponse {
    func invalidRequest(_ invalidJsonString : String) {
        return try! self
            .setBody(json: ["errorCode":"InvalidRequest", "message":"Unable to parse JSON body: \(invalidJsonString)"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .badRequest)
    }
    var emptyJSONBody : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidRequest", "message":"Empty JSON body sent."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .badRequest)
    }
}

extension Int {
    /// Initializes a new `Int ` instance with a random value below a given `Int`.
    ///
    /// - Parameters:
    ///   - randomBelow: The upper bound value to create a random value with.
    public init?(randomBelow upperLimit: Int) {
        
        guard upperLimit > 0 else { return nil }
        #if os(Linux)
        self.init(random() % upperLimit)
        #else
        self.init(arc4random_uniform(UInt32(upperLimit)))
        #endif
        
    }
    
    
    /// Runs the code passed as a closure the specified number of times.
    ///
    /// - Parameters:
    ///   - closure: The code to be run multiple times.
    public func times(_ closure: () -> Void) {
        guard self > 0 else { return }
        for _ in 0..<self { closure() }
    }
    
    /// Runs the code passed as a closure the specified number of times
    /// and creates an array from the return values.
    ///
    /// - Parameters:
    ///   - closure: The code to deliver a return value multiple times.
    public func timesMake<ReturnType>(_ closure: () -> ReturnType) -> [ReturnType] {
        guard self > 0 else { return [] }
        return (0..<self).map { _ in return closure() }
    }
}
