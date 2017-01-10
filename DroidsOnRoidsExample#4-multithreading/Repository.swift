//
//  Repository.swift
//  DroidsOnRoidsExample#4-multithreading
//
//  Created by Patrick Bellot on 1/9/17.
//  Copyright © 2017 Bell OS, LLC. All rights reserved.
//

import ObjectMapper

class Repository: Mappable {
	var identifier: Int!
	var language: String!
	var url: String!
	var name: String!
	
	required init?(map: Map) {}
	
	func mapping(map: Map) {
		identifier <- map["id"]
		language <- map["language"]
		url <- map["url"]
		name <- map["name"]
	}
}
