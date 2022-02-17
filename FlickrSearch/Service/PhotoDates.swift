//
//  PhotoDates.swift
//  FlickrSearch
//
//  Created by JOSEPH KERR on 2/11/22.
//

import Foundation



protocol PhotoDateFormatting {
    var formatter: DateFormatter { get }
    var isoFormatter: ISO8601DateFormatter { get }
    var timeFormatter: RelativeDateTimeFormatter { get }
    
    func stringDateFromDateString(_ dateString: String) -> String
    func stringDateFromISODateString(_ dateString: String) -> String
    
    func relativeStringDateFromDateString(_ dateString: String) -> String
    func relativeStringDateFromISODateString(_ dateString: String) -> String
}

extension PhotoDateFormatting {
    // normal
    
    func relativeStringDateFromDateString(_ dateString: String) -> String {
        guard  let date = dateFromString(dateString) else { return "" }
        return relativeStringForDate(date)
    }
    
    func stringDateFromDateString(_ dateString: String) -> String {
        guard  let date = dateFromString(dateString) else { return "" }
        return stringForDate(date)
    }
    
    // iso
    
    func stringDateFromISODateString(_ dateString: String) -> String {
        guard  let date = isoDateFromString(dateString) else { return "" }
        return stringForDate(date)
    }
    
    func relativeStringDateFromISODateString(_ dateString: String) -> String {
        guard  let date = isoDateFromString(dateString) else { return "" }
        return relativeStringForDate(date)
    }
    
    // let date_taken = "2022-02-07T15:53:00-08:00"
    
    private func isoDateFromString(_ dateString: String) -> Date? {
        isoFormatter.timeZone = TimeZone.current
        guard let date = isoFormatter.date(from: dateString) else { return nil }
        return date
    }
    
    // let published = "2022-02-08T14:11:09Z"
    
    private func dateFromString(_ dateString: String) -> Date? {
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: dateString) else { return nil }
        return date
    }
    
    private func stringForDate(_ date: Date) -> String {
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func relativeStringForDate(_ date: Date) -> String {
        let timeFormatter = RelativeDateTimeFormatter()
        timeFormatter.dateTimeStyle = .numeric
        guard let result = timeFormatter.string(for: date) else { return "" }
        return result
    }
}

/**
 Date and Time formatting for photos
 */

class PhotoDates {
    private(set) lazy var isoFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
    private(set) lazy var formatter: DateFormatter = DateFormatter()
    private(set) lazy var timeFormatter: RelativeDateTimeFormatter = RelativeDateTimeFormatter()
}

extension PhotoDates: PhotoDateFormatting { }
