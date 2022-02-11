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
    @State private var isShowingDetailView = false
    
    var body: some View {
        //        ZStack {
        //            Color.indigo.opacity(0.5)
        
        NavigationView {
            VStack {
                TextField("Search", text: $searchTerm.onChange(searchTermChanged))
                    .textFieldStyle(.roundedBorder)
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




//NavigationLink(destination: PhotoView(), isActive: $isShowingDetailView) { EmptyView() }

//            NavigationLink("photo", isActive: <#T##Binding<Bool>#>, destination: <#T##() -> _#>"Photo") {
//                EmptyView
//            }


//@State private var isShowingDetailView = false
//  var body: some View {
//      NavigationView {
//          VStack {
//              NavigationLink(destination: Text("Second View"), isActive: $isShowingDetailView) { EmptyView() }
//          }
//          .navigationTitle("Navigation")
//      }



//                                .onTapGesture {
//                                    viewModel.selected = item
//                                    isShowingDetailView = true
//                                }
