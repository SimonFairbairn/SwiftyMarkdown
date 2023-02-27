//
//  SwiftyScanner.swift
//  
//
//  Created by Simon Fairbairn on 04/04/2020.
//

//
//  SwiftyScanner.swift
//  SwiftyMarkdown
//
//  Created by Simon Fairbairn on 04/02/2020.
//

import Foundation
import os.log

extension OSLog {
	private static var subsystem = "SwiftyScanner"
	static let swiftyScanner = OSLog(subsystem: subsystem, category: "Swifty Scanner Scanner")
	static let swiftyScannerPerformance = OSLog(subsystem: subsystem, category: "Swifty Scanner Scanner Peformance")
}

enum RepeatingTagType {
	case open
	case either
	case close
	case neither
}

struct TagGroup {
	let groupID  = UUID().uuidString
	var tagRanges : [ClosedRange<Int>]
	var tagType : RepeatingTagType = .open
	var count = 1
}

class SwiftyScanner {
	var elements : [Element]
	let rule : CharacterRule
	let metadata : [String : String]
	var pointer : Int = 0
	
	var spaceAndNewLine = CharacterSet.whitespacesAndNewlines
	var tagGroups : [TagGroup] = []
	
	var isMetadataOpen = false
	
	
	var enableLog = (ProcessInfo.processInfo.environment["SwiftyScannerScanner"] != nil)
	
	let currentPerfomanceLog = PerformanceLog(with: "SwiftyScannerScannerPerformanceLogging", identifier: "Scanner", log: OSLog.swiftyScannerPerformance)
	let log = PerformanceLog(with: "SwiftyScannerScanner", identifier: "Scanner", log: OSLog.swiftyScanner)
		
	
	
	enum Position {
		case forward(Int)
		case backward(Int)
	}
	
	init( withElements elements : [Element], rule : CharacterRule, metadata : [String : String]) {
		self.elements = elements
		self.rule = rule
		self.currentPerfomanceLog.start()
		self.metadata = metadata
	}
	
	func elementsBetweenCurrentPosition( and newPosition : Position ) -> [Element]? {
		
		let newIdx : Int
		var isForward = true
		switch newPosition {
		case .backward(let positions):
			isForward = false
			newIdx = pointer - positions
			if newIdx < 0 {
				return nil
			}
		case .forward(let positions):
			newIdx = pointer + positions
			if newIdx >= self.elements.count {
				return nil
			}
		}
		
		
		let range : ClosedRange<Int> = ( isForward ) ? self.pointer...newIdx : newIdx...self.pointer
		return Array(self.elements[range])
	}
	
	
	func element( for position : Position ) -> Element? {
		let newIdx : Int
		switch position {
		case .backward(let positions):
			newIdx = pointer - positions
			if newIdx < 0 {
				return nil
			}
		case .forward(let positions):
			newIdx = pointer + positions
			if newIdx >= self.elements.count {
				return nil
			}
		}
		return self.elements[newIdx]
	}
	
	
	func positionIsEqualTo( character : Character, direction : Position ) -> Bool {
		guard let validElement = self.element(for: direction) else {
			return false
		}
		return validElement.character == character
	}
	
	func positionContains( characters : [Character], direction : Position ) -> Bool {
		guard let validElement = self.element(for: direction) else {
			return false
		}
		return characters.contains(validElement.character)
	}
	
	func isEscaped() -> Bool {
		let isEscaped = self.positionContains(characters: self.rule.escapeCharacters, direction: .backward(1))
		if isEscaped {
			self.elements[self.pointer - 1].type = .escape
		}
		return isEscaped
	}
	
	func range( for tag : String? ) -> ClosedRange<Int>? {

		guard let tag = tag else {
			return nil
		}
		
		guard let openChar = tag.first else {
			return nil
		}
		
		if self.pointer == self.elements.count {
			return nil
		}
		
		if self.elements[self.pointer].character != openChar {
			return nil
		}
		
		if isEscaped() {
			return nil
		}
		
		let range : ClosedRange<Int>
		if tag.count > 1 {
			guard let elements = self.elementsBetweenCurrentPosition(and: .forward(tag.count - 1) ) else {
				return nil
			}
			// If it's already a tag, then it should be ignored
			if elements.filter({ $0.type != .string }).count > 0 {
				return nil
			}
			if elements.map( { String($0.character) }).joined() != tag {
				return nil
			}
			let endIdx = (self.pointer + tag.count - 1)
			for i in self.pointer...endIdx {
				self.elements[i].type = .tag
			}
			range = self.pointer...endIdx
			self.pointer += tag.count
		} else {
			// If it's already a tag, then it should be ignored
			if self.elements[self.pointer].type != .string {
				return nil
			}
			self.elements[self.pointer].type = .tag
			range = self.pointer...self.pointer
			self.pointer += 1
		}
		return range
	}
	
	
	func resetTagGroup( withID id : String ) {
		if let idx = self.tagGroups.firstIndex(where: { $0.groupID == id }) {
			for range in self.tagGroups[idx].tagRanges {
				self.resetTag(in: range)
			}
			self.tagGroups.remove(at: idx)
		}
		self.isMetadataOpen = false
	}
	
	func resetTag( in range : ClosedRange<Int>) {
		for idx in range {
			self.elements[idx].type = .string
		}
	}
	
	func resetLastTag( for range : inout [ClosedRange<Int>]) {
		guard let last = range.last else {
			return
		}
		for idx in last {
			self.elements[idx].type = .string
		}
	}
	
	func closeTag( _ tag : String, withGroupID id : String ) {

		guard let tagIdx = self.tagGroups.firstIndex(where: { $0.groupID == id }) else {
			return
		}

		var metadataString = ""
		if self.isMetadataOpen {
			let metadataCloseRange = self.tagGroups[tagIdx].tagRanges.removeLast()
			let metadataOpenRange = self.tagGroups[tagIdx].tagRanges.removeLast()
			
			if metadataOpenRange.upperBound + 1 == (metadataCloseRange.lowerBound) {
				if self.enableLog {
					os_log("Nothing between the tags", log: OSLog.swiftyScanner, type:.info , self.rule.description)
				}
			} else {
				for idx in (metadataOpenRange.upperBound)...(metadataCloseRange.lowerBound) {
					self.elements[idx].type = .metadata
					if self.rule.definesBoundary {
						self.elements[idx].boundaryCount += 1
					}
				}
				
				
				let key = self.elements[metadataOpenRange.upperBound + 1..<metadataCloseRange.lowerBound].map( { String( $0.character )}).joined()
				if self.rule.metadataLookup {
					metadataString = self.metadata[key] ?? ""
				} else {
					metadataString = key
				}
			}
		}
		
		let closeRange = self.tagGroups[tagIdx].tagRanges.removeLast()
		let openRange = self.tagGroups[tagIdx].tagRanges.removeLast()

		if self.rule.balancedTags && closeRange.count != openRange.count {
			self.tagGroups[tagIdx].tagRanges.append(openRange)
			self.tagGroups[tagIdx].tagRanges.append(closeRange)
			return
		}

		var shouldRemove = true
		var styles : [CharacterStyling] = []
		if openRange.upperBound + 1 == (closeRange.lowerBound) {
			if self.enableLog {
				os_log("Nothing between the tags", log: OSLog.swiftyScanner, type:.info , self.rule.description)
			}
		} else {
			var remainingTags = min(openRange.upperBound - openRange.lowerBound, closeRange.upperBound - closeRange.lowerBound) + 1
			while remainingTags > 0 {
				let shouldAppendStyle = remainingTags >= self.rule.maxTags
				if shouldAppendStyle {
					remainingTags -= self.rule.maxTags
					if let style = self.rule.styles[ self.rule.maxTags ] {
						if !styles.contains(where: { $0.isEqualTo(style)}) {
							styles.append(style)
						}
					}
				}

				let remainingTagsStyle = self.rule.styles[remainingTags]
				if let style = remainingTagsStyle {
					remainingTags -= remainingTags
					if !styles.contains(where: { $0.isEqualTo(style)}) {
						styles.append(style)
					}
				}

				if !shouldAppendStyle && remainingTagsStyle == nil {
					break
				}
			}
			
			for idx in (openRange.upperBound)...(closeRange.lowerBound) {
				self.elements[idx].styles.append(contentsOf: styles)
				self.elements[idx].metadata.append(metadataString)
				if self.rule.definesBoundary {
					self.elements[idx].boundaryCount += 1
				}
				if self.rule.shouldCancelRemainingRules {
					self.elements[idx].boundaryCount = 1000
				}
			}
			
			if self.rule.isRepeatingTag {
				let difference = ( openRange.upperBound - openRange.lowerBound ) - (closeRange.upperBound - closeRange.lowerBound)
				switch difference {
				case 1...:
					shouldRemove = false
					self.tagGroups[tagIdx].count = difference
					self.tagGroups[tagIdx].tagRanges.append( openRange.upperBound - (abs(difference) - 1)...openRange.upperBound )
				case ...(-1):
					for idx in closeRange.upperBound - (abs(difference) - 1)...closeRange.upperBound {
						self.elements[idx].type = .string
					}
				default:
					break
				}
			}
			
		}
		if shouldRemove {
			self.tagGroups.removeAll(where: { $0.groupID == id })
		}
		self.isMetadataOpen = false
	}
	
	func emptyRanges( _ ranges : inout [ClosedRange<Int>] ) {
		while !ranges.isEmpty {
			self.resetLastTag(for: &ranges)
			ranges.removeLast()
		}
	}
	
	func scanNonRepeatingTags() {
		var groupID = ""
		let closeTag = self.rule.tag(for: .close)?.tag
		let metadataOpen = self.rule.tag(for: .metadataOpen)?.tag
		let metadataClose = self.rule.tag(for: .metadataClose)?.tag
		
		while self.pointer < self.elements.count {
			if self.enableLog {
				os_log("CHARACTER: %@", log: OSLog.swiftyScanner, type:.info , String(self.elements[self.pointer].character))
			}
			
			if let range = self.range(for: metadataClose) {
				if self.isMetadataOpen {
					guard let groupIdx = self.tagGroups.firstIndex(where: { $0.groupID == groupID }) else {
						self.pointer += 1
						continue
					}
					
					guard !self.tagGroups.isEmpty else {
						self.resetTagGroup(withID: groupID)
						continue
					}
				
					guard self.isMetadataOpen else {
						
						self.resetTagGroup(withID: groupID)
						continue
					}
					if self.enableLog {
						os_log("Closing metadata tag found. Closing tag with ID %@", log: OSLog.swiftyScanner, type:.info , groupID)
					}
					self.tagGroups[groupIdx].tagRanges.append(range)
					self.closeTag(closeTag!, withGroupID: groupID)
					self.isMetadataOpen = false
					continue
				} else {
					self.resetTag(in: range)
					self.pointer -= metadataClose!.count
				}

			}
			
			if let openRange = self.range(for: self.rule.primaryTag.tag) {
				if self.isMetadataOpen {
					self.resetTagGroup(withID: groupID)
				}
				
				let tagGroup = TagGroup(tagRanges: [openRange])
				groupID = tagGroup.groupID
				if self.enableLog {
					os_log("New open tag found. Starting new Group with ID %@", log: OSLog.swiftyScanner, type:.info , groupID)
				}
				if self.rule.isRepeatingTag {
					
				}
				
				self.tagGroups.append(tagGroup)
				continue
			}
	
			if let range = self.range(for: closeTag) {
				guard !self.tagGroups.isEmpty else {
					if self.enableLog {
						os_log("No open tags exist, resetting this close tag", log: OSLog.swiftyScanner, type:.info)
					}
					self.resetTag(in: range)
					continue
				}
				self.tagGroups[self.tagGroups.count - 1].tagRanges.append(range)
				groupID = self.tagGroups[self.tagGroups.count - 1].groupID
				if self.enableLog {
					os_log("New close tag found. Appending to group with ID %@", log: OSLog.swiftyScanner, type:.info , groupID)
				}
				guard metadataOpen != nil else {
					if self.enableLog {
						os_log("No metadata tags exist, closing valid tag with ID %@", log: OSLog.swiftyScanner, type:.info , groupID)
					}
					self.closeTag(closeTag!, withGroupID: groupID)
					continue
				}
				
				guard self.pointer != self.elements.count else {
					continue
				}
				
				guard let range = self.range(for: metadataOpen) else {
					if self.enableLog {
						os_log("No metadata tag found, resetting group with ID %@", log: OSLog.swiftyScanner, type:.info , groupID)
					}
					self.resetTagGroup(withID: groupID)
					continue
				}
				self.tagGroups[self.tagGroups.count - 1].tagRanges.append(range)
				self.isMetadataOpen = true
				continue
			}
			

			if let range = self.range(for: metadataOpen) {
				if self.enableLog {
					os_log("Multiple open metadata tags found!", log: OSLog.swiftyScanner, type:.info , groupID)
				}
				self.resetTag(in: range)
				self.resetTagGroup(withID: groupID)
				self.isMetadataOpen = false
				continue
			}
			self.pointer += 1
		}
	}
	
	func scanRepeatingTags() {
				
		var groupID = ""
		let escapeCharacters = "" //self.rule.escapeCharacters.map( { String( $0 ) }).joined()
		let unionSet = spaceAndNewLine.union(CharacterSet(charactersIn: escapeCharacters))
		while self.pointer < self.elements.count {
			if self.enableLog {
				os_log("CHARACTER: %@", log: OSLog.swiftyScanner, type:.info , String(self.elements[self.pointer].character))
			}
			
			if var openRange = self.range(for: self.rule.primaryTag.tag) {
				
				if self.elements[openRange].first?.boundaryCount == 1000 {
					self.resetTag(in: openRange)
					continue
				}
				
				var count = 1
				var tagType : RepeatingTagType = .open
				if let prevElement = self.element(for: .backward(self.rule.primaryTag.tag.count + 1))  {
					if !unionSet.containsUnicodeScalars(of: prevElement.character) {
						tagType = .either
					}
				} else {
					tagType = .open
				}
				
				while let nextRange = self.range(for: self.rule.primaryTag.tag)  {
					count += 1
					openRange = openRange.lowerBound...nextRange.upperBound
				}
				
				if self.rule.minTags > 1 {
					if (openRange.upperBound - openRange.lowerBound) + 1 < self.rule.minTags {
						self.resetTag(in: openRange)
						os_log("Tag does not meet minimum length", log: .swiftyScanner, type: .info)
						continue
					}
				}
				
				var validTagGroup = true
				if let nextElement = self.element(for: .forward(0)) {
					if unionSet.containsUnicodeScalars(of: nextElement.character) {
						if tagType == .either {
							tagType = .close
						} else {
							validTagGroup = tagType != .open
						}
					}
				} else {
					if tagType == .either {
						tagType = .close
					} else {
						validTagGroup = tagType != .open
					}
				}
				
				if !validTagGroup {
					if self.enableLog {
						os_log("Tag has whitespace on both sides", log: .swiftyScanner, type: .info)
					}
					self.resetTag(in: openRange)
					continue
				}
				
				if let idx = tagGroups.firstIndex(where: { $0.groupID == groupID }) {
					if tagType == .either {
						if tagGroups[idx].count == count {
							self.tagGroups[idx].tagRanges.append(openRange)
							self.closeTag(self.rule.primaryTag.tag, withGroupID: groupID)
							
							if let last = self.tagGroups.last {
								groupID = last.groupID
							}
							
							continue
						}
					} else {
						if let prevRange = tagGroups[idx].tagRanges.first {
							if self.elements[prevRange].first?.boundaryCount == self.elements[openRange].first?.boundaryCount {
								self.tagGroups[idx].tagRanges.append(openRange)
								self.closeTag(self.rule.primaryTag.tag, withGroupID: groupID)
							}
						}
						continue
					}
				}
				var tagGroup = TagGroup(tagRanges: [openRange])
				groupID = tagGroup.groupID
				tagGroup.tagType = tagType
				tagGroup.count = count
				
				if self.enableLog {
					os_log("New open tag found with characters %@. Starting new Group with ID %@", log: OSLog.swiftyScanner,  type:.info, self.elements[openRange].map( { String($0.character) }).joined(), groupID)
				}
				
				self.tagGroups.append(tagGroup)
				continue
			}
	
			self.pointer += 1
		}
	}
	
	
	func scan() -> [Element] {
		
		guard self.elements.filter({ $0.type == .string }).map({ String($0.character) }).joined().contains(self.rule.primaryTag.tag) else {
			return self.elements
		}
		
		self.currentPerfomanceLog.tag(with: "Beginning \(self.rule.primaryTag.tag)")
		
		if self.enableLog {
			os_log("RULE: %@", log: OSLog.swiftyScanner, type:.info , self.rule.description)
		}
		
		if self.rule.isRepeatingTag {
			self.scanRepeatingTags()
		} else {
			self.scanNonRepeatingTags()
		}
		
		for tagGroup in self.tagGroups {
			self.resetTagGroup(withID: tagGroup.groupID)
		}
		
		if self.enableLog {
			for element in self.elements {
				print(element)
			}
		}
		return self.elements
	}
}
