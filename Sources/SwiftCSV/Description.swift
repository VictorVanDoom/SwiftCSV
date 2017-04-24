//
//  Description.swift
//  SwiftCSV
//
//  Created by Will Richardson on 11/04/16.
//  Copyright © 2016 Naoto Kaneko. All rights reserved.
//

import Foundation

extension CSV: CustomStringConvertible {
    public var description: String {
        let head = header.joined(separator: ",") + "\n"
        
        do {
            
            let cont = try rows().map { row in
                header.map { row[$0]! }.joined(separator: ",")
                }.joined(separator: "\n")
            return head + cont
            
        } catch let error {
            return "An error occured. \(error)"
        }
    }
}
