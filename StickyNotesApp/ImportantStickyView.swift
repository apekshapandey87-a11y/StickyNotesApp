//
//  ImportantStickyView.swift
//  StickyNotesApp
//
//  Created by Apeksha Pandey on 14/11/25.
//

import SwiftUI
import Combine
import UserNotifications

// MARK: - Model
struct ImportantStickyNote: Identifiable {
    var id = UUID()
    var text: String
    var emoji: String
    var color: Color
    var reminderDate: Date?
}

// MARK: - ViewModel
class ImportantStickyViewModel: ObservableObject {
    @Published var notes: [ImportantStickyNote]

    init() {
        self.notes = [
            ImportantStickyNote(text: "Doctor Appointment", emoji: "🩺", color: .yellow, reminderDate: nil),
            ImportantStickyNote(text: "Cat Vaccination", emoji: "🐱💉", color: .pink, reminderDate: nil)
        ]
    }
    
    func add(note: ImportantStickyNote) {
        notes.append(note)
    }
    
    func update(note: ImportantStickyNote) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        }
    }
    
    func delete(at offsets: IndexSet) {
        for i in offsets {
            let note = notes[i]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [note.id.uuidString])
        }
        notes.remove(atOffsets: offsets)
    }
}

// MARK: - Star Shape
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        let outer = min(rect.width, rect.height) / 2
        let inner = outer / 2.5
        var angle = -CGFloat.pi / 2      // Use CGFloat.pi
        let step = CGFloat.pi / 5         // Use CGFloat.pi
        var first = true

        for _ in 0..<10 {
            let radius = first ? outer : inner
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            if first { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
            first.toggle()
            angle += step
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Main View
struct ImportantStickyView: View {
    @StateObject private var vm = ImportantStickyViewModel()
    @State private var showingEditSheet = false
    @State private var selectedNote: ImportantStickyNote? = nil
    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.notes) { note in
                    HStack {
                        shape(for: note)
                        
                        VStack(alignment: .leading) {
                            Text(note.text)
                                .font(.headline)
                            if let reminder = note.reminderDate {
                                Text("Reminder: \(reminder.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        Spacer()
                        Button(action: {
                            selectedNote = note
                            showingEditSheet = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                        }
                    }
                    .padding(6)
                }
                .onDelete(perform: vm.delete)
            }
            .navigationTitle("Important Stickies")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                if let note = selectedNote {
                    EditImportantNoteView(note: note) { updatedNote in
                        vm.update(note: updatedNote)
                        scheduleNotification(for: updatedNote)
                        showingEditSheet = false
                    } onCancel: {
                        showingEditSheet = false
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddImportantNoteView { newNote in
                    vm.add(note: newNote)
                    scheduleNotification(for: newNote)
                    showingAddSheet = false
                } onCancel: {
                    showingAddSheet = false
                }
            }
        }
    }
    
    // MARK: - Cartoon Shape for Note
    @ViewBuilder
    private func shape(for note: ImportantStickyNote) -> some View {
        if note.emoji.first == "🩺" {
            RoundedRectangle(cornerRadius: 16)
                .fill(note.color)
                .frame(width: 70, height: 70)
                .overlay(Text(note.emoji).font(.largeTitle))
                .shadow(radius: 3)
        } else if note.emoji.first == "🐱" {
            Capsule()
                .fill(note.color)
                .frame(width: 70, height: 70)
                .overlay(Text(note.emoji).font(.largeTitle))
                .shadow(radius: 3)
        } else {
            StarShape()
                .fill(note.color)
                .frame(width: 70, height: 70)
                .overlay(Text(note.emoji).font(.largeTitle))
                .shadow(radius: 3)
        }
    }
    
    // MARK: - Schedule Notification
    func scheduleNotification(for note: ImportantStickyNote) {
        guard let date = note.reminderDate, date > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "\(note.emoji) \(note.text)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Edit Note Sheet
struct EditImportantNoteView: View {
    @State private var note: ImportantStickyNote
    var onSave: (ImportantStickyNote) -> Void
    var onCancel: () -> Void
    
    @State private var addReminder: Bool
    @State private var reminderDate: Date
    @State private var emoji: String
    @State private var color: Color
    
    init(note: ImportantStickyNote, onSave: @escaping (ImportantStickyNote) -> Void, onCancel: @escaping () -> Void) {
        self._note = State(initialValue: note)
        self.onSave = onSave
        self.onCancel = onCancel
        self._addReminder = State(initialValue: note.reminderDate != nil)
        self._reminderDate = State(initialValue: note.reminderDate ?? Date().addingTimeInterval(3600))
        self._emoji = State(initialValue: note.emoji)
        self._color = State(initialValue: note.color)
    }
    
    let colors: [Color] = [.yellow, .pink, .green, .orange, .blue, .purple]

    var body: some View {
        NavigationView {
            Form {
                Section("Text") {
                    TextField("Note Text", text: $note.text)
                }
                
                Section("Emoji") {
                    TextField("Emoji", text: $emoji)
                        .font(.largeTitle)
                }
                
                Section("Color") {
                    HStack {
                        ForEach(colors, id: \.self) { c in
                            Circle()
                                .fill(c)
                                .frame(width: 30, height: 30)
                                .overlay(Circle().stroke(color == c ? .black : .clear, lineWidth: 2))
                                .onTapGesture { color = c }
                        }
                    }
                }
                
                Section("Reminder") {
                    Toggle("Add Reminder", isOn: $addReminder)
                    if addReminder {
                        DatePicker("Select Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Edit Sticky")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        note.emoji = emoji
                        note.color = color
                        note.reminderDate = addReminder ? reminderDate : nil
                        onSave(note)
                    }
                    .disabled(note.text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Add New Note Sheet
struct AddImportantNoteView: View {
    @State private var text: String = ""
    @State private var emoji: String = "📝"
    @State private var color: Color = .yellow
    @State private var addReminder = false
    @State private var reminderDate: Date = Date().addingTimeInterval(3600)
    
    var onSave: (ImportantStickyNote) -> Void
    var onCancel: () -> Void
    
    let colors: [Color] = [.yellow, .pink, .green, .orange, .blue, .purple]

    var body: some View {
        NavigationView {
            Form {
                Section("Text") {
                    TextField("Note Text", text: $text)
                }
                
                Section("Emoji") {
                    TextField("Emoji", text: $emoji)
                        .font(.largeTitle)
                }
                
                Section("Color") {
                    HStack {
                        ForEach(colors, id: \.self) { c in
                            Circle()
                                .fill(c)
                                .frame(width: 30, height: 30)
                                .overlay(Circle().stroke(color == c ? .black : .clear, lineWidth: 2))
                                .onTapGesture { color = c }
                        }
                    }
                }

                Section("Reminder") {
                    Toggle("Add Reminder", isOn: $addReminder)
                    if addReminder {
                        DatePicker("Select Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("New Sticky Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newNote = ImportantStickyNote(text: text, emoji: emoji, color: color, reminderDate: addReminder ? reminderDate : nil)
                        onSave(newNote)
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview
struct ImportantStickyView_Previews: PreviewProvider {
    static var previews: some View {
        ImportantStickyView()
    }
}
