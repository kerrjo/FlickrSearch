//
//  ContentView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI

struct ContentView: View {
    @State private var searchTerm: String = ""
    @StateObject var viewModel = PhotosModel()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $searchTerm.onChange(searchTermChanged))
                    .textFieldStyle(.roundedBorder)
                ZStack {
                    Color.indigo.opacity(0.5)
                    
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
                                        Image(systemName: "photo")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Flickr Photos")
        }
    }
    
    func searchTermChanged(to value: String) {
        print("Name changed to \(searchTerm)!")
        viewModel.fetch(using: searchTerm)
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

