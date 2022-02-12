//
//  PhotoItemTests.swift
//  FlickrSearchTests
//
//  Created by JOSEPH KERR on 2/11/22.
//

import XCTest
@testable import FlickrSearch

class PhotoItemTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testAuthor() {
        let sut = PhotoItem(with: Item(title: "", link: "", media: Media(m: "http://some.com"),
                                       dateTaken: "", itemDescription: "", published: "",
                                       author: "nobody@flickr.com (\"joker\")", authorID: "", tags: ""))
        
        XCTAssertEqual(sut.author, "(\"joker\")")
    }
    
    func testAuthorWithSpaces() {
        let sut = PhotoItem(with: Item(title: "", link: "", media: Media(m: "http://some.com"),
                                       dateTaken: "", itemDescription: "", published: "",
                                       author: "nobody@flickr.com (\"foo bar\")", authorID: "", tags: ""))
        
        XCTAssertEqual(sut.author, "(\"foo bar\")")
    }


}
