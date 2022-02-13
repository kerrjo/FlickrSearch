//
//  PhotoItem.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/12/22.
//

import Foundation

typealias PhotoItems = [PhotoItem]

protocol ImageSizes {
    var imageURLsmall: URL? { get }
    var imageURLlarge: URL? { get }
    var imageURLthumbnail: URL? { get }
    var imageURLsquare: URL? { get }
}

class PhotoItem: Identifiable {
    let id: UUID = UUID()
    let imageURL: URL?
    let title: String
    private(set) var dateTakenString: String
    let published: String
    let author: String
    var imageDimensions: (w: Double, h: Double) = (w: 0.0, h: 0.0)
    
    convenience init() {
        self.init(with: Item(title: "", link: "", media: Media(m: ":"), dateTaken: "", itemDescription: "", published: "", author: "", authorID: "", tags: ""),
                  dateTakenString: "",
                  published: "")
    }
    
    init(with item: Item, dateTakenString: String = "", published: String = "") {
        if let url = URL(string: item.media.m) {
            imageURL = url
        } else {
            imageURL = nil
        }
        title = item.title
        if let range = item.author.range(of: "@flickr.com ") {
            author = String(item.author.suffix(from: range.upperBound))
                .replacingOccurrences(of: "(\"", with: "")
                .replacingOccurrences(of: "\")", with: "")
        } else {
            author = item.author
        }
        self.dateTakenString = dateTakenString
        self.published = published
    }
    
}

extension PhotoItem: ImageSizes {
    var imageURLsmall: URL? {
        urlFromImage("_m", toSizeType: "_s")
    }
    
    var imageURLlarge: URL? {
        urlFromImage("_m", toSizeType: "_b")
    }
    
    var imageURLthumbnail: URL? {
        urlFromImage("_m", toSizeType: "_t")
    }
    
    var imageURLsquare: URL? {
        urlFromImage("_m", toSizeType: "_q")
    }
    
    private func urlFromImage(_ fromSizeType: String, toSizeType: String) -> URL? {
        guard let url = imageURL else {return nil }
        let ext = url.pathExtension
        var new_url = url.deletingPathExtension()
        let fname: String =
        new_url.lastPathComponent.hasSuffix(fromSizeType) ? String(new_url.lastPathComponent.dropLast(2)) : new_url.lastPathComponent
        new_url.deleteLastPathComponent()
        new_url.appendPathComponent(fname + toSizeType)
        new_url.appendPathExtension(ext)
        print(new_url)
        return new_url
    }
}

/*
 _s  <size label="Square" width="75" height="75"
 _q  <size label="Large Square" width="150" height="150"
 _t  <size label="Thumbnail" width="100" height="75"
 _m  <size label="Small" width="240" height="180"
 _n  <size label="Small 320" width="320" height="240"
 __  <size label="Medium" width="500" height="375"
 _z  <size label="Medium 640" width="640" height="480"
 _c  <size label="Medium 800" width="800" height="600"
 _b  <size label="Large" width="1024" height="768"
 _o  <size label="Original" width="2400" height="1800"
 */

