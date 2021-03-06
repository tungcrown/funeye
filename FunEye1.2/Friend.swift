//
//  firends.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

class Friend {
    private var _name: String!
    private var _id: String!
    private var _avatarUrl: String!
    private var _message: String!
    private var _username: String!
    
    var name: String {
        return _name
    }
    
    var username: String {
        return _username
    }
    
    var id: String {
        return _id
    }
    
    var avatarUrl: String {
        return _avatarUrl
    }
    
    var message: String {
        return _message
    }
    
    init(name: String, id: String, avatarUrl: String, message: String) {
        self._name = name
        self._id = id
        self._avatarUrl = avatarUrl
        self._message = message
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        if let id = dictionary["id"] as? String {
            self._id = id
        }
        
        if let name = dictionary["fullName"] as? String {
            self._name = name
        }
        
        if let avatar = dictionary["avatar"] as? String {
            self._avatarUrl = avatar
        } else {
            self._avatarUrl = "http://funeye.net:8000/img/logo-full.png"
        }
        
        if let username = dictionary["username"] as? String {
            self._username = username
        }
        
        if let provider = dictionary["provider"] as? String {
            self._message = provider
        }
    }
}