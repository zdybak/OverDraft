//
//  RosterConfig.swift
//  OverDraft
//
//  Created by sawcleaver on 8/22/21.
//

import SwiftUI

struct RosterConfig {
    let rosterMax = ["qb" : 1, "rb" : 2, "wr" : 3, "te" : 1, "flx" : 1, "k" : 1, "dst" : 1]
    let teams = 10
    var valueMap: [String : Int]
    let positions = ["qb", "rb", "wr", "te", "k", "dst"]
    
    init() {
        valueMap = [String : Int]()
        self.valueMap = rosterMax.mapValues{ $0 * teams }
    }
}
