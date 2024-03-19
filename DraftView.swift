//
//  DraftView.swift
//  OverDraft
//
//  Created by sawcleaver on 8/15/21.
//

import SwiftUI

struct SelectedBox : Identifiable {
    var id: String { String(pickIndex) }
    var pickIndex: Int
    var teamId: UUID

    init(pickIndex: Int, teamId: UUID) {
        self.pickIndex = pickIndex
        self.teamId = teamId
    }
}

struct DraftView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Player.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Player.avgRank, ascending: true)]) var allPlayers: FetchedResults<Player>
    @FetchRequest(entity: Team.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Team.order, ascending: true)]) var teams: FetchedResults<Team>
    @FetchRequest(entity: Pick.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Pick.pick, ascending: true)]) var picks: FetchedResults<Pick>
    
    private var rounds = 20
    
    @State private var selectedBox: SelectedBox?
    @State private var showingSelection = false
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    ForEach(teams, id: \.self) { team in
                        Text(team.name ?? "No Team")
                            .font(.caption)
                            .frame(width: 90, height: 50)
                            .padding(2)
                    }
                }
                
                ForEach((0..<rounds), id: \.self) { rounds in
                    if rounds+1 == 11 {
                        HStack {
                            ForEach(teams, id: \.self) { team in
                                Text(team.name ?? "No Team")
                                    .font(.caption)
                                    .frame(width: 90, height: 50)
                                    .padding(2)
                            }
                        }
                    }
                    
                    HStack {
                        Text("\(rounds+1)")
                            .padding(2)
                        ForEach(teams, id: \.self) { team in
                            let totalTeams = numTeams()
                            let index: Int = (rounds * totalTeams) + Int(team.order) - 1
                            let unwrappedTeamId = team.id!
                            
                            let boxPlayer = getPlayerAtPick(pickIndex: index, picks: picks, players: allPlayers)
                            DraftBoxView(player: boxPlayer, pickIndex: index, teamId: unwrappedTeamId)
                                .onTapGesture {
                                    updateSelection(pickIndex: index, teamId: unwrappedTeamId)
                                }
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .sheet(item: $selectedBox) { selectedBox in
            SelectionView(pickIndex: selectedBox.pickIndex, teamId: selectedBox.teamId)
                .environment(\.managedObjectContext, moc)
        }
    }
    
    func numTeams() -> Int {
        return self.teams.count
    }
    
    func updateSelection(pickIndex: Int, teamId: UUID){
        self.selectedBox = SelectedBox(pickIndex: pickIndex, teamId: teamId)
    }
}

