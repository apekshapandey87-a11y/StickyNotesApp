//
//  StickyNotesGridView.swift
//  StickyNotesApp
//
//  Created by Apeksha Pandey on 13/11/25.
//

import SwiftUI

// MARK: - Sample Note Model
struct SampleNote: Identifiable {
    var id = UUID()
    var text: String
    var imageName: String
    var color: Color
}

// MARK: - Sticky Notes Grid View
struct StickyNotesGridView: View {
    // Sample notes for display
    @State private var sampleNotes: [SampleNote] = [
        SampleNote(text: "Feed the cat 🐱", imageName: "cat1", color: .yellow),
        SampleNote(text: "Buy groceries 🥦", imageName: "grocery1", color: .pink),
        SampleNote(text: "Play with dog 🐶", imageName: "dog1", color: .green),
        SampleNote(text: "Workout 💪", imageName: "cartoon1", color: .orange),
        SampleNote(text: "Doctor Appointment 🩺", imageName: "doctor1", color: .purple),
        SampleNote(text: "Office Work 💻", imageName: "office1", color: .blue),
        SampleNote(text: "Relax Time 🌴", imageName: "cartoon2", color: .mint)
    ]
    
    // Grid layout: 2 columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Color choices
    let colorOptions: [Color] = [.yellow, .pink, .green, .orange, .purple, .blue, .mint, .red, .teal]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach($sampleNotes) { $note in
                    VStack {
                        Image(note.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .cornerRadius(10)
                        
                        Text(note.text)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(5)
                            .foregroundColor(.white)
                        
                        // Color picker for each note
                        HStack {
                            ForEach(colorOptions, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(note.color == color ? Color.black : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        note.color = color
                                    }
                            }
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(note.color)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
            }
            .padding()
        }
        .navigationTitle("Funky Sticky Notes")
    }
}

// MARK: - Preview
struct StickyNotesGridView_Previews: PreviewProvider {
    static var previews: some View {
        StickyNotesGridView()
    }
}
