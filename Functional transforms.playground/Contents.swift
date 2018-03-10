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

let hosts = userDatabase
    .map { ($0["email"] as? String)?.components(separatedBy: "@").last }
    .filter { $0 != nil }
    .map { $0! }

var uniqueHosts = [String]()

for host in hosts {
    if !uniqueHosts.contains(host) {
        uniqueHosts.append(host)
    }
}

typealias HostInfo = (count: Int, age: Int)

func hostInfo(db: JsonArray, host: String) -> HostInfo {
    var count = 0
    var age = 0
    
    for user in db {
        if let email = user["email"] as? String,
            let userHost = email.components(separatedBy: "@").last,
            let userAge = user["age"] as? Int, userHost == host {
            count += 1
            age += userAge
        }
    }
    
    return HostInfo(count: count, age: age / count)
}

let hostsInfo = uniqueHosts.map {
    hostInfo(db: userDatabase, host: $0)
}

for i in 0..<uniqueHosts.count {
    print("Host: \(uniqueHosts[i])")
    print("  - Count: \(hostsInfo[i].count) users")
    print("  - Average age: \(hostsInfo[i].age) years old")
}
