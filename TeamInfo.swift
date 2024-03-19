//
//  AssistanceAlgorithms.swift
//  OverDraft
//
//  Created by sawcleaver on 8/20/21.
//

import SwiftUI
import CoreData

struct TeamInfo {
    var players = [Player]()
    var qbs = [Player]()
    var rbs = [Player]()
    var wrs = [Player]()
    var tes = [Player]()
    var ks = [Player]()
    var ds = [Player]()
    private var rosterConfig = RosterConfig()
    
    init(players: [Player]){
        self.players = players
        
        for player in players {
            switch player.position {
            case "qb":
                self.qbs.append(player)
                break
            case "rb":
                self.rbs.append(player)
                break
            case "wr":
                self.wrs.append(player)
                break
            case "te":
                self.tes.append(player)
                break
            case "k":
                self.ks.append(player)
                break
            case "dst":
                self.ds.append(player)
                break
            default:
                break
            }
        }
    }
    
    func getBestRosterForWeek(week: Int) -> [Player]{
        let i = week-1
        var bestRoster = [Player]()
        //check for invalid week
        if !isValidWeek(week: week) {
            return bestRoster
        }
        
       //copy player into var
        let sortedPlayers = self.players.sorted(by: { getWeeklyPoints(player: $0)[i] > getWeeklyPoints(player: $1)[i] })
        var rosterCount = ["qb" : 0, "rb" : 0, "wr" : 0, "te" : 0, "flx" : 0, "k" : 0, "dst" : 0]
        let rosterMax = rosterConfig.rosterMax
        
        for player in sortedPlayers {
            let pos = player.position!
            let count = rosterCount[pos] ?? 0
            let max = rosterMax[pos] ?? 0
            if count < max {
                bestRoster.append(player)
                rosterCount[pos] = count+1
            } else if rosterCount["flx"]! < rosterMax["flx"]! && isFlex(position: pos) {
                //check for flex
                bestRoster.append(player)
                rosterCount["flx"] = rosterCount["flx"]!+1
            }
        }
        return bestRoster
    }
    
    func isFlex(position: String) -> Bool {
        if position == "rb" || position == "wr" || position == "te" {
            return true
        }
        return false
    }
    
    func isValidWeek(week: Int) -> Bool {
        if week < 1 || week > 16 {
            return false
        }
        return true
    }
    
    //Check to see how many points a player will add to a team
    func getPointsForWeek(week: Int) -> Double {
        var pointsForWeek: Double = 0
                
        if !isValidWeek(week: week) {
            return 0
        }
        
        let weekIndex = week - 1
        //Get the best current roster on this team for the week's points
        let bestRoster = getBestRosterForWeek(week: week)
        
        for player in bestRoster {
            pointsForWeek += getWeeklyPoints(player: player)[weekIndex]
        }
        
        return pointsForWeek
    }
    
    //Get points for all weeks
    func getPointsForSeason() -> Double {
        var pointsForSeason: Double = 0
        
        for week in Range(1...16) {
            let weekIndex = week - 1
            let bestRoster = getBestRosterForWeek(week: week)
            
            for player in bestRoster {
                pointsForSeason += getWeeklyPoints(player: player)[weekIndex]
            }
        }
        return pointsForSeason
    }
    
    //Checks to see how many players of position are drafted
    func numberOfPlayerTypesNeeded(position: String) -> Int {
        switch position {
        case "qb":
            return rosterConfig.rosterMax["qb"]! - qbs.count
        case "rb":
            return rosterConfig.rosterMax["rb"]!+rosterConfig.rosterMax["flx"]! - rbs.count
        case "wr":
            return rosterConfig.rosterMax["wr"]! - wrs.count
        case "te":
            return rosterConfig.rosterMax["te"]! - tes.count
        case "k":
            return rosterConfig.rosterMax["k"]! - ks.count
        case "dst":
            return rosterConfig.rosterMax["dst"]! - ds.count
        default:
            return 0
        }
    }
    
    //Checks to see how many players of position are drafted
    func numberOfPlayerTypes(position: String) -> Int {
        switch position {
        case "qb":
            return qbs.count
        case "rb":
            return rbs.count
        case "wr":
            return wrs.count
        case "te":
            return tes.count
        case "k":
            return ks.count
        case "dst":
            return ds.count
        default:
            return 0
        }
    }
    
    //returns a status string showing roster slot coverage
    func rosterCovered() -> String {
        var rosterString = ""
        for pos in rosterConfig.positions {
            rosterString += "\t"+pos.uppercased()+": "+String(numberOfPlayerTypes(position: pos))
        }
        return rosterString
    }
    
    //returns a status string showing uncovered bye weeks for mandatory roster slots
    func byesCovered() -> String {
        var byeWeeks = [String]()
        var message = ""
        
        for qb in qbs {
            let thisWeek = "\(qb.byeWeek)"
            if !byeWeeks.contains(thisWeek) {
                byeWeeks.append(thisWeek)
            }
        }
        if byeWeeks.count <= rosterConfig.rosterMax["qb"]! {
            byeWeeks.sort(by: { a,b in
                Int(a)! > Int(b)!
            })
            message += "\tQB: " + byeWeeks.joined(separator: ", ")
        }
        byeWeeks.removeAll()
        
        for rb in rbs {
            let thisWeek = "\(rb.byeWeek)"
            if !byeWeeks.contains(thisWeek) {
                byeWeeks.append(thisWeek)
            }
        }
        if byeWeeks.count <= rosterConfig.rosterMax["rb"]! {
            byeWeeks.sort(by: { a,b in
                Int(a)! > Int(b)!
            })
            message += "\tRB: " + byeWeeks.joined(separator: ", ")
        }
        byeWeeks.removeAll()
        
        for wr in wrs {
            let thisWeek = "\(wr.byeWeek)"
            if !byeWeeks.contains(thisWeek) {
                byeWeeks.append(thisWeek)
            }
        }
        if byeWeeks.count <= rosterConfig.rosterMax["wr"]! {
            byeWeeks.sort(by: { a,b in
                Int(a)! > Int(b)!
            })
            message += "\tWR: " + byeWeeks.joined(separator: ", ")
        }
        byeWeeks.removeAll()
        
        for te in tes {
            let thisWeek = "\(te.byeWeek)"
            if !byeWeeks.contains(thisWeek) {
                byeWeeks.append(thisWeek)
            }
        }
        if byeWeeks.count <= rosterConfig.rosterMax["te"]! {
            byeWeeks.sort(by: { a,b in
                Int(a)! > Int(b)!
            })
            message += "\tTE: " + byeWeeks.joined(separator: ", ")
        }
        
        return message
    }
}
