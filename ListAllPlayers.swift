//
//  ListAllPlayers.swift
//  OverDraft
//
//  Created by sawcleaver on 8/14/21.
//

import SwiftUI

struct ListAllPlayers: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Player.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Player.avgRank, ascending: true)]) var players: FetchedResults<Player>
    @State private var searchText = ""
    private var positions = ["ALL","RB","WR","QB","TE","DST","K"]
    @State private var positionSelected = 0
    
    var body: some View {
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
            Picker("Player Type", selection: $positionSelected) {
                ForEach(0..<positions.count) {
                    Text("\(self.positions[$0])")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            List {
                HStack{
                    Text("Rank").frame(width: 100)
                    Text("Name").frame(width: 200)
                    Text("Position").frame(width: 100)
                    Text("Team").frame(width: 100)
                    Text("Bye Week").frame(width: 100)
                    Text("Points").frame(width: 100)
                    Text("VOR").frame(width: 100)
                }
                if players.count > 0 {
                    ForEach(players, id: \.id) { player in
                        if positions[positionSelected] != "ALL" && player.position!.uppercased() != positions[positionSelected] {
                            //do not display players that don't match position
                        } else if searchText.count > 0 && !player.playerName!.lowercased().contains(searchText.lowercased()) {
                            //do not display players that don't match search
                        } else {
                            HStack {
                                Text("\(player.avgRank, specifier: "%.2f")").frame(width: 100)
                                Text(player.playerName!).frame(width: 200, alignment: .leading)
                                Text(player.position!.uppercased()).frame(width: 100)
                                Text(player.teamName!).frame(width: 100)
                                Text("\(player.byeWeek)").frame(width: 100)
                                Text("\(player.totalPoints, specifier: "%.1f")").frame(width: 100)
                                Text("\(player.valueOverReplacement, specifier: "%.1f")").frame(width: 100)
                                
                                //open browser to search player status
                                let playerComponents = player.playerName!.components(separatedBy: " ")
                                if playerComponents.count > 1 {
                                    let searchString: String = "https://www.espn.com/nfl/players?search=\(playerComponents[1])"
                                    Link("Check Status", destination: URL(string: searchString)!)
                                        .foregroundColor(Color.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ListAllPlayers_Previews: PreviewProvider {
    static var previews: some View {
        ListAllPlayers()
    }
}
