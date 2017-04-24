//
//  Parser.swift
//  SwiftCSV
//
//  Created by Will Richardson on 11/04/16.
//  Copyright © 2016 JavaNut13. All rights reserved.
//

extension CSV {
    /// List of dictionaries that contains the CSV data
    public func rows() throws -> [[String: String]] {
        if _rows == nil {
            try parse()
        }
        return _rows!
    }
    
    /// Dictionary of header name to list of values in that column
    /// Will not be loaded if loadColumns in init is false
    public func columns() throws -> [String: [String]] {
        if !loadColumns {
            return [:]
        } else if _columns == nil {
            try parse()
        }
        return _columns!
    }
    
    /// Parse the file and call a block for each row, passing it as a dictionary
    public func enumerateAsDict(block: @escaping ([String: String]) -> ()) throws {
        let enumeratedHeader = header.enumerated()
        
        try enumerateAsArray { fields in
            var dict = [String: String]()
            for (index, head) in enumeratedHeader {
                dict[head] = index < fields.count ? fields[index] : ""
            }
            block(dict)
        }
    }
    
    /// Parse the file and call a block on each row, passing it in as a list of fields
    public func enumerateAsArray(block: @escaping ([String]) -> ()) throws {
        try self.enumerateAsArray(block: block, limitTo: nil, startAt: 1)
    }
    
    private func parse() throws {
        var rows = [[String: String]]()
        var columns = [String: [String]]()
        
        try enumerateAsDict { dict in
            rows.append(dict)
        }

        if loadColumns {
            for field in header {
                columns[field] = rows.map { $0[field] ?? "" }
            }
        }
        
        _columns = columns
        _rows = rows
    }
}
