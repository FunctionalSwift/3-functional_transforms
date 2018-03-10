//: Playground - Functional transforms

import Foundation

public typealias JsonObject = [String: AnyObject]
public typealias JsonArray = [JsonObject]

public extension Array where Element: Hashable {
    func unique() -> [Element] {
        return self.reduce([Element]()) { accumulator, element in
            accumulator.contains(element) ? accumulator : accumulator + [element]
        }
    }
}

func json(path: String) -> JsonArray {
    guard
        let path = Bundle.main.path(forResource: path, ofType: "json"),
        let jsonData = NSData(contentsOfFile: path),
        let jsonResult = try! JSONSerialization.jsonObject(with: jsonData as Data) as? NSArray
        else {
            return JsonArray()
    }
    
    return jsonResult.flatMap { $0 as? JsonObject }
}

var databases: [JsonArray] {
    return [
        json(path: "Database1"),
        json(path: "Database2"),
        json(path: "Database3")
    ]
}

let userDatabase = databases.flatMap{$0}

func getHost(user: JsonObject) -> String? {
    return (user["email"] as? String)?.components(separatedBy: "@").last
}

let hosts = userDatabase
    .flatMap (getHost)
    .unique()

typealias HostInfo = (count: Int, age: Int)

func hostInfo(database: JsonArray) -> (String) -> HostInfo {
    return { host in
        let result = database.reduce(HostInfo(count: 0, age: 0)) { accumulator, user in
            guard
                let userHost = getHost(user: user),
                let age = user["age"] as? Int, userHost == host else {
                    return accumulator
            }
            
            return (accumulator.count + 1, accumulator.age + age)
            
        }
        
        return HostInfo(count: result.count, age: result.age / result.count)
    }
}

let hostsInfo = hosts.map(hostInfo(database: userDatabase))

let result = zip(hosts, hostsInfo)

for (host, info) in result {
    print("Host: \(host)")
    print("  - Count: \(info.count) users")
    print("  - Average age: \(info.age) years old")
}
