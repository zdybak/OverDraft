//
//  FilterFunctions.swift
//  OverDraft
//
//  Created by sawcleaver on 8/20/21.
//

import SwiftUI
import CoreData

//checks player against array of picks to see if they were drafted
func playerIsDrafted(player: Player, picks: FetchedResults<Pick>) -> Bool {
    for pick in picks {
        if pick.playerId == player.id {
            return true
        }
    }
    return false
}

//getPlayerAtPick
func getPlayerAtPick(pickIndex: Int, picks: FetchedResults<Pick>, players: FetchedResults<Player>) -> Player? {
    for pick in picks {
        if pick.pick == pickIndex {
            let playerId = pick.playerId
            for player in players {
                if player.id == playerId {
                    return player
                }
            }
        }
    }
    return nil
}

//This returns the Pick element at specified index, used for retrieving specific pick for deletion or reference
func getPickAtIndex(pickIndex: Int, picks: FetchedResults<Pick>) -> Pick? {
    for pick in picks {
        if pick.pick == pickIndex {
            return pick
        }
    }
    return nil
}

//This function is used to gather players to be picked in the SelectionView Sheet
func getPlayerList(searchText: String?, limit: Int, filter: String, players: FetchedResults<Player>, picks: FetchedResults<Pick>) -> [Player] {
    var playerListArray = [Player]()
    let search = searchText ?? ""
    
    for player in players {
        if playerIsDrafted(player: player, picks: picks) {
            continue
        }
        
        if filter != "ALL" {
            if player.position!.uppercased() == filter {
                if search.count == 0 || player.playerName!.lowercased().contains(search.lowercased()) {
                    playerListArray.append(player)
                }
            }
        } else {
            if search.count == 0 || player.playerName!.lowercased().contains(search.lowercased()) {
                playerListArray.append(player)
            }
        }
        
        if playerListArray.count >= limit {
            break
        }
    }
    return playerListArray
}

//Get all players with position
func getAllPlayersWithPosition(position: String, players: FetchedResults<Player>) -> [Player] {
    var positionPlayers = [Player]()
    for player in players {
        if player.position! == position {
            positionPlayers.append(player)
        }
    }
    //make sure to sort players by points
    return positionPlayers.sorted(by: { a,b in
        a.totalPoints > b.totalPoints
    })
}

//This function returns the top 2 players sorted by VOR for the given position
//it will be used for getting VOR deltas of the best players left
func getTop2WithPosition(position: String, players: [Player]) -> [Player] {
    var top2 = [Player]()
    let vorPlayers = players.sorted(by: { a, b in
        a.valueOverReplacement > b.valueOverReplacement
    })
    var added = 0
    for player in vorPlayers {
        if player.position! == position {
            top2.append(player)
            added += 1
        }
    }
    return top2
}

func getTopWithPosition(position: String, players: [Player]) -> Player? {
    
    let vorPlayers = players.sorted(by: { a, b in
        a.valueOverReplacement > b.valueOverReplacement
    })
    for player in vorPlayers {
        if player.position! == position {
            return player
        }
    }
    return nil
}
