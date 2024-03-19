//
//  TeamStatView.swift
//  OverDraft
//
//  Created by sawcleaver on 8/21/21.
//

import SwiftUI

struct TeamStatView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Player.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Player.avgRank, ascending: true)]) var allPlayers: FetchedResults<Player>
    @FetchRequest(entity: Team.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Team.order, ascending: true)]) var teams: FetchedResults<Team>
    @FetchRequest(entity: Pick.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Pick.pick, ascending: true)]) var picks: FetchedResults<Pick>
        
    @State private var week = 1
    @State private var teamId = UUID()
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Total Points Projection By Team")
                    List {
                        let teamPower = orderedTeamPower()
                        ForEach(teamPower, id: \.0) { power in
                            HStack {
                                Text("\(power.0)")
                                let totalString = String(format: " Season Points: %.1f", power.1)
                                Text("\(totalString)")
                            }
                        }
                    }
                }
                .padding()
                .border(Color.blue, width: 1)
                
                VStack {
                    let weekString = String(format: "%02d", self.week)
                    Stepper("Check Rank For Week \(weekString)", value: $week, in: 1...16)
                        .frame(width: 300)
                    List {
                        let teamPower = orderedTeamPowerByWeek(week: self.week)
                        ForEach(teamPower, id: \.0) { power in
                            HStack {
                                Text("\(power.0)")
                                let totalString = String(format: " Points: %.1f", power.1)
                                Text("\(totalString)")
                            }
                        }
                    }
                }
                .padding()
                .border(Color.blue, width: 1)
            }
        }
    }
    
    func setTeam() -> Bool {
        for team in teams {
            if team.id == self.teamId {
                return true
            }
        }
        return false
    }
    
    func getTeamInfo(teamId: UUID) -> TeamInfo {
        let teamPlayers = getTeamRoster(teamId: teamId, picks: picks, players: allPlayers)
        let thisTeamInfo = TeamInfo(players: teamPlayers)
        return thisTeamInfo
    }
    
    //This function calculates the total points across all weeks using the best possible roster and returns
    //a sorted array of tuples with the team name and total points
    func orderedTeamPower() -> [(String, Double)] {
        var teamPower = [String : Double]()
        
        for team in teams {
            let teamName = team.name!
            let teamInfo = getTeamInfo(teamId: team.id!)
            var totalPoints: Double = 0
            
            for week in Range(1...16) {
                totalPoints += teamInfo.getPointsForWeek(week: week)
            }
            
            teamPower[teamName] = totalPoints
        }
        var sortedTeamPower = teamPower.sorted{ (a,b) -> Bool in
            return a.value > b.value
        }
        for i in Range(0...sortedTeamPower.count-1) {
            sortedTeamPower[i].key = "\(i+1). "+sortedTeamPower[i].key
        }
        return sortedTeamPower
    }
    
    func orderedTeamPowerByWeek(week: Int) -> [(String, Double)] {
        var teamPower = [String : Double]()
        
        for team in teams {
            let teamName = team.name!
            let teamInfo = getTeamInfo(teamId: team.id!)
            let weekPoints: Double = teamInfo.getPointsForWeek(week: week)
            
            teamPower[teamName] = weekPoints
        }
        var sortedTeamPower = teamPower.sorted{ (a,b) -> Bool in
            return a.value > b.value
        }
        for i in Range(0...sortedTeamPower.count-1) {
            sortedTeamPower[i].key = "\(i+1). "+sortedTeamPower[i].key
        }
        return sortedTeamPower
    }
}
