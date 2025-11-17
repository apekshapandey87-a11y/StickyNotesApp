//
//  TravelStickyView.swift
//  StickyNotesApp
//
//  Created by Apeksha Pandey on 14/11/25.
//

import SwiftUI
import Combine
import UserNotifications

// MARK: - Model
struct TravelStickyNote: Identifiable {
    var id = UUID()
    var destination: String
    var travelDate: Date
    var budget: Double
    var emoji: String
    var color: Color
    var reminderDate: Date?
}

// MARK: - ViewModel
class TravelStickyViewModel: ObservableObject {
    @Published var notes: [TravelStickyNote] = [
        TravelStickyNote(destination: "Hawaii", travelDate: Date().addingTimeInterval(86400*30), budget: 2000, emoji: "🏖️", color: .yellow, reminderDate: nil),
        TravelStickyNote(destination: "Paris", travelDate: Date().addingTimeInterval(86400*60), budget: 2500, emoji: "🗼", color: .pink, reminderDate: nil)
    ]
    
    func add(note: TravelStickyNote) {
        notes.append(note)
    }
    
    func update(note: TravelStickyNote) {
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

// MARK: - Travel-specific Star Shape
struct TravelStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        let outer = min(rect.width, rect.height) / 2
        let inner = outer / 2.5
        var angle = -CGFloat.pi / 2
        let step = CGFloat.pi / 5
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
struct TravelStickyView: View {
    @StateObject private var vm = TravelStickyViewModel()
    @State private var showingEditSheet = false
    @State private var selectedNote: TravelStickyNote? = nil
    @State private var showingAddSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.notes) { note in
                    HStack {
                        stickyShape(for: note)
                        
                        VStack(alignment: .leading) {
                            Text(note.destination)
                                .font(.headline)
                            Text("Travel: \(note.travelDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption2)
                            Text("Budget: $\(Int(note.budget))")
                                .font(.caption2)
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
            .navigationTitle("Travel Stickies")
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
                    EditTravelNoteView(note: note) { updatedNote in
                        vm.update(note: updatedNote)
                        scheduleNotification(for: updatedNote)
                        showingEditSheet = false
                    } onCancel: {
                        showingEditSheet = false
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTravelNoteView { newNote in
                    vm.add(note: newNote)
                    scheduleNotification(for: newNote)
                    showingAddSheet = false
                } onCancel: {
                    showingAddSheet = false
                }
            }
        }
    }
    
    // MARK: - Cartoon sticky shape
    @ViewBuilder
    private func stickyShape(for note: TravelStickyNote) -> some View {
        if note.emoji.contains("🏖️") {
            RoundedRectangle(cornerRadius: 16)
                .fill(note.color)
                .frame(width: 70, height: 70)
                .overlay(Text(note.emoji).font(.largeTitle))
                .shadow(radius: 3)
        } else if note.emoji.contains("🗼") {
            Capsule()
                .fill(note.color)
                .frame(width: 70, height: 70)
                .overlay(Text(note.emoji).font(.largeTitle))
                .shadow(radius: 3)
        } else {
            TravelStarShape()
                .fill(note.color)
                .frame(width: 70, height: 70)
                .overlay(Text(note.emoji).font(.largeTitle))
                .shadow(radius: 3)
        }
    }
    
    // MARK: - Schedule Notification
    func scheduleNotification(for note: TravelStickyNote) {
        guard let date = note.reminderDate, date > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = "Travel Reminder"
        content.body = "\(note.emoji) \(note.destination)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Edit Travel Note
struct EditTravelNoteView: View {
    @State private var note: TravelStickyNote
    var onSave: (TravelStickyNote) -> Void
    var onCancel: () -> Void
    
    @State private var addReminder: Bool
    @State private var reminderDate: Date
    @State private var color: Color
    @State private var emoji: String
    
    init(note: TravelStickyNote, onSave: @escaping (TravelStickyNote) -> Void, onCancel: @escaping () -> Void) {
        self._note = State(initialValue: note)
        self.onSave = onSave
        self.onCancel = onCancel
        self._addReminder = State(initialValue: note.reminderDate != nil)
        self._reminderDate = State(initialValue: note.reminderDate ?? Date().addingTimeInterval(3600))
        self._color = State(initialValue: note.color)
        self._emoji = State(initialValue: note.emoji)
    }
    
    let colors: [Color] = [.yellow, .pink, .green, .orange, .blue, .purple]

    var body: some View {
        NavigationView {
            Form {
                Section("Destination") {
                    TextField("Destination", text: $note.destination)
                }
                Section("Travel Date") {
                    DatePicker("Travel Date", selection: $note.travelDate, displayedComponents: [.date])
                }
                Section("Budget") {
                    TextField("Budget", value: $note.budget, format: .number)
                        .keyboardType(.decimalPad)
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
            .navigationTitle("Edit Travel Sticky")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        note.color = color
                        note.emoji = emoji
                        note.reminderDate = addReminder ? reminderDate : nil
                        onSave(note)
                    }
                    .disabled(note.destination.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Add New Travel Note
struct AddTravelNoteView: View {
    @State private var destination: String = ""
    @State private var travelDate: Date = Date().addingTimeInterval(86400)
    @State private var budget: Double = 0
    @State private var emoji: String = "🌴"
    @State private var color: Color = .yellow
    @State private var addReminder: Bool = false
    @State private var reminderDate: Date = Date().addingTimeInterval(3600)
    
    var onSave: (TravelStickyNote) -> Void
    var onCancel: () -> Void
    
    let colors: [Color] = [.yellow, .pink, .green, .orange, .blue, .purple]

    var body: some View {
        NavigationView {
            Form {
                Section("Destination") {
                    TextField("Destination", text: $destination)
                }
                Section("Travel Date") {
                    DatePicker("Travel Date", selection: $travelDate, displayedComponents: [.date])
                }
                Section("Budget") {
                    TextField("Budget", value: $budget, format: .number)
                        .keyboardType(.decimalPad)
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
            .navigationTitle("New Travel Sticky")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newNote = TravelStickyNote(destination: destination, travelDate: travelDate, budget: budget, emoji: emoji, color: color, reminderDate: addReminder ? reminderDate : nil)
                        onSave(newNote)
                    }
                    .disabled(destination.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview
struct TravelStickyView_Previews: PreviewProvider {
    static var previews: some View {
        TravelStickyView()
    }
}
