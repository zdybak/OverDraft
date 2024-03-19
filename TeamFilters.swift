//
//  TeamFilters.swift
//  OverDraft
//
//  Created by sawcleaver on 8/21/21.
//

import SwiftUI
import CoreData

func getTeamRoster(teamId: UUID, picks: FetchedResults<Pick>, players: FetchedResults<Player>) -> [Player] {
    var roster = [Player]()
    
    for pick in picks {
        if pick.teamId == teamId {
            for player in players {
                if pick.playerId == player.id {
                    roster.append(player)
                    break
                }
            }
        }
    }
    return roster
}
