//: Playground - Functional transforms

import Foundation

public typealias JsonObject = [String: AnyObject]
public typealias JsonArray = [JsonObject]

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

var userDatabase = JsonArray()

for db in databases {
    userDatabase.append(contentsOf: db)
}

func getHost(user: JsonObject) -> String? {
    return (user["email"] as? String)?.components(separatedBy: "@").last
}

let hosts = userDatabase
    .map (getHost)
    .filter { $0 != nil }
    .map { $0! }
    .reduce([]) { accumulator, host in
        accumulator.contains(host) ? accumulator : accumulator + [host] }

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

for i in 0..<hosts.count {
    print("Host: \(hosts[i])")
    print("  - Count: \(hostsInfo[i].count) users")
    print("  - Average age: \(hostsInfo[i].age) years old")
}
