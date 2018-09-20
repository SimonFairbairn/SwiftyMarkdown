//
//  SwiftyMarkdown.swift
//  SwiftyMarkdown
//
//  Created by Simon Fairbairn on 05/03/2016.
//  Copyright © 2016 Voyage Travel Apps. All rights reserved.
//

import UIKit


@objc public protocol FontProperties {
	var fontName : String? { get set }
	var color : UIColor { get set }
	var fontSize : CGFloat { get set }
}


/**
A struct defining the styles that can be applied to the parsed Markdown. The `fontName` property is optional, and if it's not set then the `fontName` property of the Body style will be applied.

If that is not set, then the system default will be used.
*/
@objc open class BasicStyles : NSObject, FontProperties {
	public var fontName : String? = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body).fontName
	public var color = UIColor.black
	public var fontSize : CGFloat = 0.0
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
@objc open class SwiftyMarkdown: NSObject {
	
	/// The styles to apply to any H1 headers found in the Markdown
	open var h1 = BasicStyles()
	
	/// The styles to apply to any H2 headers found in the Markdown
	open var h2 = BasicStyles()
	
	/// The styles to apply to any H3 headers found in the Markdown
	open var h3 = BasicStyles()
	
	/// The styles to apply to any H4 headers found in the Markdown
	open var h4 = BasicStyles()
	
	/// The styles to apply to any H5 headers found in the Markdown
	open var h5 = BasicStyles()
	
	/// The styles to apply to any H6 headers found in the Markdown
	open var h6 = BasicStyles()
	
	/// The default body styles. These are the base styles and will be used for e.g. headers if no other styles override them.
	open var body = BasicStyles()
	
	/// The styles to apply to any links found in the Markdown
	open var link = BasicStyles()
	
	/// The styles to apply to any bold text found in the Markdown
	open var bold = BasicStyles()
	
	/// The styles to apply to any italic text found in the Markdown
	open var italic = BasicStyles()
	
	/// The styles to apply to any code blocks or inline code text found in the Markdown
	open var code = BasicStyles()
	
	
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
			return nil
		}
	}
	
	/**
	Set font size for all styles
	
	- parameter size: size of font
	*/
	open func setFontSizeForAllStyles(with size: CGFloat) {
		h1.fontSize = size
		h2.fontSize = size
		h3.fontSize = size
		h4.fontSize = size
		h5.fontSize = size
		h6.fontSize = size
		body.fontSize = size
		italic.fontSize = size
		code.fontSize = size
		link.fontSize = size
	}
	
	open func setFontColorForAllStyles(with color: UIColor) {
		h1.color = color
		h2.color = color
		h3.color = color
		h4.color = color
		h5.color = color
		h6.color = color
		body.color = color
		italic.color = color
		code.color = color
		link.color = color
	}
	
	open func setFontNameForAllStyles(with name: String) {
		h1.fontName = name
		h2.fontName = name
		h3.fontName = name
		h4.fontName = name
		h5.fontName = name
		h6.fontName = name
		body.fontName = name
		italic.fontName = name
		code.fontName = name
		link.fontName = name
	}
	
	/**
	Generates an NSAttributedString from the string or URL passed at initialisation. Custom fonts or styles are applied to the appropriate elements when this method is called.
	
	- returns: An NSAttributedString with the styles applied
	*/
	open func attributedString() -> NSAttributedString {
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
			var line = theLine == "" ? " " : theLine
			for heading in headings {
				
				if let range =  line.range(of: heading) , range.lowerBound == line.startIndex {
					
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
				
				let hasNonWhiteSpaceCharacters = (line.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted) != nil)
                
				if hasNonWhiteSpaceCharacters, let range = nextLine.range(of: "=") , range.lowerBound == nextLine.startIndex {
					// Make H1
					currentType = .h1
					// We need to skip the next line
					skipLine = true
				}
				
				if hasNonWhiteSpaceCharacters, let nextRange = nextLine.range(of: "-") , nextRange.lowerBound == nextLine.startIndex {
					if let range = line.range(of: "-"), range.lowerBound == line.startIndex {
						// This is a bullet list, not an `Alt-H2`, don't skip
					} else {
						// Make H2
						currentType = .h2
						// We need to skip the next line
						skipLine = true
					}
				}
			}
			
			// If this is not an empty line...
			if line.count > 0 {
				
				// ...start scanning
				let scanner = Scanner(string: line)
				
				// We want to be aware of spaces
				scanner.charactersToBeSkipped = nil
				
				while !scanner.isAtEnd {
					var string : NSString?
					
					// Get all the characters up to the ones we are interested in
					if scanner.scanUpToCharacters(from: instructionSet, into: &string) {
						
						if let hasString = string as String? {
							let bodyString = attributedStringFromString(hasString, withStyle: .none)
							attributedString.append(bodyString)
							
							let location = scanner.scanLocation
							
							let matchedCharacters = tagFromScanner(scanner).foundCharacters
							// If the next string after the characters is a space, then add it to the final string and continue
							
							let set = NSMutableCharacterSet.whitespace()
							set.formUnion(with: CharacterSet.punctuationCharacters)
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
			if lineCount < lines.count {
				attributedString.append(NSAttributedString(string: "\n"))
			}
			currentType = .body
		}
		
		return attributedString
	}
	
	func attributedStringFromScanner( _ scanner : Scanner, atStartOfLine start : Bool = false) -> NSAttributedString {
		var followingString : NSString?
		
		let results = self.tagFromScanner(scanner)
		
		var style = LineStyle.styleFromString(results.foundCharacters)
		
		var attributes = [NSAttributedString.Key : AnyObject]()
		if style == .link {
			
			var linkText : NSString?
			var linkURL : NSString?
			let linkCharacters = CharacterSet(charactersIn: "]()")
			
			scanner.scanUpToCharacters(from: linkCharacters, into: &linkText)
			scanner.scanCharacters(from: linkCharacters, into: nil)
			scanner.scanUpToCharacters(from: linkCharacters, into: &linkURL)
			scanner.scanCharacters(from: linkCharacters, into: nil)
			
			
			if let hasLink = linkText, let hasURL = linkURL {
				followingString = hasLink
				attributes[NSAttributedString.Key.link] = hasURL
			} else {
				style = .none
			}
		} else {
			scanner.scanUpToCharacters(from: instructionSet, into: &followingString)
		}
		
		let attributedString = attributedStringFromString(results.escapedCharacters, withStyle: style).mutableCopy() as! NSMutableAttributedString
		if let hasString = followingString as String? {
			
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
			if let chars = tempCharacters as String? {
				matchedCharacters = matchedCharacters + chars
			}
		}
		var foundCharacters : String = ""
		
		while matchedCharacters.contains("\\") {
			if let hasRange = matchedCharacters.range(of: "\\") {
				
				if matchedCharacters.count > 1 {
					let newRange = hasRange.lowerBound..<matchedCharacters.index(hasRange.upperBound, offsetBy: 1)
					foundCharacters = foundCharacters + matchedCharacters[newRange].replacingOccurrences(of: "\\", with: "")
					
					matchedCharacters.removeSubrange(newRange)
				} else {
					foundCharacters = matchedCharacters
					break
				}
			}
			
		}
		
		
		return (matchedCharacters, foundCharacters)
	}
	
	
	// Make H1
	
	func attributedStringFromString(_ string : String, withStyle style : LineStyle, attributes : [NSAttributedString.Key : AnyObject] = [:] ) -> NSAttributedString {
		let textStyle : UIFont.TextStyle
		var fontName : String?
		var attributes = attributes
		var fontSize : CGFloat?
		
		// What type are we and is there a font name set?
		
		
		switch currentType {
		case .h1:
			fontName = h1.fontName
			fontSize = h1.fontSize
			if #available(iOS 9, *) {
				textStyle = UIFont.TextStyle.title1
			} else {
				textStyle = UIFont.TextStyle.headline
			}
			attributes[NSAttributedString.Key.foregroundColor] = h1.color
		case .h2:
			fontName = h2.fontName
			fontSize = h2.fontSize
			if #available(iOS 9, *) {
				textStyle = UIFont.TextStyle.title2
			} else {
				textStyle = UIFont.TextStyle.headline
			}
			attributes[NSAttributedString.Key.foregroundColor] = h2.color
		case .h3:
			fontName = h3.fontName
			fontSize = h3.fontSize
			if #available(iOS 9, *) {
				textStyle = UIFont.TextStyle.title2
			} else {
				textStyle = UIFont.TextStyle.subheadline
			}
			attributes[NSAttributedString.Key.foregroundColor] = h3.color
		case .h4:
			fontName = h4.fontName
			fontSize = h4.fontSize
			textStyle = UIFont.TextStyle.headline
			attributes[NSAttributedString.Key.foregroundColor] = h4.color
		case .h5:
			fontName = h5.fontName
			fontSize = h5.fontSize
			textStyle = UIFont.TextStyle.subheadline
			attributes[NSAttributedString.Key.foregroundColor] = h5.color
		case .h6:
			fontName = h6.fontName
			fontSize = h6.fontSize
			textStyle = UIFont.TextStyle.footnote
			attributes[NSAttributedString.Key.foregroundColor] = h6.color
		default:
			fontName = body.fontName
			fontSize = body.fontSize
			textStyle = UIFont.TextStyle.body
			attributes[NSAttributedString.Key.foregroundColor] = body.color
			break
		}
		
		// Check for code
		
		if style == .code {
			fontName = code.fontName
			fontSize = code.fontSize
			attributes[NSAttributedString.Key.foregroundColor] = code.color
		}
		
		if style == .link {
			fontName = link.fontName
			fontSize = link.fontSize
			attributes[NSAttributedString.Key.foregroundColor] = link.color
		}
		
		// Fallback to body
		if let _ = fontName {
			
		} else {
			fontName = body.fontName
		}
		
		fontSize = fontSize == 0.0 ? nil : fontSize
		let font = UIFont.preferredFont(forTextStyle: textStyle)
		let styleDescriptor = font.fontDescriptor
		let styleSize = fontSize ?? styleDescriptor.fontAttributes[UIFontDescriptor.AttributeName.size] as? CGFloat ?? CGFloat(14)
		
		var finalFont : UIFont
		if let finalFontName = fontName, let font = UIFont(name: finalFontName, size: styleSize) {
			finalFont = font
		} else {
			finalFont = UIFont.preferredFont(forTextStyle:  textStyle)
		}
		
		let finalFontDescriptor = finalFont.fontDescriptor
		if style == .italic {
			if let italicDescriptor = finalFontDescriptor.withSymbolicTraits(.traitItalic) {
				finalFont = UIFont(descriptor: italicDescriptor, size: styleSize)
			}
			
		}
		if style == .bold {
			if let boldDescriptor = finalFontDescriptor.withSymbolicTraits(.traitBold) {
				finalFont = UIFont(descriptor: boldDescriptor, size: styleSize)
			}
			
		}
		
		
		attributes[NSAttributedString.Key.font] = finalFont
		
		return NSAttributedString(string: string, attributes: attributes)
	}
}
