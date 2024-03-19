//
//  LoadPlayers.swift
//  OverDraft
//
//  Created by sawcleaver on 8/13/21.
//

import SwiftUI
import CoreData

struct PlayerResponse: Decodable {
    var playerName: String
    var teamName: String
    var position: String
    var byeWeek: Int
    var week1points: Double?
    var week1rank: Double?
    var week2points: Double?
    var week2rank: Double?
    var week3points: Double?
    var week3rank: Double?
    var week4points: Double?
    var week4rank: Double?
    var week5points: Double?
    var week5rank: Double?
    var week6points: Double?
    var week6rank: Double?
    var week7points: Double?
    var week7rank: Double?
    var week8points: Double?
    var week8rank: Double?
    var week9points: Double?
    var week9rank: Double?
    var week10points: Double?
    var week10rank: Double?
    var week11points: Double?
    var week11rank: Double?
    var week12points: Double?
    var week12rank: Double?
    var week13points: Double?
    var week13rank: Double?
    var week14points: Double?
    var week14rank: Double?
    var week15points: Double?
    var week15rank: Double?
    var week16points: Double?
    var week16rank: Double?
    var avgRank: Double
    var totalPoints: Double
        
}


struct LoadPlayers: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Player.entity(), sortDescriptors: []) var players: FetchedResults<Player>
    @FetchRequest(entity: Pick.entity(), sortDescriptors: []) var picks: FetchedResults<Pick>
    
    @State private var playersLoaded = false
    @State private var urlString = "https://zdybak.com/football/2021-09-03players.json"
    @State private var userMessage = ""
                        
    var body: some View {
        VStack{
            
            Form {
                TextField("Enter URL to download JSON data: ", text: $urlString)
            }
            .frame(height: 200)
            
            HStack {
                Button("Clear All Draft Picks") {
                    if picks.count > 0 {
                        clearDraftPicks()
                        self.userMessage = "Draft Picks Cleared!"
                    } else {
                        self.userMessage = "No draft picks to clear"
                    }
                }
                .frame(width: 250, height: 100)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Capsule())
                
                
                Button("Load Player Data From Server") {
                    let json = getPlayerJSON(url: urlString)
                    if json != nil {
                        let jsonPlayers = decodePlayers(json!)
                        if(jsonPlayers.count > 0) {
                            clearPlayerData()
                            clearDraftPicks()
                            refreshPlayerData(jsonPlayers)
                            updateValueOverReplacement()
                            playersLoaded.toggle()
                            self.userMessage = "Players Loaded Successfully"
                        }
                    }
                }
                .frame(width: 250, height: 100)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                
            }
            .padding()
            
            Text(self.userMessage)
        }
    }
    
    func getPlayerJSON(url: String) -> Data? {
        if let url = URL(string: url) {
            do {
                let contents = try String(contentsOf: url)
                let json = contents.data(using: .utf8)
                return json
            } catch {
                self.userMessage = "Error Loading from URL, please check to ensure the URL is correct"
            }
        }
        return nil
    }
    
    //todo: make decodePlayers return a PlayerResponse Array, then load it into core data.
    func decodePlayers(_ jsondata: Data) -> [PlayerResponse] {
        do {
            let players = try JSONDecoder().decode([PlayerResponse].self, from: jsondata)
            return players
        } catch {
            self.userMessage = "Error decoding JSON: \(error.localizedDescription)"
        }
        return [PlayerResponse]()
    }
    
    func refreshPlayerData(_ jsonPlayers: [PlayerResponse]) {
        for player in jsonPlayers {
            let newPlayer = Player(context: self.moc)
            newPlayer.id = UUID()
            newPlayer.playerName = player.playerName
            newPlayer.teamName = player.teamName
            newPlayer.position = player.position
            newPlayer.byeWeek = Int16(player.byeWeek)
            newPlayer.avgRank = player.avgRank
            newPlayer.totalPoints = player.totalPoints
            newPlayer.week1points = player.week1points ?? 0.0
            newPlayer.week2points = player.week2points ?? 0.0
            newPlayer.week3points = player.week3points ?? 0.0
            newPlayer.week4points = player.week4points ?? 0.0
            newPlayer.week5points = player.week5points ?? 0.0
            newPlayer.week6points = player.week6points ?? 0.0
            newPlayer.week7points = player.week7points ?? 0.0
            newPlayer.week8points = player.week8points ?? 0.0
            newPlayer.week9points = player.week9points ?? 0.0
            newPlayer.week10points = player.week10points ?? 0.0
            newPlayer.week11points = player.week11points ?? 0.0
            newPlayer.week12points = player.week12points ?? 0.0
            newPlayer.week13points = player.week13points ?? 0.0
            newPlayer.week14points = player.week14points ?? 0.0
            newPlayer.week15points = player.week15points ?? 0.0
            newPlayer.week16points = player.week16points ?? 0.0
            newPlayer.valueOverReplacement = 0.0
        }
        
        do {
            try self.moc.save()
        } catch {
            self.userMessage = "Failed to save json players to core data: \(error.localizedDescription)"
        }
    }
    
    func clearDraftPicks() {
        for pick in picks {
            self.moc.delete(pick)
        }
        do {
            try self.moc.save()
        } catch {
            self.userMessage = "Failed to delete picks"
        }
    }
    
    func clearPlayerData() {
        for player in players {
            self.moc.delete(player)
        }
        do {
            try self.moc.save()
        } catch {
            self.userMessage = "Failed to save after deleting all players"
        }
    }
    
    func updateValueOverReplacement() {
        let rosterConfig = RosterConfig()
        
        for pos in rosterConfig.positions {
            let valuePlayers = getAllPlayersWithPosition(position: pos, players: players)
            
            //Modifer the VOR calculations
            let flexMod = pos == "rb" ? 1*rosterConfig.teams : 0
            let baseline = rosterConfig.valueMap[pos]!+flexMod
            print("Calculating VOR for \(pos) with baseline \(baseline)")
            let baselinePlayer = valuePlayers[baseline]
            print ("Baseline Player is: \(baselinePlayer.playerName ?? "No player")")
            for player in valuePlayers {
                player.valueOverReplacement = player.totalPoints - baselinePlayer.totalPoints
            }
        }
        
        do {
            try self.moc.save()
        } catch {
            self.userMessage = "Failed to save after updating VOR"
        }
    }
}

struct LoadPlayers_Previews: PreviewProvider {
    static var previews: some View {
        LoadPlayers()
    }
}
