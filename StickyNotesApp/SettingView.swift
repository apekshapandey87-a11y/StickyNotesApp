//
//  SettingView.swift
//  StickyNotesApp
//
//  Created by Apeksha Pandey on 14/11/25.
//

import SwiftUI
import Combine // ✅ Needed for ObservableObject

// MARK: - Settings Model
class AppSettings: ObservableObject {
    @Published var notificationsEnabled: Bool = true
    @Published var defaultColor: Color = .yellow
    @Published var defaultEmoji: String = "😊"
    @Published var isDarkMode: Bool = false
}

// MARK: - Settings View
struct SettingsView: View {
    @StateObject private var settings = AppSettings() // ✅ Requires Combine
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Enable Reminders", isOn: $settings.notificationsEnabled)
                }
                
                Section("Default Sticky") {
                    Picker("Default Color", selection: $settings.defaultColor) {
                        HStack { Circle().fill(Color.yellow).frame(width: 20, height: 20); Text("Yellow") }.tag(Color.yellow)
                        HStack { Circle().fill(Color.pink).frame(width: 20, height: 20); Text("Pink") }.tag(Color.pink)
                        HStack { Circle().fill(Color.green).frame(width: 20, height: 20); Text("Green") }.tag(Color.green)
                        HStack { Circle().fill(Color.orange).frame(width: 20, height: 20); Text("Orange") }.tag(Color.orange)
                        HStack { Circle().fill(Color.blue).frame(width: 20, height: 20); Text("Blue") }.tag(Color.blue)
                        HStack { Circle().fill(Color.purple).frame(width: 20, height: 20); Text("Purple") }.tag(Color.purple)
                    }
                    
                    TextField("Default Emoji", text: $settings.defaultEmoji)
                        .font(.largeTitle)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $settings.isDarkMode)
                        .onChange(of: settings.isDarkMode) { isDark in
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                windowScene.windows.first?.overrideUserInterfaceStyle = isDark ? .dark : .light
                            }
                        }
                }
                
                Section("Danger Zone") {
                    Button(role: .destructive) {
                        resetAllData()
                    } label: {
                        Text("Reset All Sticky Notes")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    // MARK: - Reset Function
    func resetAllData() {
        // Implement resetting sticky notes if needed
        print("All sticky notes reset!")
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
