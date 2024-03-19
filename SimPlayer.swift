//
//  SimPlayer.swift
//  OverDraft
//
//  Created by sawcleaver on 8/22/21.
//

import SwiftUI

struct SimPlayer : Hashable {
    var id = UUID()
    var player: Player
    var simPoints: Double
    var simVOR: Double
    var labelString: String
    var listOrder: Int
    
    init(player: Player, simPoints: Double, simVOR: Double, listOrder: Int) {
        self.player = player
        self.simPoints = simPoints
        self.simVOR = simVOR
        self.listOrder = listOrder
        let name = player.playerName!
        let pos = player.position!.uppercased()
        let tpoints = String(format: "%.1f", player.totalPoints)
        let points = String(format: "%.1f", simPoints)
        let team = player.teamName!
        let vor = String(format: "%.1f", simVOR)
        let bye = String(format: "%02d", player.byeWeek)
        let order = String(format: "%02d", listOrder)
      
        //build a label string with a an exact length of characters
        //TODO fix this so it's better, also it might crash if a name is larger than 30 chars etc
        var labelBuilder = "\(order)." + String(repeating: " ", count: 4 - order.count+1)
        labelBuilder += name + String(repeating: " ", count: 30 - name.count)
        labelBuilder += pos + String(repeating: " ", count: 3 - pos.count)
        labelBuilder += "VOR: \(vor) " + String(repeating: " ", count: 12 - vor.count)
        labelBuilder += "TPS: \(tpoints) " + String(repeating: " ", count: 12 - tpoints.count)
        labelBuilder += "SPT: \(points) " + String(repeating: " ", count: 12 - points.count)
        labelBuilder += "BYE: \(bye) " + String(repeating: " ", count: 12 - bye.count)
        labelBuilder += team
        self.labelString = labelBuilder
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
