//
//  SwiftyMarkdown.swift
//  SwiftyMarkdown
//
//  Created by Simon Fairbairn on 05/03/2016.
//  Copyright © 2016 Voyage Travel Apps. All rights reserved.
//

import UIKit


public protocol FontProperties {
	var fontName : String? { get set }
	var color : UIColor { get set }
}


/**
A struct defining the styles that can be applied to the parsed Markdown. The `fontName` property is optional, and if it's not set then the `fontName` property of the Body style will be applied.

If that is not set, then the system default will be used.
*/
public struct BasicStyles : FontProperties {
	public var fontName : String? = UIFont.preferredFont(forTextStyle: UIFontTextStyleBody).fontName
	public var color = UIColor.black
}

enum LineType : Int {
	case h1, h2, h3, h4, h5, h6, body
}

enum LineStyle : Int {
	case none
	case italic
	case bold
	case code
	case link
	
	static func styleFromString(_ string : String ) -> LineStyle {
		if string == "**" || string == "__" {
			return .bold
		} else if string == "*" || string == "_" {
			return .italic
		} else if string == "`" {
			return .code
		} else if string == "["  {
			return .link
		} else {
			return .none
		}
	}
}

/// A class that takes a [Markdown](https://daringfireball.net/projects/markdown/) string or file and returns an NSAttributedString with the applied styles. Supports Dynamic Type.
public class SwiftyMarkdown {
	
	/// The styles to apply to any H1 headers found in the Markdown
	public var h1 = BasicStyles()

	/// The styles to apply to any H2 headers found in the Markdown
	public var h2 = BasicStyles()
	
	/// The styles to apply to any H3 headers found in the Markdown
	public var h3 = BasicStyles()
	
	/// The styles to apply to any H4 headers found in the Markdown
	public var h4 = BasicStyles()
	
	/// The styles to apply to any H5 headers found in the Markdown
	public var h5 = BasicStyles()
	
	/// The styles to apply to any H6 headers found in the Markdown
	public var h6 = BasicStyles()
	
	/// The default body styles. These are the base styles and will be used for e.g. headers if no other styles override them.
	public var body = BasicStyles()
	
	/// The styles to apply to any links found in the Markdown
	public var link = BasicStyles()

	/// The styles to apply to any bold text found in the Markdown
	public var bold = BasicStyles()
	
	/// The styles to apply to any italic text found in the Markdown
	public var italic = BasicStyles()
	
	/// The styles to apply to any code blocks or inline code text found in the Markdown
	public var code = BasicStyles()

	
	var currentType : LineType = .body

	
	let string : String
	let instructionSet = CharacterSet(charactersIn: "[\\*_`")
	
	/**
	
	- parameter string: A string containing [Markdown](https://daringfireball.net/projects/markdown/) syntax to be converted to an NSAttributedString
	
	- returns: An initialized SwiftyMarkdown object
	*/
	public init(string : String ) {
		self.string = string
	}
	
	/**
	A failable initializer that takes a URL and attempts to read it as a UTF-8 string
	
	- parameter url: The location of the file to read
	
	- returns: An initialized SwiftyMarkdown object, or nil if the string couldn't be read
	*/
	public init?(url : URL ) {
		
		do {
			self.string = try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue) as String
			
		} catch {
			self.string = ""
			fatalError("Couldn't read string")
			return nil
		}
	}
	
	/**
	Generates an NSAttributedString from the string or URL passed at initialisation. Custom fonts or styles are applied to the appropriate elements when this method is called.
	
	- returns: An NSAttributedString with the styles applied
	*/
	public func attributedString() -> NSAttributedString {
		let attributedString = NSMutableAttributedString(string: "")
		
		let lines = self.string.components(separatedBy: CharacterSet.newlines)
		
		var lineCount = 0
		
		let headings = ["# ", "## ", "### ", "#### ", "##### ", "###### "]
		
		var skipLine = false
		for theLine in lines {
			lineCount += 1
			if skipLine {
				skipLine = false
				continue
			}
			var line = theLine
			for heading in headings {
				
				if let range =  line.range(of: heading), range.lowerBound == line.startIndex {
					
					let startHeadingString = line.replacingCharacters(in: range, with: "")

					// Remove ending
					let endHeadingString = heading.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
					line = startHeadingString.replacingOccurrences(of: endHeadingString, with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
					
					currentType = LineType(rawValue: headings.index(of: heading)!)!

					// We found a heading so break out of the inner loop
					break
				}
			}
			
			// Look for underlined headings
			if lineCount  < lines.count {
				let nextLine = lines[lineCount]
				
				if let range = nextLine.range(of: "="), range.lowerBound == nextLine.startIndex {
					// Make H1
					currentType = .h1
					// We need to skip the next line
					skipLine = true
				}
				
				if let range = nextLine.range(of: "-"), range.lowerBound == nextLine.startIndex {
					// Make H2
					currentType = .h2
					// We need to skip the next line
					skipLine = true
				}
			}
			
			// If this is not an empty line...
			if line.characters.count > 0 {
				
				// ...start scanning
				let scanner = Scanner(string: line)
				
				// We want to be aware of spaces
				scanner.charactersToBeSkipped = nil
				
				while !scanner.isAtEnd {
					var string : NSString?

					// Get all the characters up to the ones we are interested in
					if scanner.scanUpToCharacters(from: instructionSet, into: &string) {
						
						if let hasString = string as? String {
							let bodyString = attributedStringFromString(hasString, withStyle: .none)
							attributedString.append(bodyString)
							
							let location = scanner.scanLocation
							
							let matchedCharacters = tagFromScanner(scanner).foundCharacters
							// If the next string after the characters is a space, then add it to the final string and continue
							
							let set = NSMutableCharacterSet.whitespace()
							set.formUnion(with: CharacterSet.punctuation)
							if scanner.scanUpToCharacters(from: set as CharacterSet, into: nil) {
								scanner.scanLocation = location
								attributedString.append(self.attributedStringFromScanner(scanner))

							} else if matchedCharacters == "[" {
								scanner.scanLocation = location
								attributedString.append(self.attributedStringFromScanner(scanner))								
							} else {
								let charAtts = attributedStringFromString(matchedCharacters, withStyle: .none)
								attributedString.append(charAtts)
							}
						}
					} else {
						attributedString.append(self.attributedStringFromScanner(scanner, atStartOfLine: true))
					}
				}
			}
			
			// Append a new line character to the end of the processed line
			attributedString.append(NSAttributedString(string: "\n"))
			currentType = .body
		}
		
		return attributedString
	}
	
	func attributedStringFromScanner( _ scanner : Scanner, atStartOfLine start : Bool = false) -> NSAttributedString {
		var followingString : NSString?

		let results = self.tagFromScanner(scanner)

		var style = LineStyle.styleFromString(results.foundCharacters)
		
		var attributes = [String : AnyObject]()
		if style == .link {
			
			var linkText : NSString?
			var linkURL : NSString?
			let linkCharacters = CharacterSet(charactersIn: "]()")
			
			scanner.scanUpToCharacters(from: linkCharacters, into: &linkText)
			scanner.scanCharacters(from: linkCharacters, into: nil)
			scanner.scanUpToCharacters(from: linkCharacters, into: &linkURL)
			scanner.scanCharacters(from: linkCharacters, into: nil)
			
			
			if let hasLink = linkText, let hasURL = linkURL {
				followingString = hasLink as String
				attributes[NSLinkAttributeName] = hasURL as String
			} else {
				style = .none
			}
		} else {
			scanner.scanUpToCharacters(from: instructionSet, into: &followingString)		
		}
		
		let attributedString = attributedStringFromString(results.escapedCharacters, withStyle: style).mutableCopy() as! NSMutableAttributedString
		if let hasString = followingString as? String {

			let prefix = ( style == .code && start ) ? "\t" : ""
			let attString = attributedStringFromString(prefix + hasString, withStyle: style, attributes: attributes)
			attributedString.append(attString)
		}
		let suffix = self.tagFromScanner(scanner)
		attributedString.append(attributedStringFromString(suffix.escapedCharacters, withStyle: style))
		
		return attributedString
	}
	
	func tagFromScanner( _ scanner : Scanner ) -> (foundCharacters : String, escapedCharacters : String) {
		var matchedCharacters : String = ""
		var tempCharacters : NSString?
		
		// Scan the ones we are interested in
		while scanner.scanCharacters(from: instructionSet, into: &tempCharacters) {
			if let chars = tempCharacters as? String {
				matchedCharacters = matchedCharacters + chars
			}
		}
		var foundCharacters : String = ""
		
		while matchedCharacters.contains("\\") {
			if let hasRange = matchedCharacters.range(of: "\\") {
                let lowerBound = matchedCharacters.index(hasRange.lowerBound, offsetBy: 0)
                let upperBound = matchedCharacters.index(hasRange.upperBound, offsetBy: 1)
                let newRange = Range<String.Index>(lowerBound..<upperBound)
				foundCharacters = foundCharacters + matchedCharacters.substring(with: newRange)
				matchedCharacters.removeSubrange(newRange)
			}
			
		}
		
		
		return (matchedCharacters, foundCharacters.replacingOccurrences(of: "\\", with: ""))
	}
	
	
	// Make H1
	
	func attributedStringFromString(_ string : String, withStyle style : LineStyle, attributes : [String : AnyObject] = [:] ) -> NSAttributedString {
		let textStyle : String
		var fontName : String?
        var attributes = attributes

		// What type are we and is there a font name set?
		
		
		switch currentType {
		case .h1:
			fontName = h1.fontName
			if #available(iOS 9, *) {
				textStyle = UIFontTextStyleTitle1
			} else {
				textStyle = UIFontTextStyleHeadline
			}
			attributes[NSForegroundColorAttributeName] = h1.color
		case .h2:
			fontName = h2.fontName
			if #available(iOS 9, *) {
				textStyle = UIFontTextStyleTitle2
			} else {
				textStyle = UIFontTextStyleHeadline
			}
			attributes[NSForegroundColorAttributeName] = h2.color
		case .h3:
			fontName = h3.fontName
			if #available(iOS 9, *) {
				textStyle = UIFontTextStyleTitle2
			} else {
				textStyle = UIFontTextStyleSubheadline
			}
			attributes[NSForegroundColorAttributeName] = h3.color
		case .h4:
			fontName = h4.fontName
			textStyle = UIFontTextStyleHeadline
			attributes[NSForegroundColorAttributeName] = h4.color
		case .h5:
			fontName = h5.fontName
			textStyle = UIFontTextStyleSubheadline
			attributes[NSForegroundColorAttributeName] = h5.color
		case .h6:
			fontName = h6.fontName
			textStyle = UIFontTextStyleFootnote
			attributes[NSForegroundColorAttributeName] = h6.color
		default:
			fontName = body.fontName
			textStyle = UIFontTextStyleBody
			attributes[NSForegroundColorAttributeName] = body.color
			break
		}
		
		// Check for code
		
		if style == .code {
			fontName = code.fontName
			attributes[NSForegroundColorAttributeName] = code.color
		}
		
		if style == .link {
			fontName = link.fontName
			attributes[NSForegroundColorAttributeName] = link.color
		}
		
		// Fallback to body
		if let _ = fontName {
			
		} else {
			fontName = body.fontName
		}
		
		let font = UIFont.preferredFont(forTextStyle: textStyle)
		let styleDescriptor = font.fontDescriptor
		let styleSize = styleDescriptor.fontAttributes[UIFontDescriptorSizeAttribute] as? CGFloat ?? CGFloat(14)
		
		var finalFont : UIFont
		if let finalFontName = fontName, let font = UIFont(name: finalFontName, size: styleSize) {
			finalFont = font
		} else {
			finalFont = UIFont.preferredFont(forTextStyle: textStyle)
		}
		
		let finalFontDescriptor = finalFont.fontDescriptor
		if style == .italic {
			let italicDescriptor = finalFontDescriptor.withSymbolicTraits(.traitItalic)
			finalFont = UIFont(descriptor: italicDescriptor!, size: styleSize)
		}
		if style == .bold {
			let boldDescriptor = finalFontDescriptor.withSymbolicTraits(.traitBold)
			finalFont = UIFont(descriptor: boldDescriptor!, size: styleSize)
		}
		
		
		attributes[NSFontAttributeName] = finalFont
		
		return NSAttributedString(string: string, attributes: attributes)
	}
}
