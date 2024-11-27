//
//  ContentView.swift
//  DailyMotivation
//
//  Created by Sok Pich on 11/27/24.
//
import SwiftUI

struct ContentView: View {
    @State private var quote: String = "Your limitation—it's only your imagination."
    @State private var isSettingsPresented = false
    @StateObject private var quoteManager = QuoteManager()
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("🌟 Daily Motivation")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(quote)
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button(action: generateNewQuote) {
                        Text("Get New Quote")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    Button(action: { isSettingsPresented = true }) {
                        Text("Settings")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $isSettingsPresented) {
                        SettingsView(quoteManager: quoteManager)
                    }
                }
                .padding()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func generateNewQuote() {
        if let newQuote = quoteManager.quotes.randomElement() {
            quote = newQuote
        }
    }
}

struct SettingsView: View {
    @ObservedObject var quoteManager: QuoteManager
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                List {
                    Section {
                        NavigationLink("Edit List") {
                            EditQuoteListView(quoteManager: quoteManager)
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct EditQuoteListView: View {
    @ObservedObject var quoteManager: QuoteManager
    @State private var isEditingQuote = false
    @State private var isAddingQuote = false
    @State private var currentQuoteIndex: Int? = nil
    
    var body: some View {
        List {
            ForEach(quoteManager.quotes.indices, id: \.self) { index in
                Text(quoteManager.quotes[index])
                    .swipeActions {
                        Button(role: .destructive) {
                            quoteManager.deleteQuote(at: index)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            currentQuoteIndex = index
                            isEditingQuote = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
            }
            
            Button(action: { isAddingQuote = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Quote")
                }
            }
        }
        .sheet(isPresented: $isEditingQuote, content: {
            if let index = currentQuoteIndex {
                AddEditQuoteView(
                    title: "Edit Quote",
                    initialText: quoteManager.quotes[index],
                    onSubmit: { updatedQuote in
                        quoteManager.updateQuote(at: index, with: updatedQuote)
                    }
                )
            }
        })
        .sheet(isPresented: $isAddingQuote, content: {
            AddEditQuoteView(
                title: "Add New Quote",
                initialText: "",
                onSubmit: { newQuote in
                    quoteManager.addQuote(newQuote: newQuote)
                }
            )
        })
        .navigationTitle("Edit Quotes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddEditQuoteView: View {
    let title: String
    @State private var quoteText: String
    let onSubmit: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(title: String, initialText: String, onSubmit: @escaping (String) -> Void) {
        self.title = title
        self._quoteText = State(initialValue: initialText)
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                Form {
                    Section(header: Text("Quote")) {
                        TextField("Enter quote", text: $quoteText)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            onSubmit(quoteText)
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

class QuoteManager: ObservableObject {
    @Published var quotes: [String] = [
        "Push yourself, because no one else is going to do it for you.",
        "Sometimes later becomes never. Do it now.",
        "Great things never come from comfort zones.",
        "Dream it. Wish it. Do it.",
        "Success doesn’t just find you. You have to go out and get it.",
        "The harder you work for something, the greater you’ll feel when you achieve it.",
        "Dream bigger. Do bigger.",
        "Don’t stop when you’re tired. Stop when you’re done.",
        "Your limitation—it’s only your imagination.",
        "Believe you can, and you're halfway there.",
        "Don't wait. The time will never be just right.",
        "It always seems impossible until it's done.",
        "Success is not final, failure is not fatal: It is the courage to continue that counts.",
        "You don't have to be great to start, but you have to start to be great.",
        "Hardships often prepare ordinary people for an extraordinary destiny.",
        "Believe in yourself and all that you are. Know that there is something inside you that is greater than any obstacle.",
        "Do what you can with all you have, wherever you are.",
        "The only way to do great work is to love what you do.",
        "Challenges are what make life interesting, and overcoming them is what makes life meaningful.",
        "Failure is not the opposite of success; it’s part of success.",
        "The best time to plant a tree was 20 years ago. The second-best time is now.",
        "You are never too old to set another goal or to dream a new dream.",
        "Act as if what you do makes a difference. It does.",
        "Happiness is not something ready-made. It comes from your own actions."
    ]
    
    func deleteQuote(at index: Int) {
        quotes.remove(at: index)
    }
    
    func updateQuote(at index: Int, with newQuote: String) {
        quotes[index] = newQuote
    }
    
    func addQuote(newQuote: String) {
        quotes.append(newQuote)
    }
}
