//
//  DraftBoxView.swift
//  OverDraft
//
//  Created by sawcleaver on 8/15/21.
//

import SwiftUI

struct DraftBoxView: View {
    private var player: Player?
    private var pickIndex: Int
    private var teamId: UUID
    private var positionColors = ["qb" : Color.gray, "rb" : Color.red, "wr" : Color.blue, "te" : Color.green, "k" : Color.purple, "dst" : Color.orange]
        
    var body: some View {
        
        Text(playerInfo())
            .frame(width: 90, height: 50)
            .background(playerColor())
            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            .padding(2)
    }
    
    init(player: Player?, pickIndex: Int, teamId: UUID) {
        self.player = player ?? nil
        self.pickIndex = pickIndex
        self.teamId = teamId
    }
    
    func playerInfo() -> String {
        if player != nil {
            return player!.playerName!+"\n"+player!.position!.uppercased()+"\t"+player!.teamName!
        } else {
            return ""
        }
    }
    
    func playerColor() -> Color {
        guard let player = self.player else {
            return Color.white
        }
        return positionColors[player.position!] ?? Color.white
    }
}

/*
struct DraftBoxView_Previews: PreviewProvider {
    static var previews: some View {
        DraftBoxView()
    }
}*/
