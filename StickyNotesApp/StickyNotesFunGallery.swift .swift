//
//  StickyNotesFunGallery.swift .swift
//  StickyNotesApp
//
//  Created by Apeksha Pandey on 13/11/25.
//

import SwiftUI
import Combine
import UserNotifications
import PhotosUI

// MARK: - Model
struct FunStickyNote: Identifiable {
    var id = UUID()
    var text: String
    var color: Color
    var image: UIImage?  // Picked or preloaded image
    var reminderDate: Date?
}

// MARK: - ViewModel
class FunStickyNotesViewModel: ObservableObject {
    @Published var notes: [FunStickyNote] = []
    
    // Preload fun sticky notes
    init() {
        notes = [
            FunStickyNote(text: "Feed the cat 🐱", color: .yellow, image: UIImage(named: "cat1"), reminderDate: nil),
            FunStickyNote(text: "Buy groceries 🛒", color: .pink, image: UIImage(named: "grocery1"), reminderDate: nil),
            FunStickyNote(text: "Play with dog 🐶", color: .green, image: UIImage(named: "dog1"), reminderDate: nil),
            FunStickyNote(text: "Workout 💪", color: .orange, image: UIImage(named: "cartoon1"), reminderDate: nil),
            FunStickyNote(text: "Doctor Appointment 🩺", color: .purple, image: UIImage(named: "doctor1"), reminderDate: nil),
            FunStickyNote(text: "Relax Time 🌴", color: .mint, image: UIImage(named: "cartoon2"), reminderDate: nil)
        ]
    }
    
    func addNote(text: String, color: Color, image: UIImage?, reminder: Date?) {
        let newNote = FunStickyNote(text: text, color: color, image: image, reminderDate: reminder)
        notes.append(newNote)
        
        // Schedule notification if reminder exists
        if reminder != nil {
            scheduleNotification(note: newNote)
        }
    }
    
    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
    
    private func scheduleNotification(note: FunStickyNote) {
        guard let date = note.reminderDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = note.text
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: note.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Animated Background View
struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.purple, .pink, .blue, .orange, .mint, .yellow]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .animation(.linear(duration: 10).repeatForever(autoreverses: true), value: animateGradient)
        .onAppear { animateGradient.toggle() }
        .ignoresSafeArea()
    }
}

// MARK: - Sticky Notes Grid View
struct StickyNotesFunGallery: View {
    @StateObject private var viewModel = FunStickyNotesViewModel()
    @State private var showingAddNote = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.notes) { note in
                            VStack {
                                TextEditor(text: Binding(
                                    get: { note.text },
                                    set: { newValue in
                                        if let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                                            viewModel.notes[index].text = newValue
                                        }
                                    }
                                ))
                                .frame(height: 80)
                                .padding(5)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                
                                if let img = note.image {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .cornerRadius(10)
                                } else {
                                    Image(systemName: "smiley.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(note.color.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }
                        .onDelete(perform: viewModel.delete)
                    }
                    .padding()
                }
                .navigationTitle("Fun Sticky Notes")
                .toolbar {
                    Button(action: { showingAddNote = true }) {
                        Label("Add Note", systemImage: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .sheet(isPresented: $showingAddNote) {
                    AddFunStickyNoteView(viewModel: viewModel)
                }
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Notification permission granted: \(granted)")
            }
        }
    }
}

// MARK: - Add Sticky Note Page
struct AddFunStickyNoteView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FunStickyNotesViewModel
    
    @State private var text = ""
    @State private var color: Color = .yellow
    @State private var reminderDate = Date()
    @State private var addReminder = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    let colors: [Color] = [.yellow, .green, .pink, .orange, .purple, .blue, .mint, .red, .teal]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Note Text") {
                    TextField("Enter note...", text: $text)
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
                
                Section("Image") {
                    Button(action: { showImagePicker = true }) {
                        Text(selectedImage == nil ? "Pick Image" : "Change Image")
                    }
                    if let img = selectedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addNote(text: text, color: color, image: selectedImage, reminder: addReminder ? reminderDate : nil)
                        dismiss()
                    }
                    .disabled(text.isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { img, _ in
                    DispatchQueue.main.async { self.parent.selectedImage = img as? UIImage }
                }
            }
        }
    }
}

// MARK: - Preview
struct FunStickyNotesPage_Previews: PreviewProvider {
    static var previews: some View {
        StickyNotesFunGallery()
    }
}
