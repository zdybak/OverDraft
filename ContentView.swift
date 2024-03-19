//
//  ContentView.swift
//  OverDraft
//
//  Created by sawcleaver on 8/13/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
       
    var body: some View {
        TabView {
            DraftView()
                .padding()
                .tabItem {
                    Image(systemName: "pencil")
                    Text("Draft Board")
                }
            ListAllPlayers()
                .padding()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Full List")
                }
            TeamStatView()
                .padding()
                .tabItem {
                    Image(systemName: "printer")
                    Text("Team Stats")
                }
            TeamView()
                .padding()
                .tabItem {
                    Image(systemName: "building")
                    Text("Edit Teams")
                }
            LoadPlayers()
                .padding()
                .tabItem {
                    Image(systemName: "tray.and.arrow.down")
                    Text("Load Players")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
