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

print(databases)

var userDatabase = JsonArray()

for db in databases {
    userDatabase.append(contentsOf: db)
}

var hosts = [String]()

for user in userDatabase {
    if let email = user["email"] as? String,
        let host = email.components(separatedBy: "@").last,
        !hosts.contains(host) {
        
        hosts.append(host)
    }
}

func hostInfo(db: JsonArray, host: String) -> (Int, Int) {
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
    
    return (count, age / count)
}
