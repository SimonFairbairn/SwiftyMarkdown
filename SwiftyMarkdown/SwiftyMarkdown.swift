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
	public var fontName : String? = UIFont.preferredFontForTextStyle(UIFontTextStyleBody).fontName
	public var color = UIColor.blackColor()
}

enum LineType : Int {
	case H1, H2, H3, H4, H5, H6, Body
}

enum LineStyle : Int {
	case None
	case Italic
	case Bold
	case Code
	case Link
	
	static func styleFromString(string : String ) -> LineStyle {
		if string == "**" || string == "__" {
			return .Bold
		} else if string == "*" || string == "_" {
			return .Italic
		} else if string == "`" {
			return .Code
		} else if string == "["  {
			return .Link
		} else {
			return .None
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

	
	var currentType : LineType = .Body

	
	let string : String
	let instructionSet = NSCharacterSet(charactersInString: "[\\*_`")
	
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
	public init?(url : NSURL ) {
		
		do {
			self.string = try NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding) as String
			
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
		
		let lines = self.string.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
		
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
				
				if let range =  line.rangeOfString(heading) where range.startIndex == line.startIndex {
					
					let startHeadingString = line.stringByReplacingCharactersInRange(range, withString: "")

					// Remove ending
					let endHeadingString = heading.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
					line = startHeadingString.stringByReplacingOccurrencesOfString(endHeadingString, withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
					
					currentType = LineType(rawValue: headings.indexOf(heading)!)!

					// We found a heading so break out of the inner loop
					break
				}
			}
			
			// Look for underlined headings
			if lineCount  < lines.count {
				let nextLine = lines[lineCount]
				
				if let range = nextLine.rangeOfString("=") where range.startIndex == nextLine.startIndex {
					// Make H1
					currentType = .H1
					// We need to skip the next line
					skipLine = true
				}
				
				if let range = nextLine.rangeOfString("-") where range.startIndex == nextLine.startIndex {
					// Make H2
					currentType = .H2
					// We need to skip the next line
					skipLine = true
				}
			}
			
			// If this is not an empty line...
			if line.characters.count > 0 {
				
				// ...start scanning
				let scanner = NSScanner(string: line)
				
				// We want to be aware of spaces
				scanner.charactersToBeSkipped = nil
				
				while !scanner.atEnd {
					var string : NSString?

					// Get all the characters up to the ones we are interested in
					if scanner.scanUpToCharactersFromSet(instructionSet, intoString: &string) {
						
						if let hasString = string as? String {
							let bodyString = attributedStringFromString(hasString, withStyle: .None)
							attributedString.appendAttributedString(bodyString)
							
							let location = scanner.scanLocation
							
							let matchedCharacters = tagFromScanner(scanner).foundCharacters
							// If the next string after the characters is a space, then add it to the final string and continue
							
							let set = NSMutableCharacterSet.whitespaceCharacterSet()
							set.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())
							if scanner.scanUpToCharactersFromSet(set, intoString: nil) {
								scanner.scanLocation = location
								attributedString.appendAttributedString(self.attributedStringFromScanner(scanner))

							} else if matchedCharacters == "[" {
								scanner.scanLocation = location
								attributedString.appendAttributedString(self.attributedStringFromScanner(scanner))								
							} else {
								let charAtts = attributedStringFromString(matchedCharacters, withStyle: .None)
								attributedString.appendAttributedString(charAtts)
							}
						}
					} else {
						attributedString.appendAttributedString(self.attributedStringFromScanner(scanner, atStartOfLine: true))
					}
				}
			}
			
			// Append a new line character to the end of the processed line
			//attributedString.appendAttributedString(NSAttributedString(string: "\n"))
			currentType = .Body
		}
		
		return attributedString
	}
	
	func attributedStringFromScanner( scanner : NSScanner, atStartOfLine start : Bool = false) -> NSAttributedString {
		var followingString : NSString?

		let results = self.tagFromScanner(scanner)

		var style = LineStyle.styleFromString(results.foundCharacters)
		
		var attributes = [String : AnyObject]()
		if style == .Link {
			
			var linkText : NSString?
			var linkURL : NSString?
			let linkCharacters = NSCharacterSet(charactersInString: "]()")
			
			scanner.scanUpToCharactersFromSet(linkCharacters, intoString: &linkText)
			scanner.scanCharactersFromSet(linkCharacters, intoString: nil)
			scanner.scanUpToCharactersFromSet(linkCharacters, intoString: &linkURL)
			scanner.scanCharactersFromSet(linkCharacters, intoString: nil)
			
			
			if let hasLink = linkText, hasURL = linkURL {
				followingString = hasLink as String
				attributes[NSLinkAttributeName] = hasURL as String
			} else {
				style = .None
			}
		} else {
			scanner.scanUpToCharactersFromSet(instructionSet, intoString: &followingString)		
		}
		
		let attributedString = attributedStringFromString(results.escapedCharacters, withStyle: style).mutableCopy() as! NSMutableAttributedString
		if let hasString = followingString as? String {

			let prefix = ( style == .Code && start ) ? "\t" : ""
			let attString = attributedStringFromString(prefix + hasString, withStyle: style, attributes: attributes)
			attributedString.appendAttributedString(attString)
		}
		let suffix = self.tagFromScanner(scanner)
		attributedString.appendAttributedString(attributedStringFromString(suffix.escapedCharacters, withStyle: style))
		
		return attributedString
	}
	
	func tagFromScanner( scanner : NSScanner ) -> (foundCharacters : String, escapedCharacters : String) {
		var matchedCharacters : String = ""
		var tempCharacters : NSString?
		
		// Scan the ones we are interested in
		while scanner.scanCharactersFromSet(instructionSet, intoString: &tempCharacters) {
			if let chars = tempCharacters as? String {
				matchedCharacters = matchedCharacters + chars
			}
		}
		var foundCharacters : String = ""
		
		while matchedCharacters.containsString("\\") {
			if let hasRange = matchedCharacters.rangeOfString("\\") {
				
				let newRange  = hasRange.startIndex...hasRange.endIndex
				foundCharacters = foundCharacters + matchedCharacters.substringWithRange(newRange)

				matchedCharacters.removeRange(newRange)
			}
			
		}
		
		
		return (matchedCharacters, foundCharacters.stringByReplacingOccurrencesOfString("\\", withString: ""))
	}
	
	
	// Make H1
	
	func attributedStringFromString(string : String, withStyle style : LineStyle, attributes : [String : AnyObject] = [:] ) -> NSAttributedString {
		let textStyle : String
		var fontName : String?
        var attributes = attributes

		// What type are we and is there a font name set?
		
		
		switch currentType {
		case .H1:
			fontName = h1.fontName
			if #available(iOS 9, *) {
				textStyle = UIFontTextStyleTitle1
			} else {
				textStyle = UIFontTextStyleHeadline
			}
			attributes[NSForegroundColorAttributeName] = h1.color
		case .H2:
			fontName = h2.fontName
			if #available(iOS 9, *) {
				textStyle = UIFontTextStyleTitle2
			} else {
				textStyle = UIFontTextStyleHeadline
			}
			attributes[NSForegroundColorAttributeName] = h2.color
		case .H3:
			fontName = h3.fontName
			if #available(iOS 9, *) {
				textStyle = UIFontTextStyleTitle2
			} else {
				textStyle = UIFontTextStyleSubheadline
			}
			attributes[NSForegroundColorAttributeName] = h3.color
		case .H4:
			fontName = h4.fontName
			textStyle = UIFontTextStyleHeadline
			attributes[NSForegroundColorAttributeName] = h4.color
		case .H5:
			fontName = h5.fontName
			textStyle = UIFontTextStyleSubheadline
			attributes[NSForegroundColorAttributeName] = h5.color
		case .H6:
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
		
		if style == .Code {
			fontName = code.fontName
			attributes[NSForegroundColorAttributeName] = code.color
		}
		
		if style == .Link {
			fontName = link.fontName
			attributes[NSForegroundColorAttributeName] = link.color
		}
		
		// Fallback to body
		if let _ = fontName {
			
		} else {
			fontName = body.fontName
		}
		
		let font = UIFont.preferredFontForTextStyle(textStyle)
		let styleDescriptor = font.fontDescriptor()
		let styleSize = styleDescriptor.fontAttributes()[UIFontDescriptorSizeAttribute] as? CGFloat ?? CGFloat(14)
		
		var finalFont : UIFont
		if let finalFontName = fontName, font = UIFont(name: finalFontName, size: styleSize) {
			finalFont = font
		} else {
			finalFont = UIFont.preferredFontForTextStyle(textStyle)
		}
		
		let finalFontDescriptor = finalFont.fontDescriptor()
		if style == .Italic {
			let italicDescriptor = finalFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitItalic)
			finalFont = UIFont(descriptor: italicDescriptor, size: styleSize)
		}
		if style == .Bold {
			let boldDescriptor = finalFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
			finalFont = UIFont(descriptor: boldDescriptor, size: styleSize)
		}
		
		
		attributes[NSFontAttributeName] = finalFont
		
		return NSAttributedString(string: string, attributes: attributes)
	}
}
