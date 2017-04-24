//
//  Parser.swift
//  SwiftCSV
//
//  Created by Will Richardson on 13/04/16.
//  Copyright © 2016 Naoto Kaneko. All rights reserved.
//


public enum ParserError: Swift.Error, CustomStringConvertible{
    
    case nonQuote(String, Character)
    case meIRL(String)
    
    public var description: String {
        
        switch self {
        case .nonQuote(let source, let char):
            return "Can't have non-quote character \(char) in \(source)"
        case .meIRL(let source):
            return "me_irl error in \(source)"
        }
    }
    
    public var localizedDescription: String {
        return description
    }
}

extension CSV {
    /// Parse the file and call a block on each row, passing it in as a list of fields
    /// limitTo will limit the result to a certain number of lines
    func enumerateAsArray(block: @escaping ([String]) -> (), limitTo: Int?, startAt: Int = 0) throws {
        var currentIndex = text.startIndex
        let endIndex = text.endIndex
        
        var atStart = true
        var parsingField = false
        var parsingQuotes = false
        var innerQuotes = false
        
        var fields = [String]()
        var field = [Character]()
        
        var count = 0
        let doLimit = limitTo != nil
        
        let callBlock: () -> () = {
            fields.append(String(field))
            if count >= startAt {
                block(fields)
            }
            count += 1
            fields = [String]()
            field = [Character]()
        }
        
        let changeState: (Character) throws -> (Bool) = { char in
            if atStart {
                if char == "\"" {
                    atStart = false
                    parsingQuotes = true
                } else if char == self.delimiter {
                    fields.append(String(field))
                    field = [Character]()
                } else if CSV.isNewline(char: char) {
                    callBlock()
                } else {
                    parsingField = true
                    atStart = false
                    field.append(char)
                }
            } else if parsingField {
                if innerQuotes {
                    if char == "\"" {
                        field.append(char)
                        innerQuotes = false
                    } else {
                        throw ParserError.nonQuote(self.fileName, char)
                    }
                } else {
                    if char == "\"" {
                        innerQuotes = true
                    } else if char == self.delimiter {
                        atStart = true
                        parsingField = false
                        innerQuotes = false
                        fields.append(String(field))
                        field = [Character]()
                    } else if CSV.isNewline(char: char) {
                        atStart = true
                        parsingField = false
                        innerQuotes = false
                        callBlock()
                    } else {
                        field.append(char)
                    }
                }
            } else if parsingQuotes {
                if innerQuotes {
                    if char == "\"" {
                        field.append(char)
                        innerQuotes = false
                    } else if char == self.delimiter {
                        atStart = true
                        parsingField = false
                        innerQuotes = false
                        fields.append(String(field))
                        field = [Character]()
                    } else if CSV.isNewline(char: char) {
                        atStart = true
                        parsingQuotes = false
                        innerQuotes = false
                        callBlock()
                    } else {
                        throw ParserError.nonQuote(self.fileName, char)
                    }
                } else {
                    if char == "\"" {
                        innerQuotes = true
                    } else {
                        field.append(char)
                    }
                }
            } else {
                throw ParserError.meIRL(self.fileName)
            }
            return doLimit && count >= limitTo!
        }
        
        while currentIndex < endIndex {
            let char = text[currentIndex]
            if try changeState(char) {
                break
            }
            currentIndex = text.index(after: currentIndex)
        }
        
        if fields.count != 0 || field.count != 0 || (doLimit && count < limitTo!) {
            fields.append(String(field))
            block(fields)
        }
    }
    
    private static func isNewline(char: Character) -> Bool {
        return char == "\n" || char == "\r\n"
    }
}
