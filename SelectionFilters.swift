//
//  SelectionFilters.swift
//  OverDraft
//
//  Created by sawcleaver on 8/21/21.
//

import SwiftUI
import CoreData

func getAvailablePlayersWithLimit(allPlayers: FetchedResults<Player>, picks: FetchedResults<Pick>, limit: Int) -> [Player] {
    var count = 0
    var available = [Player]()
    
    for player in allPlayers {
        if !playerIsDrafted(player: player, picks: picks) {
            available.append(player)
            count += 1
        }
        if count > limit-1 {
            break
        }
    }
    return available
}

//this gets the top choices for the filtered positions and sorts them by the sortMethod
func getMultipleBestSelection(choices: Int, position: String, sortMethod: String, availablePlayers: [Player], teamInfo: TeamInfo, showDefAndK: Bool) -> [SimPlayer] {
    var bestSelections = [SimPlayer]()
    let baselinePoints = teamInfo.getPointsForSeason()
    var deltaPoints: Double = 0
    var lowestDeltaPoints: Double = 0
    
    var deltaVOR: Double = 0
    var lowestVOR: Double = 0
    
    //simulate points gains for all players
    for player in availablePlayers {
        if position == "ALL" || player.position!.uppercased() == position {
            if (player.position!.uppercased() != "DST" && player.position!.uppercased() != "K") || showDefAndK {
                //fill sim stuff here
                //create a copy of the teamInfo roster
                var simRoster = teamInfo.players
                //add this simulated player and create a simulated TeamInfo
                simRoster.append(player)
                let simTeam = TeamInfo(players: simRoster)
                
                //calculate the delta points, how the points for the season would change by adding this new player
                let simPoints = simTeam.getPointsForSeason()
                deltaPoints = simPoints - baselinePoints
                
                //set deltaVOR
                deltaVOR = player.valueOverReplacement
                
                //this will find and keep <choices> players with the highest simulated points for the current team
                if sortMethod == "PTS" {
                    if deltaPoints > lowestDeltaPoints || bestSelections.count < choices {
                        //If bestselections is filling up, then remove the last one
                        if bestSelections.count > choices {
                            bestSelections.removeLast()
                        }
                        let newSimPlayer = SimPlayer(player: player, simPoints: deltaPoints, simVOR: player.valueOverReplacement, listOrder: 0)
                        bestSelections.append(newSimPlayer)
                        bestSelections.sort(by: { (a,b) in
                            a.simPoints > b.simPoints
                        })
                        lowestDeltaPoints = bestSelections.last!.simPoints
                    }
                } else if sortMethod == "VOR" {
                    if deltaVOR > lowestVOR || bestSelections.count < choices {
                        if bestSelections.count > choices {
                            bestSelections.removeLast()
                        }
                        let newSimPlayer = SimPlayer(player: player, simPoints: deltaPoints, simVOR: player.valueOverReplacement, listOrder: 0)
                        bestSelections.append(newSimPlayer)
                        bestSelections.sort(by: { (a,b) in
                            a.simVOR > b.simVOR
                        })
                        lowestVOR = bestSelections.last!.simVOR
                    }
                }
            }
        }
    }
    
    //Update the orders since they are sorted
    var returnSelections = [SimPlayer]()
    var i = 1
    for selection in bestSelections {
        returnSelections.append(SimPlayer(player: selection.player, simPoints: selection.simPoints, simVOR: selection.simVOR, listOrder: i))
        i += 1
    }
    
    return returnSelections
}
