//
//  ContentView.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import SwiftUI

struct PhotoItem: Identifiable {
    var id: UUID = UUID()
    var imageURL: URL
    var title: String = "photo"
    init(_ url: URL, title: String = "") {
        imageURL = url
        self.title = title
    }
}


class PhotosModel: ObservableObject {
    @Published var photos: [PhotoItem] = []
    @Published var selected: PhotoItem?
    private var service: FlickrWebService
    
    func fetch(using term: String) {
        service.fetchPhotos(searchTerm: term) { [weak self] in
            switch $0 {
            case .success(let resp):
                print(resp.title, "\(resp.items.count)")
                
                var items: [PhotoItem] = []
                resp.items.forEach {
                    if let url = URL(string: $0.media.m) {
                        items.append(PhotoItem(url, title: $0.title))
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.photos = items
                }
//                Task {
//                    await MainActor.run { [unowned items] in
//                        self?.photos = items
//                    }
//                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    init(_ service: FlickrWebService? = nil) {
        self.service = service ?? FlickrServiceHandler()
    }
    
}


//@State private var isShowingDetailView = false
//
//  var body: some View {
//      NavigationView {
//          VStack {
//              NavigationLink(destination: Text("Second View"), isActive: $isShowingDetailView) { EmptyView() }
//
//              Button("Tap to show detail") {
//                  isShowingDetailView = true
//              }
//          }
//          .navigationTitle("Navigation")
//      }


struct ContentView: View {
    @State private var searchTerm: String = ""
    @StateObject var viewModel = PhotosModel()
    @State private var isShowingDetailView = false
    
    var body: some View {
        //        ZStack {
        //            Color.indigo.opacity(0.5)
        
        NavigationView {
            //NavigationLink(destination: PhotoView(), isActive: $isShowingDetailView) { EmptyView() }
            
            //            NavigationLink("photo", isActive: <#T##Binding<Bool>#>, destination: <#T##() -> _#>"Photo") {
            //                EmptyView
            //            }
            VStack {
                TextField("Search", text: $searchTerm.onChange(searchTermChanged))
                    .textFieldStyle(.roundedBorder)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.photos, id: \.id) { item in
                            
                            NavigationLink {
                                PhotoView(viewModel: viewModel, item: item)
                            } label: {
                                AsyncImage(url: item.imageURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Image(systemName: "photo")
                                    //ProgressView()
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Flickr Photos")
        //        }
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



//                                .onTapGesture {
//                                    viewModel.selected = item
//                                    isShowingDetailView = true
//                                }
