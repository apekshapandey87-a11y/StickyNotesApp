//
//  HomeView.swift
//  StickyNotesApp
//
//  Created by Apeksha Pandey on 14/11/25.
//

import SwiftUI

// MARK: - Model for Animated Stickers
struct HomeSticker: Identifiable {
    let id = UUID()
    let emoji: String
    let color: Color
    var xPos: CGFloat
    var yPos: CGFloat
    let size: CGFloat
    var rotation: Double
    var xVelocity: CGFloat
    var yVelocity: CGFloat
    var opacity: Double
}

// MARK: - Animated Home Screen with Dark Blue + Glowing Stickers
struct HomeView: View {
    @State private var stickers: [HomeSticker] = []
    @State private var animateBackground = false
    
    let emojis = ["😊", "😎", "🌴", "🏖️", "✨", "👍", "🗼", "🌟", "🎉"]
    let colors: [Color] = [.yellow, .orange, .pink, .purple, .green, .blue, .red, .white]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: - Dark Blue Animated Background
                LinearGradient(
                    colors: animateBackground
                        ? [Color(red: 10/255, green: 30/255, blue: 74/255),
                           Color(red: 19/255, green: 47/255, blue: 109/255),
                           Color(red: 26/255, green: 63/255, blue: 140/255)]
                        : [Color(red: 26/255, green: 63/255, blue: 140/255),
                           Color(red: 10/255, green: 30/255, blue: 74/255),
                           Color(red: 19/255, green: 47/255, blue: 109/255)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(
                    Animation.linear(duration: 8).repeatForever(autoreverses: true),
                    value: animateBackground
                )
                .onAppear { animateBackground = true }
                
                // MARK: - Floating, glowing & blinking stickers
                ForEach(stickers.indices, id: \.self) { i in
                    Text(stickers[i].emoji)
                        .font(.system(size: stickers[i].size))
                        .padding(10)
                        .background(stickers[i].color.opacity(0.6))
                        .cornerRadius(15)
                        .shadow(color: stickers[i].color.opacity(0.8), radius: 10, x: 0, y: 0)
                        .position(x: stickers[i].xPos, y: stickers[i].yPos)
                        .rotationEffect(.degrees(stickers[i].rotation))
                        .opacity(stickers[i].opacity)
                        .onAppear {
                            startStickerAnimation(index: i, width: geo.size.width, height: geo.size.height)
                        }
                }
                
                // MARK: - Navigation content
                NavigationView {
                    VStack(spacing: 20) {
                        Text("🌟 My Sticky Notes App 🌟")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(.top, 20)
                        
                        List {
                            NavigationLink("Fun Sticky") { StickyNotesFunGallery() }
                            NavigationLink("Sticky Office Space") { OfficeSpaceView() }
                            NavigationLink("Important Sticky") { ImportantStickyView() }
                            NavigationLink("Sticky Travel") { TravelStickyView() }
                            NavigationLink("Settings") { SettingsView() }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    .navigationBarHidden(true)
                }
            }
            .onAppear {
                createStickers(count: 20, width: geo.size.width, height: geo.size.height)
            }
        }
    }
    
    // MARK: - Create random stickers
    private func createStickers(count: Int, width: CGFloat, height: CGFloat) {
        stickers = []
        for _ in 0..<count {
            let emoji = emojis.randomElement()!
            let color = colors.randomElement()!
            let size = CGFloat.random(in: 40...70)
            let xPos = CGFloat.random(in: size...(width - size))
            let yPos = CGFloat.random(in: size...(height - size))
            let rotation = Double.random(in: -20...20)
            let xVelocity = CGFloat.random(in: -1.5...1.5)
            let yVelocity = CGFloat.random(in: -1.5...1.5)
            let opacity = Double.random(in: 0.5...1)
            
            stickers.append(HomeSticker(
                emoji: emoji,
                color: color,
                xPos: xPos,
                yPos: yPos,
                size: size,
                rotation: rotation,
                xVelocity: xVelocity,
                yVelocity: yVelocity,
                opacity: opacity
            ))
        }
    }
    
    // MARK: - Animate stickers: bounce + blinking
    private func startStickerAnimation(index: Int, width: CGFloat, height: CGFloat) {
        guard stickers.indices.contains(index) else { return }
        
        // Timer for position & rotation
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            stickers[index].xPos += stickers[index].xVelocity
            stickers[index].yPos += stickers[index].yVelocity
            
            // Bounce off edges
            if stickers[index].xPos <= stickers[index].size / 2 || stickers[index].xPos >= width - stickers[index].size / 2 {
                stickers[index].xVelocity *= -1
            }
            if stickers[index].yPos <= stickers[index].size / 2 || stickers[index].yPos >= height - stickers[index].size / 2 {
                stickers[index].yVelocity *= -1
            }
            
            // Slight rotation change
            stickers[index].rotation += Double.random(in: -1...1)
        }
        
        // Timer for blinking effect
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 0.5...2.0), repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                stickers[index].opacity = stickers[index].opacity == 1 ? 0.4 : 1
            }
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        StickyNotesGridView()
    }
}

