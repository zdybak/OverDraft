//
//  TeamView.swift
//  OverDraft
//
//  Created by sawcleaver on 8/16/21.
//

import SwiftUI

struct TeamView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Team.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Team.order, ascending: true)]) var teams: FetchedResults<Team>
    @State private var showingEditScreen = false
    
    var body: some View {
        VStack{
            HStack {
                Button(action: {
                    self.showingEditScreen.toggle()
                }) {
                    Text("Add New Team")
                    Image(systemName: "plus")
                }
                .frame(width: 200)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding(.horizontal)
                .sheet(isPresented: $showingEditScreen) {
                    TeamEditView().environment(\.managedObjectContext, self.moc)
                }
                
                Button(action: {
                    for team in teams {
                        self.moc.delete(team)
                    }
                    try? self.moc.save()
                }) {
                    Text("Remove All Teams")
                    Image(systemName: "cloud.bolt")
                }
                .frame(width: 200)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding(.horizontal)
            }
            
            List {
                HStack {
                    Text("Team Name")
                        .font(.headline)
                        .frame(width: 200, alignment: .leading)
                    Text("Draft Order")
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                }
                ForEach(teams, id: \.self) { team in
                    HStack {
                        Text(team.name ?? "Empty Team").frame(width: 200, alignment: .leading)
                        Text("\(team.order)").frame(width: 100, alignment: .leading)
                    }
                }
                .onDelete(perform: deleteTeams)
            }
        }
    }
    
    func deleteTeams(at offsets: IndexSet) {
        for offset in offsets {
            let team = teams[offset]
            
            moc.delete(team)
        }
        
        try? moc.save()
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView()
    }
}
