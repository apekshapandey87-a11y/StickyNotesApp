//
//  ModelsAndViews.swift
//  StickyNotesApp
//
//  Created by Apeksha Pandey on 13/11/25.
//

import SwiftUI
import Combine
import UserNotifications

// MARK: - Model
struct StickyNote: Identifiable {
    var id = UUID()
    var text: String
    var category: NoteCategory
    var color: Color
    var reminderDate: Date?
    var createdAt = Date()
}

enum NoteCategory: String, CaseIterable, Identifiable {
    case cartoon = "Cartoon"
    case grocery = "Grocery"
    case smile = "Smile"
    
    var id: String { self.rawValue }
}

// MARK: - ViewModel
class NotesViewModel: ObservableObject {
    @Published var notes: [StickyNote] = []
    
    func addNote(text: String, category: NoteCategory, color: Color, reminder: Date?) {
        let newNote = StickyNote(text: text, category: category, color: color, reminderDate: reminder)
        notes.append(newNote)
        
        if let reminder = reminder {
            scheduleNotification(for: newNote, at: reminder)
        }
    }
    
    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
    
    private func scheduleNotification(for note: StickyNote, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Sticky Note Reminder"
        content.body = note.text
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Main Notes List View
struct NotesListView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.notes) { note in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(note.text)
                            .font(.headline)
                            .padding(8)
                            .background(note.color)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        
                        Text("Category: \(note.category.rawValue)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if let reminder = note.reminderDate {
                            Text("Reminder: \(reminder.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: viewModel.delete)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Sticky Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel)
            }
        }
        .onAppear {
            // Request notification permissions
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                print("Notification permission granted: \(granted)")
            }
        }
    }
}

// MARK: - Add Note View
struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: NotesViewModel
    
    @State private var text = ""
    @State private var category: NoteCategory = .cartoon
    @State private var selectedColor: Color = .yellow
    @State private var addReminder = false
    @State private var reminderDate = Date()
    
    let colors: [Color] = [.yellow, .green, .pink, .orange, .purple, .blue, .red, .mint, .teal]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Note Text") {
                    TextField("Enter note...", text: $text)
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(NoteCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(colors, id: \.self) { c in
                                Circle()
                                    .fill(c)
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(selectedColor == c ? .black : .clear, lineWidth: 2))
                                    .onTapGesture { selectedColor = c }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Section("Reminder") {
                    Toggle("Add Reminder", isOn: $addReminder)
                    if addReminder {
                        DatePicker("Select Date & Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("New Sticky Note")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addNote(text: text, category: category, color: selectedColor, reminder: addReminder ? reminderDate : nil)
                        dismiss()
                    }
                    .disabled(text.isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Previews
struct NotesListView_Previews: PreviewProvider {
    static var previews: some View {
        NotesListView()
    }
}


struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView(viewModel: NotesViewModel())
    }
}
