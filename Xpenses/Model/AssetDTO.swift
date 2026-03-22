//
//  AssetDTO.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 09/02/26.
//

import Foundation

struct AssetDTO: Codable {
    var id: UUID
    var name: String
    var type: String
    var institution: String
}
