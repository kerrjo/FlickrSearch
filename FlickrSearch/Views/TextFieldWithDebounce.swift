//
//  TextFieldWithDebounce.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/15/22.
//

import SwiftUI
import Combine

/*
 an Observable that will update the secondary, debounced from the primary at intervals
 https://stackoverflow.com/questions/66164898/swiftui-combine-debounce-textfield/66165075
 */
class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(0.50), scheduler: DispatchQueue.main)
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
            if #available(iOS 15, *) {
                TextField("Search Tags", text: $textObserver.searchText) //.onChange(textChanged))
                    .frame(height: 30)
                    .padding(.leading, 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.indigo.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            } else {
                TextField("Search Tags", text: $textObserver.searchText) //.onChange(textChanged))
                    .frame(height: 30)
                    .padding(.leading, 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
            }
        }
        .onReceive(textObserver.$debouncedText) {
            debouncedText = $0
        }
    }
    
    /// debug - use TextField("Search Tags", text: $textObserver.searchText.onChange(textChanged))
    func textChanged(to value: String) {
        print(#function, "", value)
    }
}

struct TextFieldWithDebounce_Previews: PreviewProvider {
    @State static var text: String = ""
    static var previews: some View {
        TextFieldWithDebounce(debouncedText: $text)
    }
}
