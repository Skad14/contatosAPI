//
//  User.swift
//  ContatosAPI
//
//  Created by Rafael Franca on 28/09/17.
//  Copyright © 2017 Rafael Franca. All rights reserved.
//

import Foundation

struct Contacts: Codable {
    let id: Int
    let name: String?
    let phone: String?
    let username: String?
    let email: String?
    let website: String?
    let company: Company?
    let address: Address?
}
