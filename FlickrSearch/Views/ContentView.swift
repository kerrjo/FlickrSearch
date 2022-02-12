//
//  ContentView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI
import Combine

// https://stackoverflow.com/questions/66164898/swiftui-combine-debounce-textfield/66165075

/*
 an Observable that will update the secondary, debounced from the primary at intervals
 */
class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.debouncedText = $0
            } )
            .store(in: &subscriptions)
    }
}

/*
 a View contains a TextField that uses an observable
 The text that is changed in thetext field is subscribed to insid ethe observable
 */
struct TextFieldWithDebounce : View {
    @Binding var debouncedText : String
    @StateObject private var textObserver = TextFieldObserver()
    
    var body: some View {
        VStack {
            TextField("Search Tags", text: $textObserver.searchText)
                .frame(height: 30)
                .padding(.leading, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .padding(.horizontal, 20)
        }.onReceive(textObserver.$debouncedText) {
            debouncedText = $0
        }
    }
}

/*
 a View conatins a TextFiels that uses an observable
 The text that is changed in thetext field is subscribed to insid ethe observable
 */
struct ContentView: View {
    @StateObject var viewModel = PhotosModel()
    @StateObject var textObserver = TextFieldObserver()
    @State private var searchTerm = ""

    var body: some View {
        NavigationView {
            VStack {
                TextFieldWithDebounce(debouncedText: $searchTerm.onChange(searchTermChanged))
                ZStack {
                    Color.indigo.opacity(0.5)
                        .edgesIgnoringSafeArea([.bottom])
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(viewModel.photos, id: \.id) { item in
                                NavigationLink {
                                    PhotoView(item: item)
                                } label: {
                                    AsyncImage(url: item.imageURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                        .frame(width: 100, height: 100, alignment: .center)

//                                        Image(systemName: "photo")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 80, height: 80, alignment: .center)
                                    }
                                }
                            }
                        }
                    }
                    // scroll view
                }
            }
            .navigationTitle("Flickr Photos")
        }
    }
    
    func searchTermChanged(to value: String) {
        print(#function, value)
        guard value.count > 1 else { return }
        viewModel.fetch(using: value)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}
