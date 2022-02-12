//
//  PhotoItemTests.swift
//  FlickrSearchTests
//
//  Created by JOSEPH KERR on 2/11/22.
//

import XCTest
@testable import FlickrSearch

class PhotoItemTests: XCTestCase {
    
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    func testExample() throws {
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testAuthor() {
        let sut = PhotoItem(with: Item(title: "", link: "", media: Media(m: "url:"), dateTaken: "", itemDescription: "", published: "",
                                       author: "nobody@flickr.com (\"joker\")", authorID: "", tags: ""))
        XCTAssertEqual(sut.author, "joker")
    }
    
    func testAuthorWithSpaces() {
        let sut = PhotoItem(with: Item(title: "", link: "", media: Media(m: "url:"), dateTaken: "", itemDescription: "", published: "",
                                       author: "nobody@flickr.com (\"foo bar\")", authorID: "", tags: ""))
        XCTAssertEqual(sut.author, "foo bar")
    }
    
    func testImageURLlarge() {
        let sut = PhotoItem(with: Item(title: "", link: "", media: Media(m: "http://some.com/some_m.jpg"), dateTaken: "", itemDescription: "", published: "", author: "", authorID: "", tags: ""))
        XCTAssertEqual(sut.imageURLlarge?.absoluteString, "http://some.com/some_b.jpg")
    }
    
    func testImageURLsmall() {
        let sut = PhotoItem(with: Item(title: "", link: "", media: Media(m: "http://some.com/some_m.jpg"), dateTaken: "", itemDescription: "", published: "", author: "", authorID: "", tags: ""))
        XCTAssertEqual(sut.imageURLsmall!.absoluteString, "http://some.com/some_s.jpg")
    }
    
    func testImageURLthumbnail() {
        let sut = PhotoItem(with: Item(title: "", link: "", media: Media(m: "http://some.com/some_m.jpg"), dateTaken: "", itemDescription: "", published: "", author: "", authorID: "", tags: ""))
        XCTAssertEqual(sut.imageURLthumbnail!.absoluteString, "http://some.com/some_t.jpg")
    }
}
