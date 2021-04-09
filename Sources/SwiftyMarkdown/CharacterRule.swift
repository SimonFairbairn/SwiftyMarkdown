//
//  CharacterRule.swift
//  SwiftyMarkdown
//
//  Created by Simon Fairbairn on 04/02/2020.
//

import Foundation

public enum SpaceAllowed {
	case no
	case bothSides
	case oneSide
	case leadingSide
	case trailingSide
}

public enum Cancel {
	case none
	case allRemaining
	case currentSet
}

public enum CharacterRuleTagType {
	case open
	case close
	case metadataOpen
	case metadataClose
	case repeating
}


public struct CharacterRuleTag {
	let tag : String
	let type : CharacterRuleTagType
	
	public init( tag : String, type : CharacterRuleTagType ) {
		self.tag = tag
		self.type = type
	}
}

public struct CharacterRule : CustomStringConvertible {
	
	public let primaryTag : CharacterRuleTag
	public let tags : [CharacterRuleTag]
	public let escapeCharacters : [Character]
	public var styles : [Int : CharacterStyling]
	public let minTags : Int
	public let maxTags : Int
	public var metadataLookup : Bool = false
	public var isRepeatingTag : Bool {
		return self.primaryTag.type == .repeating
	}
	public var definesBoundary = false
	public var shouldCancelRemainingRules = false
	public var balancedTags = false
	
	public var description: String {
		return "Character Rule with Open tag: \(self.primaryTag.tag) and current styles : \(self.styles) "
	}
	
	public func tag( for type : CharacterRuleTagType ) -> CharacterRuleTag? {
		return self.tags.filter({ $0.type == type }).first ?? nil
	}
	
	public init(primaryTag: CharacterRuleTag, otherTags: [CharacterRuleTag], escapeCharacters : [Character] = ["\\"], styles: [Int : CharacterStyling] = [:], minTags : Int = 1, maxTags : Int = 1, metadataLookup : Bool = false, definesBoundary : Bool = false, shouldCancelRemainingRules : Bool = false, balancedTags : Bool = false) {
		self.primaryTag = primaryTag
		self.tags = otherTags
		self.escapeCharacters = escapeCharacters
		self.styles = styles
		self.metadataLookup = metadataLookup
		self.definesBoundary = definesBoundary
		self.shouldCancelRemainingRules = shouldCancelRemainingRules
		self.minTags = maxTags < minTags ? maxTags : minTags
		self.maxTags = minTags > maxTags ? minTags : maxTags
		self.balancedTags = balancedTags
	}
}



enum ElementType {
	case tag
	case escape
	case string
	case space
	case newline
	case metadata
}

struct Element {
	let character : Character
	var type : ElementType
	var boundaryCount : Int = 0
	var isComplete : Bool = false
	var styles : [CharacterStyling] = []
	var metadata : [String] = []
}

extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy(contains(_:))
    }
}



