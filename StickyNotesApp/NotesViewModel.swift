//
//  NotesViewModel.swift
//  StickyNotesApp
//
//  Created by Apeksha Pandey on 14/11/25.
//

import SwiftUI
import Combine
import UserNotifications

struct StickyNoteapp: Identifiable {
    var id = UUID()
    var text: String
    var category: StickyNotesFunGallery
    var color: Color
    var reminderDate: Date?
}

enum StickyNoteFunGalleryImagePicker: String, CaseIterable, Identifiable {
    case cartoon = "Cartoon"
    case grocery = "Grocery"
    case smile = "Smile"

    var id: String { rawValue }
}

class StickyNotesGrid: ObservableObject {
    @Published var notes: [StickyNote] = []

    func addNote(text: String, category: NoteCategory, color: Color, reminder: Date?) {
        let note = StickyNote(text: text, category: category, color: color, reminderDate: reminder)
        notes.append(note)
    }

    func update(note: StickyNote, text: String, color: Color, category: NoteCategory, reminder: Date?) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].text = text
            notes[index].color = color
            notes[index].category = category
            notes[index].reminderDate = reminder
        }
    }

    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}
