//
//  SelectionView.swift
//  OverDraft
//
//  Created by sawcleaver on 8/18/21.
//

import SwiftUI

struct SelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Player.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Player.avgRank, ascending: true)]) var players: FetchedResults<Player>
    @FetchRequest(entity: Pick.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Pick.pick, ascending: true)]) var picks: FetchedResults<Pick>
    @FetchRequest(entity: Team.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Team.order, ascending: true)]) var teams: FetchedResults<Team>
    
    private var pickIndex: Int
    private var teamId: UUID
               
    private var positions = ["ALL","RB","WR","QB","TE","DST","K"]
    
    @State private var positionSelected = UserDefaults.standard.integer(forKey: "positionFilter")
    @State private var searchText = ""
    
    private var sortMethods = ["VOR","PTS"]
    @State private var sortSelected = UserDefaults.standard.integer(forKey: "sortFilter")
    
    @State private var defAndKickerShowing = UserDefaults.standard.bool(forKey: "defFilter")
    
    var body: some View {
        VStack {
            //Info
            Text("This is the selection for pick: \(pickIndex+1) for \(getTeamName())")
            //If there is an existing pick we don't show these
            if selectionExists() == false {
                //Selectable player filters and list
                Picker("Player Type", selection: $positionSelected) {
                    ForEach(0..<positions.count) {
                        Text("\(self.positions[$0])")
                    }
                }
                .onChange(of: positionSelected, perform: { value in
                    UserDefaults.standard.set(positionSelected, forKey: "positionFilter")
                })
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                HStack {
                    Picker("Sort Method", selection: $sortSelected) {
                        ForEach(0..<sortMethods.count) {
                            Text("\(self.sortMethods[$0])")
                        }
                    }
                    .onChange(of: sortSelected, perform: { value in
                        UserDefaults.standard.set(sortSelected, forKey: "sortFilter")
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Toggle("Show DST/K", isOn: $defAndKickerShowing)
                        .onChange(of: defAndKickerShowing, perform: { value in
                            UserDefaults.standard.set(defAndKickerShowing, forKey: "defFilter")
                        })
                }
                
                //Show general top 5 based on position filter
                //let listPlayers: [Player] = getPlayerList(searchText: nil, limit: 5, filter: positions[positionSelected], players: players, picks: picks)
                let currentTeamRoster = getTeamRoster(teamId: self.teamId, picks: picks, players: players)
                let currentTeamInfo = TeamInfo(players: currentTeamRoster)
                let playersLeft = getAvailablePlayersWithLimit(allPlayers: players, picks: picks, limit: 600)
                let listPlayers: [SimPlayer] = getMultipleBestSelection(choices: 20, position: positions[positionSelected], sortMethod: sortMethods[sortSelected], availablePlayers: playersLeft, teamInfo: currentTeamInfo, showDefAndK: defAndKickerShowing)
        
                List {
                    ForEach(listPlayers, id: \.self) { simPlayer in
                        let label = simPlayer.labelString
                        
                        Button(action: {
                            let newPick = Pick(context: moc)
                            newPick.playerId = simPlayer.player.id
                            newPick.teamId = self.teamId
                            newPick.pick = Int32(self.pickIndex)
                            
                            do {
                                try moc.save()
                            } catch {
                                print("Failed to save new pick \(error.localizedDescription)")
                            }
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text(label).tracking(2)
                        })
                    }
                }
                .id(UUID())
                .border(Color.blue, width: 1)
                
                //Show tips about the current selecting team
                VStack {
                    Text("Team Info").font(.title)
                    let rosterCovered = currentTeamInfo.rosterCovered()
                    HStack {
                        Text("Roster Coverage").bold()
                        Text(rosterCovered)
                    }
                    
                    let byesNotCovered = currentTeamInfo.byesCovered()
                    HStack {
                        Text("Uncovered Byes").bold()
                        Text(byesNotCovered)
                    }
                }
                                
                //Manual search
                VStack {
                    HStack {
                        TextField("Search for a player: ", text: $searchText)
                            .frame(width: 300)
                            .disableAutocorrection(true)
                        Button("Clear Search") {
                            self.searchText = ""
                        }
                        .frame(width: 200)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .padding()
                    if searchText != "" {
                        let searchPlayers: [Player] = getPlayerList(searchText: searchText, limit: 3, filter: positions[positionSelected], players: players, picks: picks)
                        List {
                            ForEach(searchPlayers, id: \.self) { player in
                                let label = getPlayerLabelString(player: player, addition: "")
                                
                                Button(label) {
                                    let newPick = Pick(context: moc)
                                    newPick.playerId = player.id
                                    newPick.teamId = self.teamId
                                    newPick.pick = Int32(self.pickIndex)
                                    
                                    try? moc.save()
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
            } else {
                //Show some detailed info about selected player
                let chosenPlayer = getSelectedPlayer()
                VStack {
                    Text(chosenPlayer.playerName!)
                        .font(.largeTitle)
                        .padding()
                    Text(chosenPlayer.position!.uppercased())
                        .font(.title)
                        .padding()
                    Text(chosenPlayer.teamName!)
                        .font(.title)
                        .padding()
                    Text("Bye Week \(chosenPlayer.byeWeek)")
                        .font(.title)
                        .padding()
                    let pointString = String(format: "%.1f", chosenPlayer.totalPoints)
                    Text("Total Points \(pointString)")
                        .font(.title)
                        .padding()
                    let vorString = String(format: "%.1f", chosenPlayer.valueOverReplacement)
                    Text("VOR \(vorString)")
                        .font(.title)
                        .padding()
                    Spacer()
                    
                    //Option to clear selection
                    Button("Clear This Pick") {
                        guard let thisPick = getPickAtIndex(pickIndex: self.pickIndex, picks: picks) else {
                            print("Unable to find this pick for index: \(pickIndex)")
                            return
                        }
                        moc.delete(thisPick)
                        try? moc.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(width: 150, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
            Spacer()
            //Controls to end
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .frame(width: 150, height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .padding()
    }
    
    init(pickIndex: Int, teamId: UUID) {
        self.pickIndex = pickIndex
        self.teamId = teamId
    }
    
    func getTeamName() -> String {
        for team in teams {
            if team.id == self.teamId {
                return team.name ?? "team"
            }
        }
        return "team"
    }
    
    func selectionExists() -> Bool {
        for pick in picks {
            if pick.pick == self.pickIndex {
                return true
            }
        }
        return false
    }
    
    func getSelectedPlayer() -> Player {
        let thisPlayer = getPlayerAtPick(pickIndex: self.pickIndex, picks: picks, players: players)
        return thisPlayer!
    }
}


