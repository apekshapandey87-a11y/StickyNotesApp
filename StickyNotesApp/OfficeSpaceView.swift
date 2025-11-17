//
//  OfficeSpaceView.swift
//  StickyNotesApp
//
//  Created by Apeksha Pandey on 14/11/25.
//

import SwiftUI

struct OfficeSpaceView: View {
    
    // Categories
    enum OfficeCategory: String, CaseIterable, Identifiable {
        case meeting = "Meeting"
        case work = "Work"
        case tasks = "Tasks"
        
        var id: String { self.rawValue }
        var emoji: String {
            switch self {
            case .meeting: return "📅"
            case .work: return "💼"
            case .tasks: return "📌"
            }
        }
    }
    
    // Sticky Note Model
    struct OfficeNote: Identifiable {
        var id = UUID()
        var text: String
        var category: OfficeCategory
        var color: Color
    }
    
    @State private var selectedCategory: OfficeCategory = .meeting
    @State private var noteText: String = ""
    @State private var notes: [OfficeNote] = []
    
    
    var body: some View {
        ZStack {
            
            // 🌈 BACKGROUND COLOR
            Color.white.opacity(0.30)
                .ignoresSafeArea()
            
            // 😀 SMILEY BACKGROUND
            VStack {
                ForEach(0..<15) { _ in
                    HStack {
                        ForEach(0..<10) { _ in
                            Text("😊")
                                .font(.system(size: 28))
                                .opacity(0.15)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            
            
            // MAIN CONTENT
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("")
                        .font(.largeTitle).bold()
                    
                    // CATEGORY PICKER
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(OfficeCategory.allCases) { cat in
                            Text("\(cat.emoji) \(cat.rawValue)").tag(cat)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical)
                    
                    
                    // TEXT FIELD
                    TextField("Write something...", text: $noteText)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    
                    // ADD BUTTON
                    Button(action: addNote) {
                        Text("Add Sticky Note")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    
                    // STICKY NOTES GRID
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(notes) { note in
                            VStack(alignment: .leading, spacing: 8) {
                                
                                Text(note.category.emoji)
                                    .font(.largeTitle)
                                
                                Text(note.text)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.top, 5)
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(note.color)
                            .cornerRadius(20)
                            .shadow(radius: 4)
                            .contextMenu {
                                Button("Delete") { delete(note) }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Office Space Work")
    }
    
    
    // MARK: - FUNCTIONS
    
    func addNote() {
        guard !noteText.isEmpty else { return }
        
        let colorOptions: [Color] = [.yellow, .green, .orange, .pink, .blue.opacity(0.6)]
        
        let newNote = OfficeNote(
            text: noteText,
            category: selectedCategory,
            color: colorOptions.randomElement()!
        )
        
        notes.append(newNote)
        noteText = ""
    }
    
    func delete(_ note: OfficeNote) {
        notes.removeAll { $0.id == note.id }
    }
}

#Preview {
    NavigationView {
        OfficeSpaceView()
    }
}
