//
//  Asset.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 26/01/26.
//

import Foundation

struct Asset: Codable, Identifiable, Sendable {
    var id: UUID
    var name: String
    var type: String
    var institution: String
    var latestValue: Double
    
    init(id: UUID = UUID(), name: String, type: String, institution: String, latestValue: Double) {
        self.id = id
        self.name = name
        self.type = type
        self.institution = institution
        self.latestValue = latestValue
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, institution
        case latestValue = "latest_value"
    }
}
