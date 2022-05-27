import Foundation
import UIKit

enum CharacterStyle : CharacterStyling {
	case none
	case bold
	case italic
	case code
	case link
	case image
}

enum MarkdownLineStyle : LineStyling {
    var shouldTokeniseLine: Bool {
        switch self {
        case .codeblock:
            return false
        default:
            return true
        }
        
    }
    
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
    case previousH1
    case previousH2
    case body
    case blockquote
    case codeblock
    case unorderedList
    func styleIfFoundStyleAffectsPreviousLine() -> LineStyling? {
        switch self {
        case .previousH1:
            return MarkdownLineStyle.h1
        case .previousH2:
            return MarkdownLineStyle.h2
        default :
            return nil
        }
    }
}

@objc public enum FontStyle : Int {
	case normal
	case bold
	case italic
	case boldItalic
}

@objc public protocol FontProperties {
	var fontName : String? { get set }
	var color : UIColor { get set }
	var fontSize : CGFloat { get set }
	var fontStyle : FontStyle { get set }
}

@objc public protocol LineProperties {
	var alignment : NSTextAlignment { get set }
}


/**
A class defining the styles that can be applied to the parsed Markdown. The `fontName` property is optional, and if it's not set then the `fontName` property of the Body style will be applied.

If that is not set, then the system default will be used.
*/
@objc open class BasicStyles : NSObject, FontProperties {
	public var fontName : String?
	public var color = UIColor.black
	public var fontSize : CGFloat = 0.0
	public var fontStyle : FontStyle = .normal
}

@objc open class LineStyles : NSObject, FontProperties, LineProperties {
	public var fontName : String?
	public var color = UIColor.black
	public var fontSize : CGFloat = 0.0
	public var fontStyle : FontStyle = .normal
	public var alignment: NSTextAlignment = .left
}



/// A class that takes a [Markdown](https://daringfireball.net/projects/markdown/) string or file and returns an NSAttributedString with the applied styles. Supports Dynamic Type.
@objc open class SwiftyMarkdown: NSObject {
	static let lineRules = [
		LineRule(token: "=", type: MarkdownLineStyle.previousH1, removeFrom: .entireLine, changeAppliesTo: .previous),
		LineRule(token: "-", type: MarkdownLineStyle.previousH2, removeFrom: .entireLine, changeAppliesTo: .previous),
		LineRule(token: "    ", type: MarkdownLineStyle.codeblock, removeFrom: .leading, shouldTrim: false),
		LineRule(token: "\t", type: MarkdownLineStyle.codeblock, removeFrom: .leading, shouldTrim: false),
		LineRule(token: ">",type : MarkdownLineStyle.blockquote, removeFrom: .leading),
		LineRule(token: "- ",type : MarkdownLineStyle.unorderedList, removeFrom: .leading),
		LineRule(token: "###### ",type : MarkdownLineStyle.h6, removeFrom: .both),
		LineRule(token: "##### ",type : MarkdownLineStyle.h5, removeFrom: .both),
		LineRule(token: "#### ",type : MarkdownLineStyle.h4, removeFrom: .both),
		LineRule(token: "### ",type : MarkdownLineStyle.h3, removeFrom: .both),
		LineRule(token: "## ",type : MarkdownLineStyle.h2, removeFrom: .both),
		LineRule(token: "# ",type : MarkdownLineStyle.h1, removeFrom: .both)
	]
	
	static let characterRules = [
		CharacterRule(openTag: "![", intermediateTag: "](", closingTag: ")", escapeCharacter: "\\", styles: [1 : [CharacterStyle.image]], maxTags: 1),
		CharacterRule(openTag: "[", intermediateTag: "](", closingTag: ")", escapeCharacter: "\\", styles: [1 : [CharacterStyle.link]], maxTags: 1),
		CharacterRule(openTag: "`", intermediateTag: nil, closingTag: nil, escapeCharacter: "\\", styles: [1 : [CharacterStyle.code]], maxTags: 1, cancels: .allRemaining),
		CharacterRule(openTag: "*", intermediateTag: nil, closingTag: nil, escapeCharacter: "\\", styles: [1 : [CharacterStyle.italic], 2 : [CharacterStyle.bold], 3 : [CharacterStyle.bold, CharacterStyle.italic]], maxTags: 3),
		CharacterRule(openTag: "_", intermediateTag: nil, closingTag: nil, escapeCharacter: "\\", styles: [1 : [CharacterStyle.italic], 2 : [CharacterStyle.bold], 3 : [CharacterStyle.bold, CharacterStyle.italic]], maxTags: 3)
	]
	
	let lineProcessor = SwiftyLineProcessor(rules: SwiftyMarkdown.lineRules, defaultRule: MarkdownLineStyle.body)
	let tokeniser = SwiftyTokeniser(with: SwiftyMarkdown.characterRules)
	
	/// The styles to apply to any H1 headers found in the Markdown
	open var h1 = LineStyles()
	
	/// The styles to apply to any H2 headers found in the Markdown
	open var h2 = LineStyles()
	
	/// The styles to apply to any H3 headers found in the Markdown
	open var h3 = LineStyles()
	
	/// The styles to apply to any H4 headers found in the Markdown
	open var h4 = LineStyles()
	
	/// The styles to apply to any H5 headers found in the Markdown
	open var h5 = LineStyles()
	
	/// The styles to apply to any H6 headers found in the Markdown
	open var h6 = LineStyles()
	
	/// The default body styles. These are the base styles and will be used for e.g. headers if no other styles override them.
	open var body = LineStyles()
	
	/// The styles to apply to any blockquotes found in the Markdown
	open var blockquotes = LineStyles()
	
	/// The styles to apply to any links found in the Markdown
	open var link = BasicStyles()
	
	/// The styles to apply to any bold text found in the Markdown
	open var bold = BasicStyles()
	
	/// The styles to apply to any italic text found in the Markdown
	open var italic = BasicStyles()
	
	/// The styles to apply to any code blocks or inline code text found in the Markdown
	open var code = BasicStyles()
	

	
	public var underlineLinks : Bool = false
	
	var currentType : MarkdownLineStyle = .body
	
	
	let string : String
	
	let tagList = "!\\_*`[]()"
	let validMarkdownTags = CharacterSet(charactersIn: "!\\_*`[]()")

	
	/**
	
	- parameter string: A string containing [Markdown](https://daringfireball.net/projects/markdown/) syntax to be converted to an NSAttributedString
	
	- returns: An initialized SwiftyMarkdown object
	*/
	public init(string : String ) {
		self.string = string
		super.init()
		if #available(iOS 13.0, *) {
			self.setFontColorForAllStyles(with: .label)
		}
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
		super.init()
		if #available(iOS 13.0, *) {
			self.setFontColorForAllStyles(with: .label)
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
		bold.fontSize = size
		code.fontSize = size
		link.fontSize = size
		blockquotes.fontSize = size
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
		bold.color = color
		code.color = color
		link.color = color
		blockquotes.color = color
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
		bold.fontName = name
		code.fontName = name
		link.fontName = name
		blockquotes.fontName = name
	}
	
	
	
	/**
	Generates an NSAttributedString from the string or URL passed at initialisation. Custom fonts or styles are applied to the appropriate elements when this method is called.
	
	- returns: An NSAttributedString with the styles applied
	*/
	open func attributedString() -> NSAttributedString {
		let attributedString = NSMutableAttributedString(string: "")
		self.lineProcessor.processEmptyStrings = MarkdownLineStyle.body
		let foundAttributes : [SwiftyLine] = lineProcessor.process(self.string)

		for line in foundAttributes {
			let finalTokens = self.tokeniser.process(line.line)
			attributedString.append(attributedStringFor(tokens: finalTokens, in: line))
			attributedString.append(NSAttributedString(string: "\n"))
		}
		return attributedString
	}
	
	
}

extension SwiftyMarkdown {
	
	func font( for line : SwiftyLine, characterOverride : CharacterStyle? = nil ) -> UIFont {
		let textStyle : UIFont.TextStyle
		var fontName : String?
		var fontSize : CGFloat?
		
		var globalBold = false
		var globalItalic = false
		
		let style : FontProperties
		// What type are we and is there a font name set?
		switch line.lineStyle as! MarkdownLineStyle {
		case .h1:
			style = self.h1
			if #available(iOS 9, *) {
				textStyle = UIFont.TextStyle.title1
			} else {
				textStyle = UIFont.TextStyle.headline
			}
		case .h2:
			style = self.h2
			if #available(iOS 9, *) {
				textStyle = UIFont.TextStyle.title2
			} else {
				textStyle = UIFont.TextStyle.headline
			}
		case .h3:
			style = self.h3
			if #available(iOS 9, *) {
				textStyle = UIFont.TextStyle.title2
			} else {
				textStyle = UIFont.TextStyle.subheadline
			}
		case .h4:
			style = self.h4
			textStyle = UIFont.TextStyle.headline
		case .h5:
			style = self.h5
			textStyle = UIFont.TextStyle.subheadline
		case .h6:
			style = self.h6
			textStyle = UIFont.TextStyle.footnote
		case .codeblock:
			style = self.code
			textStyle = UIFont.TextStyle.body
		case .blockquote:
			style = self.blockquotes
			textStyle = UIFont.TextStyle.body
		default:
			style = self.body
			textStyle = UIFont.TextStyle.body
		}
		
		fontName = style.fontName
		fontSize = style.fontSize
		switch style.fontStyle {
		case .bold:
			globalBold = true
		case .italic:
			globalItalic = true
		case .boldItalic:
			globalItalic = true
			globalBold = true
		case .normal:
			break
		}

		if fontName == nil {
			fontName = body.fontName
		}
		
		if let characterOverride = characterOverride {
			switch characterOverride {
			case .code:
				fontName = code.fontName ?? fontName
				fontSize = code.fontSize
			case .link:
				fontName = link.fontName ?? fontName
				fontSize = link.fontSize
			case .bold:
				fontName = bold.fontName ?? fontName
				fontSize = bold.fontSize
				globalBold = true
			case .italic:
				fontName = italic.fontName ?? fontName
				fontSize = italic.fontSize
				globalItalic = true
			default:
				break
			}
		}
		
		fontSize = fontSize == 0.0 ? nil : fontSize
		var font : UIFont
		if let existentFontName = fontName {
			font = UIFont.preferredFont(forTextStyle: textStyle)
			let finalSize : CGFloat
			if let existentFontSize = fontSize {
				finalSize = existentFontSize
			} else {
				let styleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
				finalSize = styleDescriptor.fontAttributes[.size] as? CGFloat ?? CGFloat(14)
			}
			
			if let customFont = UIFont(name: existentFontName, size: finalSize)  {
				let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
				font = fontMetrics.scaledFont(for: customFont)
			} else {
				font = UIFont.preferredFont(forTextStyle: textStyle)
			}
		} else {
			font = UIFont.preferredFont(forTextStyle: textStyle)
		}
		
		if globalItalic, let italicDescriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
			font = UIFont(descriptor: italicDescriptor, size: 0)
		}
		if globalBold, let boldDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
			font = UIFont(descriptor: boldDescriptor, size: 0)
		}
		
		return font
		
	}
	
	func color( for line : SwiftyLine ) -> UIColor {
		// What type are we and is there a font name set?
		switch line.lineStyle as! MarkdownLineStyle {
		case .h1, .previousH1:
			return h1.color
		case .h2, .previousH2:
			return h2.color
		case .h3:
			return h3.color
		case .h4:
			return h4.color
		case .h5:
			return h5.color
		case .h6:
			return h6.color
		case .body:
			return body.color
		case .codeblock:
			return code.color
		case .blockquote:
			return blockquotes.color
		case .unorderedList:
			return body.color
		}
	}
	
	func attributedStringFor( tokens : [Token], in line : SwiftyLine ) -> NSAttributedString {
		
		var finalTokens = tokens
		let finalAttributedString = NSMutableAttributedString()
		var attributes : [NSAttributedString.Key : AnyObject] = [:]
	

		let lineProperties : LineProperties
		switch line.lineStyle as! MarkdownLineStyle {
		case .h1:
			lineProperties = self.h1
		case .h2:
			lineProperties = self.h2
		case .h3:
			lineProperties = self.h3
		case .h4:
			lineProperties = self.h4
		case .h5:
			lineProperties = self.h5
		case .h6:
			lineProperties = self.h6
			
		case .codeblock:
			lineProperties = body
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.firstLineHeadIndent = 20.0
			attributes[.paragraphStyle] = paragraphStyle
		case .blockquote:
			lineProperties = self.blockquotes
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.firstLineHeadIndent = 20.0
			attributes[.paragraphStyle] = paragraphStyle
		case .unorderedList:
			lineProperties = body
			finalTokens.insert(Token(type: .string, inputString: "・ "), at: 0)
		default:
			lineProperties = body
			break
		}
		
		if lineProperties.alignment != .left {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = lineProperties.alignment
			attributes[.paragraphStyle] = paragraphStyle
		}
		
		
		for token in finalTokens {
			attributes[.font] = self.font(for: line)
			attributes[.foregroundColor] = self.color(for: line)
			guard let styles = token.characterStyles as? [CharacterStyle] else {
				continue
			}
			if styles.contains(.italic) {
				attributes[.font] = self.font(for: line, characterOverride: .italic)
				attributes[.foregroundColor] = self.italic.color
			}
			if styles.contains(.bold) {
				attributes[.font] = self.font(for: line, characterOverride: .bold)
				attributes[.foregroundColor] = self.bold.color
			}
			
			if styles.contains(.link), let url = token.metadataString {
				attributes[.foregroundColor] = self.link.color
				attributes[.font] = self.font(for: line, characterOverride: .link)
				attributes[.link] = url as AnyObject
				
				if underlineLinks {
					attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue as AnyObject
				}
			}
			
			if styles.contains(.image), let imageName = token.metadataString {
				let image1Attachment = NSTextAttachment()
				image1Attachment.image = UIImage(named: imageName)
				let str = NSAttributedString(attachment: image1Attachment)
				finalAttributedString.append(str)
				continue
			}
			
			if styles.contains(.code) {
				attributes[.foregroundColor] = self.code.color
				attributes[.font] = self.font(for: line, characterOverride: .code)
			} else {
				// Switch back to previous font
			}
			let str = NSAttributedString(string: token.outputString, attributes: attributes)
			finalAttributedString.append(str)
		}
	
		return finalAttributedString
	}
}
