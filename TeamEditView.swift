//
//  TeamEditView.swift
//  OverDraft
//
//  Created by sawcleaver on 8/16/21.
//

import SwiftUI

struct TeamEditView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: Team.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Team.order, ascending: true)]) var teams: FetchedResults<Team>
    
    @State private var name = ""
    @State private var order = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name of Team", text: $name)
                    
                    Picker("Draft Order", selection: $order) {
                        ForEach((1..<11), id: \.self) { id in
                            if orderIsAvailable(id) {
                                Text("\(id)")
                            }
                        }
                    }
                }
                
                Section {
                    Button("Save") {
                        if self.name.count < 3 || self.order < 1 || self.order > 10 {
                            return
                        }
                        
                        let newTeam = Team(context: self.moc)
                        newTeam.id = UUID()
                        newTeam.name = self.name
                        newTeam.order = Int16(self.order)
                        
                        try? self.moc.save()
                        
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitle("Add Team")
        }
    }
    
    func orderIsAvailable(_ order: Int) -> Bool {
        for team in teams {
            if team.order == Int16(order) {
                return false
            }
        }
        return true
    }
}

struct TeamEditView_Previews: PreviewProvider {
    static var previews: some View {
        TeamEditView()
    }
}
