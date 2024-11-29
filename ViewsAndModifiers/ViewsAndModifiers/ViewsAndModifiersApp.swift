//
//  ViewsAndModifiersApp.swift
//  ViewsAndModifiers
//
//  Created by Sok Pich on 11/29/24.
//

import SwiftUI

@main
struct ViewsAndModifiersApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
            showText()
        }
    }
}

struct Modifiers: View {
    var body: some View {
//        Button("Hello, World!") {
//            print(type(of: self.body))
//        }
//        .background(.red)
//        .frame(maxWidth: 200, maxHeight: 200)
//        .background(Color.red)
        Text("Hello, Swifty")
            .padding()
            .background(.red)
            .padding()
            .background(.blue)
            .padding()
            .background(.green)
            .padding()
            .background(.yellow)
    }
}

#Preview {
    Modifiers()
}

struct CapsuleText: View {
    var text: String
    var body: some View {
        Text(text)
        .font(.largeTitle)
        .padding()
        .foregroundStyle(.cyan)
        .background(.blue)
        .clipShape(.capsule)
    }
}
struct showText: View {
    var body: some View {
        VStack(spacing: 10) {
            // create our own
            CapsuleText(text: "Frist")
            CapsuleText(text: "Second")
            
            //custom modifiers
            Text("hi").modifier(Title())
            
            //we extent to View
            Text("Hello my world").titleStyle()
            
            
            // Water mark
            Color.blue
                .frame(width: 300, height: 200)
                .watermarked(with: "N0 M3rcy")
            
            GridStack(rows: 4, columns: 5) { row, col in
                Text("R\(row), C\(col)")
            }
        }
    }
}


// Custom modifiers
struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.white)
            .padding()
            .background(.blue)
            .clipShape(.rect(cornerRadius: 10))
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(Title())
    }
}

struct Watermark: ViewModifier {
    var text: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            Text(text)
                .font(.caption)
                .foregroundStyle(.white)
                .padding(5)
                .background(.black)
        }
    }
}

extension View {
    func watermarked(with text: String) -> some View {
        modifier(Watermark(text: text))
    }
}

// Custom containers
struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content
    
    var body: some View {
       VStack {
           ForEach(0..<rows, id: \.self) { row in
               HStack {
                   ForEach(0..<columns, id: \.self) { column in
                       content(row, column)
                   }
               }
               
           }
        }
    }
}
