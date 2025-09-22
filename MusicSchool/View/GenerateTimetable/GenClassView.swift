//
//  GenClassView.swift
//  MusicSchool
//
//  Created by Jeremy Lo on 11/8/25.
//

import SwiftUI

struct GenClassView: View {
    @EnvironmentObject var viewModel: GenViewModel
    @State private var classes: [String] = []
    @State private var anyClass: Bool = false
    @State private var showConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Classes")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                if anyClass {
                    List {
                        ForEach(classes, id: \.self) { className in
                            // Update values
                            let parts = className.split(separator: ":")
                            let displayName = "\(String(parts[0]))h \(String(parts[1]))min"
                            NavigationLink(destination: AddClassView(classID: className)) {
                                Text(displayName)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                } else {
                    NavigationLink (destination: AddClassView(classID: "")) {
                        Image(systemName: "plus.app.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .padding()
                    }
                }
            }
        }
        
        // MARK: - Toolbar
        .toolbar {
            NavigationLink(destination: AddClassView(classID: "")) {
                Image(systemName: "plus.app")
            }
            
            Button {
                showConfirmation = true
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
        }
        
        
        // MARK: - Others
        .onAppear {
            viewModel.printList()   // TODO: Remove this
            classes = viewModel.fetchClassList()
            if classes.count == 0 {
                anyClass = false
            } else {
                anyClass = true
            }
        }
        
        .alert("Are you sure?" ,isPresented: $showConfirmation) {
            Button("Yes") {
                viewModel.resetClassList()
                anyClass = false
            }
            Button("No") {
                
            }
        } message: {
            Text("This operation cannot be undone.")
        }
    }
    
    
    // Function for Deleting Classes
    func delete(at offsets: IndexSet) {
        // Remove from Global List
        for index in offsets {
            let duration = classes[index]
            viewModel.deleteClass(duration: duration)
        }
        // Remove from View List
        classes.remove(atOffsets: offsets)
        
        // Update View
        classes = viewModel.fetchClassList()
        if classes.count == 0 {
            anyClass = false
        } else {
            anyClass = true
        }
    }
}
