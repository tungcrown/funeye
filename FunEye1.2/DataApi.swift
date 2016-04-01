//
//  DataApi.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/25/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import Foundation

let ACCESS_TOKEN_KEY = "ACCESS_TOKEN"
var ACCESS_TOKEN :String!
let URL_MAIN_DOMAIN = "http://funeye.net:8000"

let URL_LOGIN_FACEBOOK = URL_MAIN_DOMAIN + "/oauth/fbmobile"
let URL_GET_NEW_FEED = URL_MAIN_DOMAIN + "/api/articles?page=1&sort=create&access_token=\(ACCESS_TOKEN)"
let URL_GET_FRIEND_FOLLOW = URL_MAIN_DOMAIN + "/api/suggestfriends?access_token=\(ACCESS_TOKEN)"

func createUrlCallComment(post_id: String) -> String{
    return URL_MAIN_DOMAIN + "/api/articles/\(post_id)/comments?access_token=\(ACCESS_TOKEN)"
}