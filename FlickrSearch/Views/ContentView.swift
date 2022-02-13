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
//            TextField("Search Tags", text: $textObserver.searchText.onChange(textChanged))
                .frame(height: 30)
                .padding(.leading, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.indigo.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        }
        .onReceive(textObserver.$debouncedText) {
            debouncedText = $0
        }
    }
    
    /// debug
    func textChanged(to value: String) {
        print(#function, "", value)
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
    @State private var gridSplit = 3
    @State private var gridSpacing = 8.0
    @State private var square = true
 
    private func gridItems(for width: CGFloat) -> [GridItem] {
        // interior bewteen items and outside = ( gridSplit + 1 )
        let gridSplitWidth = width - gridSpacing * Double(gridSplit + 1)
        let gridItemWidth = gridSplitWidth / Double(gridSplit)
        return (1...gridSplit).map { _ in GridItem(.fixed(gridItemWidth), spacing: gridSpacing) }
    }

    var body: some View {
        NavigationView {
            GeometryReader { geom in
                VStack {
                    
                    TextFieldWithDebounce(debouncedText: $searchTerm.onChange(searchTermChanged))
                    
                    ZStack {
                        Color.indigo.opacity(0.5)
                            .edgesIgnoringSafeArea([.bottom])
                        
                        ScrollView {
                            LazyVGrid(columns: gridItems(for: geom.size.width), spacing: gridSpacing) {
                                ForEach(viewModel.photos, id: \.id) { item in
                                    NavigationLink {
                                        PhotoView(item: item)
                                    } label: {
                                        AsyncImage(url: square ? item.imageURLsquare : item.imageURL) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                                .progressViewStyle(.circular)
                                                .accentColor(Color.white)
                                                .scaleEffect(x: 1.3, y: 1.3, anchor: .center)
                                                .padding((geom.size.width / Double(gridSplit)) / 2.2)
                                        }
                                    }
                                    //.navigationBarHidden(true)
                                }
                            }
                        } // scroll view
                        .padding(gridSpacing)
                    }
                }
            } // navigation view
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
