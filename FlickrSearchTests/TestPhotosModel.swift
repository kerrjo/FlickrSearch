//
//  TestPhotosModel.swift
//  FlickrSearchTests
//
//  Created by JOSEPH KERR on 2/11/22.
//

import XCTest
import Combine
@testable import FlickrSearch

class TestPhotosModel: XCTestCase {
    
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
   // override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    //    item.dateTakenString = self?.dateFormatter?.stringDateFromISODateString($0.dateTaken) ?? ""
    //    item.published = self?.dateFormatter?.relativeStringDateFromDateString($0.published) ?? ""

    func testRelativeCalledForPublished() throws {
        
        let expectedDateString = "publisheddate"
        let mockFlickr = Flickr(title: "", link: "", flickrDescription: "", modified: "", generator: "",
                                items:[
                                    Item(title: "", link: "", media: Media(m: "http://some.com"),
                                         dateTaken: "datetakendate", itemDescription: "", published: expectedDateString,
                                         author: "", authorID: "", tags: "")
                                ])
                                
        let expectationService = expectation(description: "")
        let mockService = MockFlickrWebService {
            expectationService.fulfill()
            $0(.success(mockFlickr))
        }
        
        let mockDateHandler = MockDateFormatter(relativeStringDateFromDateStringHandler: {
            XCTAssertEqual($0, expectedDateString)
            return "called\($0)"
        })
               
        let sut = PhotosModel(mockService, dateFormatter: mockDateHandler)
        sut.fetch(using: "")
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testStringDateCalledForDateTaken() throws {
        
        let expectedDateString = "datetaken"
        let mockFlickr = Flickr(title: "", link: "", flickrDescription: "", modified: "", generator: "",
                                items:[
                                    Item(title: "", link: "", media: Media(m: "http://some.com"),
                                         dateTaken: expectedDateString, itemDescription: "", published: "",
                                         author: "", authorID: "", tags: "")
                                ])

        let expectationDateHandler = expectation(description: "")
        let expectationService = expectation(description: "")
        let mockService = MockFlickrWebService {
            $0(.success(mockFlickr))
            expectationService.fulfill()
        }

        let mockDateHandler = MockDateFormatter(stringDateFromISODateStringHandler: {
            XCTAssertEqual($0, expectedDateString)
            expectationDateHandler.fulfill()
            return "called\($0)"
        })
     
        let sut = PhotosModel(mockService, dateFormatter: mockDateHandler)
        sut.fetch(using: "")
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    

    func testStringForDateTaken() throws {
        let expectedDateString = "datetaken"
        let mockFlickr = Flickr(title: "", link: "", flickrDescription: "", modified: "", generator: "",
                                items:[Item(title: "", link: "", media: Media(m: "http://some.com"),
                                            dateTaken: expectedDateString, itemDescription: "", published: "",
                                            author: "", authorID: "", tags: "")
                                      ])

        let mockService = MockFlickrWebService {
            $0(.success(mockFlickr))
        }

        let mockDateHandler = MockDateFormatter(stringDateFromISODateStringHandler: {
            XCTAssertEqual($0, expectedDateString)
            return "formatted\($0)"
        })
     
        let sut = PhotosModel(mockService, dateFormatter: mockDateHandler)
        let expectationPhotos = expectation(description: "")
        expectationPhotos.expectedFulfillmentCount = 2
        var photosResult = [PhotoItem]()

        sut.$photos
            .sink { value in
                print(value)
                photosResult = value
                expectationPhotos.fulfill()
            }
            .store(in: &cancellables)

        sut.fetch(using: "")
        waitForExpectations(timeout: 0.1, handler: nil)
        print(photosResult)
        XCTAssertEqual(photosResult.count, 1)
        XCTAssertEqual(photosResult[0].dateTakenString, "formatted" + expectedDateString)
    }
}

class MockFlickrWebService: FlickrWebService {
    func cancel() { }
    
    typealias FetchCompletion = (Result<Flickr, FetchError>) -> ()
    typealias FetchCompletionHandler = (FetchCompletion) -> ()

    func fetchPhotos(searchTerm: String, completion: @escaping (Result<Flickr, FetchError>) -> ()) {
        fetchCompletionHandler?(completion)
    }
    
    private var fetchCompletionHandler: FetchCompletionHandler?
    init(_ fetchCompletion: FetchCompletionHandler? = nil) {
        fetchCompletionHandler = fetchCompletion
    }
}

class MockDateFormatter: PhotoDateFormatting {
    lazy var formatter: DateFormatter = DateFormatter()
    lazy var isoFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
    
    typealias StringDateFromISODateStringHandler = (String) -> String
    typealias RelativeStringDateFromDateStringHandler = (String) -> String

    //    item.dateTakenString = self?.dateFormatter?.stringDateFromISODateString($0.dateTaken) ?? ""

    private var stringDateFromISODateStringHandler: StringDateFromISODateStringHandler?

    //    item.published = self?.dateFormatter?.relativeStringDateFromDateString($0.published) ?? ""

    private var relativeStringDateFromDateStringHandler: RelativeStringDateFromDateStringHandler?

    // DATESTR
    
    func relativeStringDateFromDateString(_ dateString: String) -> String {
        relativeStringDateFromDateStringHandler?(dateString) ?? ""
    }
    
    func stringDateFromDateString(_ dateString: String) -> String { "" }
    
    // ISO
    
    func stringDateFromISODateString(_ dateString: String) -> String {
        stringDateFromISODateStringHandler?(dateString) ?? ""
    }
    
    func relativeStringDateFromISODateString(_ dateString: String) -> String { "" }
    
    /// init
    init(stringDateFromISODateStringHandler: StringDateFromISODateStringHandler? = nil,
         relativeStringDateFromDateStringHandler: RelativeStringDateFromDateStringHandler? = nil
    ) {
        self.stringDateFromISODateStringHandler = stringDateFromISODateStringHandler
        self.relativeStringDateFromDateStringHandler = relativeStringDateFromDateStringHandler
    }
}
