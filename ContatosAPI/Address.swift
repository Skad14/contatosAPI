//
//  Address.swift
//  ContatosAPI
//
//  Created by Rafael Franca on 28/09/17.
//  Copyright © 2017 Rafael Franca. All rights reserved.
//

import Foundation

struct Address: Codable {
    let city: String?
    let street: String?
    let suite: String?
    let zipcode: String?
    let geo: Geo?
}
