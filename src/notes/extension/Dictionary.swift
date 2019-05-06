//
//  Dictionary.swift
//  notes
//
//  Created by jabari on 5/4/19.
//  Copyright © 2019 jabari. All rights reserved.
//

extension Dictionary {
    var keyList: [Key] {
        var keys = [Key]()
        
        for (key, _) in self {
            keys.append(key)
        }
        
        return keys
    }
    
    var keySet: Set<Key> {
        return Set<Key>(keyList)
    }
    
    var valueList: [Value] {
        var values: [Value] = []
        
        for (_, value) in self {
            values.append(value)
        }
        
        return values
    }
    
    mutating func removValues(fromKeysIn keys: Set<Key>) {
        for key in keys {
            removeValue(forKey: key)
        }
    }
}

extension Dictionary where Value: Hashable {
    var valueSet: Set<Value> {
        var values = Set<Value>()
        
        for value in valueList {
            values.insert(value)
        }
        
        return values
    }
}
