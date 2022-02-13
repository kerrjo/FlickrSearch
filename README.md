# FlickrSearch

built with Xcode _Version 13.2.1 (13C100)_


<img width="319" alt="Screen Shot 2022-02-11 at 6 12 05 PM" src="https://user-images.githubusercontent.com/12850537/153683428-5637beb2-22e4-477b-b915-1249006c93f0.png">

A branch called `submitted` https://github.com/kerrjo/FlickrSearch/tree/submitted was created at the TimeLimit mark in case i commit or push to `main` after the fact.


## Issues and Concerns

The 3 hour time limit had many design decisions be prioritized.

### quicktyp io mishandling unicode
quicktyp io had an issue with the json results: **Invalid Reverse Solidus '\' declaration._**

unicode characters

\u00fc
```
{
  "title": "F\u00fctterung",
  "link": "https:\/\/www.flickr.com\/photos\/157157091@N07\/51851795689\/",
  "media": {"m":"https:\/\/live.staticflickr.com\/65535\/51851795689_a362183e1d_m.jpg"},
  "date_taken": "2022-01-18T15:42:19-08:00",
  "description": " <p><a href=\"https:\/\/www.flickr.com\/people\/157157091@N07\/\">HappeHap04<\/a> posted a photo:<\/p> <p><a href=\"https:\/\/www.flickr.com\/photos\/157157091@N07\/51851795689\/\" title=\"F\u00fctterung\"><img src=\"https:\/\/live.staticflickr.com\/65535\/51851795689_a362183e1d_m.jpg\" width=\"240\" height=\"160\" alt=\"F\u00fctterung\" \/><\/a><\/p> ",
  "published": "2022-01-30T09:11:39Z",
  "author": "nobody@flickr.com (\"HappeHap04\")",
  "author_id": "157157091@N07",
  "tags": "stachelschwein porcupine"
}
```
I removed any items similar and basically provided one or two items that would pass

### quicktyp io Date

quicktype io used the type `Date` instead of `String` for 

After the `Codable` was available I began running fetches. A json `.parse` error kept happening, i thought it was more of the `\u000c` erros, but was indeed date handling
```
			"date_taken": "2021-11-05T23:07:55-08:00",
			"published": "2022-01-14T01:33:57Z",
```
These had to be changed and the date formatted separately
```
struct Item: Codable {
    let title: String
    let link: String
    let media: Media
    let dateTaken: Date
    let itemDescription: String
    let published: Date
    let author, authorID, tags: String
```
These two issues took more time than i expected.


### UIImage and size for width and height

After the service was retrieving the results correctly I was able to begin processing the `ContentView`

I originally planned on using UIImage from data, and create an `Image` View from it. I had planned this so I could get the image size width and height from UIImage size property.  However, instead I used `AsyncImage()` to get a quick run of the results. I knew I had a challenge in front of with the `NavigationLink`.

Width and Height is discoverable in the description

...in a _hyperlink_ , in  <img> tag is used to embed an image in an HTML page. ... src - Specifies the path to the image.
```
"description": " <p><a href=\"https:\/\/www.flickr.com\/people\/geelog\/\">geelog<\/a> posted a photo:<\/p> <p><a href=\"https:\/\/www.flickr.com\/photos\/geelog\/51873892304\/\" title=\"Porcupine\"><img src=\"https:\/\/live.staticflickr.com\/65535\/51873892304_a30856c528_m.jpg\" width=\"240\" height=\"160\" alt=\"Porcupine\" \/><\/a><\/p> ",
```

I am not sure what the requirement was asking for width and height

i did find reference to flickr photos where by the image url can be suffixed with a size type
```
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
```

the plan was to, for example, strip the \_m and append \_t for Thumbnail for search results. then use \_b or \_c for the Detail.
but then again _Time_ is a factor.

### Broad solution vs deep

Instead of going deep in any one area i chose to go broad, 
- basic input, instead of `.searchable` on NavigationView
- submit request on every letter change in text, instead of debouncing, and min character
- unit tests that perform basic integration tests
- the detail view uses a simple struct instead of an @ObeservedObject of the viewModel
- NavigationLink is the image as opposed to a `EmptyView()` NavigationLink with `isDetailDisplayed` `@State` property.

### One unit test took a substantial amount of time

I wanted more tests, from the mocks provided many more tests could be performed

```
 func testStringForDateTaken() throws {
        let expectedDateString = "datetaken"
        let mockFlickr = Flickr(title: "", link: "", flickrDescription: "", modified: "", generator: "",
                                items:[Item(title: "", link: "", media: Media(m: "http://some.com"),
                                            dateTaken: expectedDateString, itemDescription: "", published: "",
                                            author: "", authorID: "", tags: "")
                                      ])
```
here, i wanted to test that the date formatter returns the expected data

pretty much mocking output from the service call and checking results

what ended up being a working solution is to subscribe to to the publisher before checking.

```
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
```
From this one test, many more tests can be derived from the same pattern.
- check count on success
- check count 0 on error any of teh fetch errors
- proper image url
- proper date formatting (mock the service, but use the real date formatter)
- author formatting


### The canvas was not used and needs to be to fine tune layout

Didnt have time to supply data to the view for preview


## Usage

Deployment target must be 15 + as `AsyncImage()` is used to display image from url.

Tap the _Search_ field to enter search tag. Results shoud begin showing if any are found.

<img width="319" alt="Screen Shot 2022-02-11 at 6 08 36 PM" src="https://user-images.githubusercontent.com/12850537/153683248-6e11425f-656c-4375-9974-1bc5b78f77b5.png">

Tap on an image to see detail

<img width="319" alt="Screen Shot 2022-02-11 at 6 12 15 PM" src="https://user-images.githubusercontent.com/12850537/153683451-feec656f-edfd-4054-ab96-6460d2a32bea.png">

Tap the left _Flickr Photos_ navigationItem to go back to search results.

Change the text size in system settings if you wish

<img width="319" alt="Screen Shot 2022-02-11 at 6 12 44 PM" src="https://user-images.githubusercontent.com/12850537/153683471-50bc9c1e-47a7-4a3f-90bd-af4f8f2359c2.png">

Detail will show larger text as well

<img width="319" alt="Screen Shot 2022-02-11 at 6 12 49 PM" src="https://user-images.githubusercontent.com/12850537/153683481-8ca37e58-73e5-4819-a6c6-8d72d2d660a8.png">


## Content Changes Quickly

Typing "Doghouse" for example will show dogs if you pause long enough.

<img width="319" alt="Screen Shot 2022-02-11 at 6 08 49 PM" src="https://user-images.githubusercontent.com/12850537/153683263-1c77b448-a419-48b7-936d-9295cae31d7d.png">

<img width="319" alt="Screen Shot 2022-02-11 at 6 09 05 PM" src="https://user-images.githubusercontent.com/12850537/153683276-d33bf68e-ea14-44de-a5af-e218ee5df23f.png">

<img width="319" alt="Screen Shot 2022-02-11 at 6 09 13 PM" src="https://user-images.githubusercontent.com/12850537/153683285-9ac80651-c186-4548-9333-9c45761a4d63.png">

Scroll to images that appear offscreen.

<img width="319" alt="Screen Shot 2022-02-11 at 6 10 13 PM" src="https://user-images.githubusercontent.com/12850537/153683301-ac1ad904-36ac-4721-a7ad-410c8e94d77d.png">
<img width="319" alt="Screen Shot 2022-02-11 at 6 10 18 PM" src="https://user-images.githubusercontent.com/12850537/153683324-b08cf4f5-eb5e-446f-9c00-b23b39e4490b.png">
<img width="319" alt="Screen Shot 2022-02-11 at 6 10 31 PM" src="https://user-images.githubusercontent.com/12850537/153683358-7f1b3a0a-3cf4-4141-beea-7df5a5344195.png">

<img width="319" alt="Screen Shot 2022-02-11 at 6 10 59 PM" src="https://user-images.githubusercontent.com/12850537/153683376-9f998843-1500-43fc-bfca-2f5091633dc2.png">
<img width="319" alt="Screen Shot 2022-02-11 at 6 11 04 PM" src="https://user-images.githubusercontent.com/12850537/153683385-b6bad1b9-5cdf-4f7b-8653-1fcacff99238.png">
<img width="319" alt="Screen Shot 2022-02-11 at 6 11 09 PM" src="https://user-images.githubusercontent.com/12850537/153683400-321fa490-e66a-4d0b-993f-10ee207a1239.png">


# Enhancements

the branch enhancements https://github.com/kerrjo/FlickrSearch/tree/enhancements
already has imporvements

PR #1 https://github.com/kerrjo/FlickrSearch/pull/1

adds higher resolution images for detail 

and adds debouncing for Text entry

<img width="660" alt="image" src="https://user-images.githubusercontent.com/12850537/153743354-98b4cd7b-413e-443c-8675-75bcd5f355cd.png">



