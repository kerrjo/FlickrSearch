//
//  ContentView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI
import Combine

/*
 Primary content view
 presents the main Search and Search Results screen
 
 a View conatins a TextFiels that uses an observable
 The text that is changed in thetext field is subscribed to insid ethe observable
 */
struct ContentView: View {
    @StateObject var viewModel = PhotosModel()
    @StateObject var textObserver = TextFieldObserver()
    @State private var searchTerm = ""
    @State private var gridSplit = 3
    @State private var gridSpacing = 4.0
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
                        if #available(iOS 15, *) {
                            Color.indigo.opacity(0.5)
                                .edgesIgnoringSafeArea([.bottom])
                        } else {
                            Color.blue.opacity(0.5)
                                .edgesIgnoringSafeArea([.bottom])
                        }
                        
                        ScrollView {
                            LazyVGrid(columns: gridItems(for: geom.size.width), spacing: gridSpacing) {
                                ForEach(viewModel.photos, id: \.id) { item in
                                    NavigationLink(destination: PhotoView(item: item, title: searchTerm)) {
                                        PhotoItemView(item: item, square: $square, padding: (geom.size.width / Double(gridSplit)) / 2.2)
                                    }
                                }
                            }
                        }
                        .padding(gridSpacing)
                    }
                }
            }
            .navigationTitle("Flickr Photos")
        }
        .navigationViewStyle(.stack)
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
