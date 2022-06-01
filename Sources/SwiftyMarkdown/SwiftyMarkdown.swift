//
//  SwiftyMarkdown.swift
//  SwiftyMarkdown
//
//  Created by Simon Fairbairn on 05/03/2016.
//  Copyright © 2016 Voyage Travel Apps. All rights reserved.
//
import os.log
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension OSLog {
	private static var subsystem = "SwiftyMarkdown"
	static let swiftyMarkdownPerformance = OSLog(subsystem: subsystem, category: "Swifty Markdown Performance")
}

public enum CharacterStyle : CharacterStyling {
	case none
	case bold
	case italic
	case code
	case link
	case image
	case referencedLink
	case referencedImage
	case strikethrough
	
	public func isEqualTo(_ other: CharacterStyling) -> Bool {
		guard let other = other as? CharacterStyle else {
			return false
		}
		return other == self 
	}
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
    case yaml
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
	case unorderedListIndentFirstOrder
	case unorderedListIndentSecondOrder
    case orderedList
	case orderedListIndentFirstOrder
	case orderedListIndentSecondOrder
	case referencedLink
	
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

#if os(macOS)
@objc public protocol FontProperties {
	var fontName : String? { get set }
	var color : NSColor { get set }
	var fontSize : CGFloat { get set }
	var fontStyle : FontStyle { get set }
}
#else
@objc public protocol FontProperties {
	var fontName : String? { get set }
	var color : UIColor { get set }
	var fontSize : CGFloat { get set }
	var fontStyle : FontStyle { get set }
}
#endif


@objc public protocol LineProperties {
	var alignment : NSTextAlignment { get set }
    var lineSpacing: CGFloat { get set }
    var paragraphSpacing: CGFloat { get set }
}


/**
A class defining the styles that can be applied to the parsed Markdown. The `fontName` property is optional, and if it's not set then the `fontName` property of the Body style will be applied.

If that is not set, then the system default will be used.
*/
@objc open class BasicStyles : NSObject, FontProperties {
	public var fontName : String?
	#if os(macOS)
	public var color = NSColor.black
	#else
	public var color = UIColor.black
	#endif
	public var fontSize : CGFloat = 0.0
	public var fontStyle : FontStyle = .normal
}

@objc open class LineStyles : NSObject, FontProperties, LineProperties {
	public var fontName : String?
	#if os(macOS)
	public var color = NSColor.black
	#else
	public var color = UIColor.black
	#endif
	public var fontSize : CGFloat = 0.0
	public var fontStyle : FontStyle = .normal
	public var alignment: NSTextAlignment = .left
    public var lineSpacing : CGFloat = 0.0
    public var paragraphSpacing : CGFloat = 0.0
}

@objc open class LinkStyles : BasicStyles {
    public var underlineStyle: NSUnderlineStyle = .single
	#if os(macOS)
	public lazy var underlineColor = self.color
	#else
	public lazy var underlineColor = self.color
	#endif
}

/// A class that takes a [Markdown](https://daringfireball.net/projects/markdown/) string or file and returns an NSAttributedString with the applied styles. Supports Dynamic Type.
@objc open class SwiftyMarkdown: NSObject {
	
	static public var frontMatterRules = [
		FrontMatterRule(openTag: "---", closeTag: "---", keyValueSeparator: ":")
	]
	
	static public var lineRules = [
		LineRule(token: "=", type: MarkdownLineStyle.previousH1, removeFrom: .entireLine, changeAppliesTo: .previous),
		LineRule(token: "-", type: MarkdownLineStyle.previousH2, removeFrom: .entireLine, changeAppliesTo: .previous),
		LineRule(token: "\t\t- ", type: MarkdownLineStyle.unorderedListIndentSecondOrder, removeFrom: .leading, shouldTrim: false),
		LineRule(token: "\t- ", type: MarkdownLineStyle.unorderedListIndentFirstOrder, removeFrom: .leading, shouldTrim: false),
		LineRule(token: "- ",type : MarkdownLineStyle.unorderedList, removeFrom: .leading),
		LineRule(token: "\t\t* ", type: MarkdownLineStyle.unorderedListIndentSecondOrder, removeFrom: .leading, shouldTrim: false),
		LineRule(token: "\t* ", type: MarkdownLineStyle.unorderedListIndentFirstOrder, removeFrom: .leading, shouldTrim: false),
		LineRule(token: "\t\t1. ", type: MarkdownLineStyle.orderedListIndentSecondOrder, removeFrom: .leading, shouldTrim: false),
		LineRule(token: "\t1. ", type: MarkdownLineStyle.orderedListIndentFirstOrder, removeFrom: .leading, shouldTrim: false),
		LineRule(token: "1. ",type : MarkdownLineStyle.orderedList, removeFrom: .leading),
		LineRule(token: "* ",type : MarkdownLineStyle.unorderedList, removeFrom: .leading),
		LineRule(token: "    ", type: MarkdownLineStyle.codeblock, removeFrom: .leading, shouldTrim: false),
		LineRule(token: "\t", type: MarkdownLineStyle.codeblock, removeFrom: .leading, shouldTrim: false),
		LineRule(token: ">",type : MarkdownLineStyle.blockquote, removeFrom: .leading),
		LineRule(token: "###### ",type : MarkdownLineStyle.h6, removeFrom: .both),
		LineRule(token: "##### ",type : MarkdownLineStyle.h5, removeFrom: .both),
		LineRule(token: "#### ",type : MarkdownLineStyle.h4, removeFrom: .both),
		LineRule(token: "### ",type : MarkdownLineStyle.h3, removeFrom: .both),
		LineRule(token: "## ",type : MarkdownLineStyle.h2, removeFrom: .both),
		LineRule(token: "# ",type : MarkdownLineStyle.h1, removeFrom: .both)
	]
	
	static public var characterRules = [
		CharacterRule(primaryTag: CharacterRuleTag(tag: "![", type: .open), otherTags: [
				CharacterRuleTag(tag: "]", type: .close),
				CharacterRuleTag(tag: "[", type: .metadataOpen),
				CharacterRuleTag(tag: "]", type: .metadataClose)
		], styles: [1 : CharacterStyle.image], metadataLookup: true, definesBoundary: true),
		CharacterRule(primaryTag: CharacterRuleTag(tag: "![", type: .open), otherTags: [
				CharacterRuleTag(tag: "]", type: .close),
				CharacterRuleTag(tag: "(", type: .metadataOpen),
				CharacterRuleTag(tag: ")", type: .metadataClose)
		], styles: [1 : CharacterStyle.image], metadataLookup: false, definesBoundary: true),
		CharacterRule(primaryTag: CharacterRuleTag(tag: "[", type: .open), otherTags: [
				CharacterRuleTag(tag: "]", type: .close),
				CharacterRuleTag(tag: "[", type: .metadataOpen),
				CharacterRuleTag(tag: "]", type: .metadataClose)
		], styles: [1 : CharacterStyle.link], metadataLookup: true, definesBoundary: true),
		CharacterRule(primaryTag: CharacterRuleTag(tag: "[", type: .open), otherTags: [
				CharacterRuleTag(tag: "]", type: .close),
				CharacterRuleTag(tag: "(", type: .metadataOpen),
				CharacterRuleTag(tag: ")", type: .metadataClose)
		], styles: [1 : CharacterStyle.link], metadataLookup: false, definesBoundary: true),
		CharacterRule(primaryTag: CharacterRuleTag(tag: "`", type: .repeating), otherTags: [], styles: [1 : CharacterStyle.code], shouldCancelRemainingRules: true, balancedTags: true),
		CharacterRule(primaryTag:CharacterRuleTag(tag: "~", type: .repeating), otherTags : [], styles: [2 : CharacterStyle.strikethrough], minTags:2 , maxTags:2),
		CharacterRule(primaryTag: CharacterRuleTag(tag: "*", type: .repeating), otherTags: [], styles: [1 : CharacterStyle.italic, 2 : CharacterStyle.bold], minTags:1 , maxTags:2),
		CharacterRule(primaryTag: CharacterRuleTag(tag: "_", type: .repeating), otherTags: [], styles: [1 : CharacterStyle.italic, 2 : CharacterStyle.bold], minTags:1 , maxTags:2)
	]
	
	let lineProcessor = SwiftyLineProcessor(rules: SwiftyMarkdown.lineRules, defaultRule: MarkdownLineStyle.body, frontMatterRules: SwiftyMarkdown.frontMatterRules)
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
	open var link = LinkStyles()
	
	/// The styles to apply to any bold text found in the Markdown
	open var bold = BasicStyles()
	
	/// The styles to apply to any italic text found in the Markdown
	open var italic = BasicStyles()
	
	/// The styles to apply to any code blocks or inline code text found in the Markdown
	open var code = BasicStyles()
	
	open var strikethrough = BasicStyles()
	
	public var bullet : String = "・"
	
	public var underlineLinks : Bool = false
	
	public var frontMatterAttributes : [String : String] {
		get {
			return self.lineProcessor.frontMatterAttributes
		}
	}
    
    public var imageScale : CGFloat = 1
    
    public var containImageWidth : Bool = false
	
	var currentType : MarkdownLineStyle = .body
	
	var string : String

	var orderedListCount = 0
	var orderedListIndentFirstOrderCount = 0
	var orderedListIndentSecondOrderCount = 0
	
	var previouslyFoundTokens : [Token] = []
	
	var applyAttachments = true
	
	let perfomanceLog = PerformanceLog(with: "SwiftyMarkdownPerformanceLogging", identifier: "Swifty Markdown", log: .swiftyMarkdownPerformance)
		
	/**
	
	- parameter string: A string containing [Markdown](https://daringfireball.net/projects/markdown/) syntax to be converted to an NSAttributedString
	
	- returns: An initialized SwiftyMarkdown object
	*/
	public init(string : String ) {
		self.string = string
		super.init()
		self.setup()
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
		self.setup()
	}
	
	func setup() {
		#if os(macOS)
		self.setFontColorForAllStyles(with: .labelColor)
		#elseif !os(watchOS)
		if #available(iOS 13.0, tvOS 13.0, *) {
			self.setFontColorForAllStyles(with: .label)
		}
		#endif
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
		link.fontSize = size
		strikethrough.fontSize = size
	}
	
	#if os(macOS)
	open func setFontColorForAllStyles(with color: NSColor) {
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
		strikethrough.color = color
	}
	#else
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
		strikethrough.color = color
	}
	#endif
	
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
		strikethrough.fontName = name
	}
	
	
	/**
	Generates an NSAttributedString from the string or URL passed at initialisation. Custom fonts or styles are applied to the appropriate elements when this method is called.
	
	- returns: An NSAttributedString with the styles applied
	*/
	open func attributedString(from markdownString : String? = nil) -> NSAttributedString {
		
		self.previouslyFoundTokens.removeAll()
		self.perfomanceLog.start()
		
		if let existentMarkdownString = markdownString {
			self.string = existentMarkdownString
		}
		let attributedString = NSMutableAttributedString(string: "")
		self.lineProcessor.processEmptyStrings = MarkdownLineStyle.body
		let foundAttributes : [SwiftyLine] = lineProcessor.process(self.string)
		
		let references : [SwiftyLine] = foundAttributes.filter({ $0.line.starts(with: "[") && $0.line.contains("]:") })
		let referencesRemoved : [SwiftyLine] = foundAttributes.filter({ !($0.line.starts(with: "[") && $0.line.contains("]:") ) })
		var keyValuePairs : [String : String] = [:]
		for line in references {
			let strings = line.line.components(separatedBy: "]:")
			guard strings.count >= 2 else {
				continue
			}
			var key : String = strings[0]
			if !key.isEmpty {
				let newstart = key.index(key.startIndex, offsetBy: 1)
				let range : Range<String.Index> = newstart..<key.endIndex
				key = String(key[range]).trimmingCharacters(in: .whitespacesAndNewlines)
			}
			keyValuePairs[key] = strings[1].trimmingCharacters(in: .whitespacesAndNewlines)
		}
		
		self.perfomanceLog.tag(with: "(line processing complete)")
		
		self.tokeniser.metadataLookup = keyValuePairs
		
		for (idx, line) in referencesRemoved.enumerated() {
			if idx > 0 {
				attributedString.append(NSAttributedString(string: "\n"))
			}
			let finalTokens = self.tokeniser.process(line.line)
			self.previouslyFoundTokens.append(contentsOf: finalTokens)
			self.perfomanceLog.tag(with: "(tokenising complete for line \(idx)")
			
			attributedString.append(attributedStringFor(tokens: finalTokens, in: line))
			
		}
		
		self.perfomanceLog.end()
		
		return attributedString
	}
	
}

class ImageAttachment: NSTextAttachment {
    
    private var imageScale: CGFloat = 1.0
    private var containImageWidth: Bool = false
    
    convenience init(imageScale: CGFloat, containImageWidth: Bool) {
        self.init()
        self.imageScale = imageScale
        self.containImageWidth = containImageWidth
    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        guard let imageSize = image?.size else {
            return super.attachmentBounds(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
        }
        let scale: CGFloat = containImageWidth ? min(imageScale, lineFrag.width / imageSize.width) : imageScale
        
        return CGRect(x: 0, y: 0, width: imageSize.width * scale, height: imageSize.height * scale)
    }
}

extension SwiftyMarkdown {
	
	func attributedStringFor( tokens : [Token], in line : SwiftyLine ) -> NSAttributedString {
		
		var finalTokens = tokens
		let finalAttributedString = NSMutableAttributedString()
		var attributes : [NSAttributedString.Key : AnyObject] = [:]
	
		guard let markdownLineStyle = line.lineStyle as? MarkdownLineStyle else {
			preconditionFailure("The passed line style is not a valid Markdown Line Style")
		}
		
		var listItem = self.bullet
		switch markdownLineStyle {
		case .orderedList:
			self.orderedListCount += 1
			self.orderedListIndentFirstOrderCount = 0
			self.orderedListIndentSecondOrderCount = 0
			listItem = "\(self.orderedListCount)."
		case .orderedListIndentFirstOrder, .unorderedListIndentFirstOrder:
			self.orderedListIndentFirstOrderCount += 1
			self.orderedListIndentSecondOrderCount = 0
			if markdownLineStyle == .orderedListIndentFirstOrder {
				listItem = "\(self.orderedListIndentFirstOrderCount)."
			}
			
		case .orderedListIndentSecondOrder, .unorderedListIndentSecondOrder:
			self.orderedListIndentSecondOrderCount += 1
			if markdownLineStyle == .orderedListIndentSecondOrder {
				listItem = "\(self.orderedListIndentSecondOrderCount)."
			}
			
		default:
			self.orderedListCount = 0
			self.orderedListIndentFirstOrderCount = 0
			self.orderedListIndentSecondOrderCount = 0
		}

		let lineProperties : LineProperties
		switch markdownLineStyle {
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
			paragraphStyle.headIndent = 20.0
			attributes[.paragraphStyle] = paragraphStyle
		case .unorderedList, .unorderedListIndentFirstOrder, .unorderedListIndentSecondOrder, .orderedList, .orderedListIndentFirstOrder, .orderedListIndentSecondOrder:
			
			let interval : CGFloat = 30
			var addition = interval
			var indent = ""
			switch line.lineStyle as! MarkdownLineStyle {
			case .unorderedListIndentFirstOrder, .orderedListIndentFirstOrder:
				addition = interval * 2
				indent = "\t"
			case .unorderedListIndentSecondOrder, .orderedListIndentSecondOrder:
				addition = interval * 3
				indent = "\t\t"
			default:
				break
			}
			
			lineProperties = body
			
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: interval, options: [:]), NSTextTab(textAlignment: .left, location: interval, options: [:])]
			paragraphStyle.defaultTabInterval = interval
			paragraphStyle.headIndent = addition

			attributes[.paragraphStyle] = paragraphStyle
			finalTokens.insert(Token(type: .string, inputString: "\(indent)\(listItem)\t"), at: 0)
			
		case .yaml:
			lineProperties = body
		case .previousH1:
			lineProperties = body
		case .previousH2:
			lineProperties = body
		case .body:
			lineProperties = body
		case .referencedLink:
			lineProperties = body
		}
		
        let paragraphStyle = attributes[.paragraphStyle] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
		if lineProperties.alignment != .left {
			paragraphStyle.alignment = lineProperties.alignment
		}
        paragraphStyle.lineSpacing = lineProperties.lineSpacing
        paragraphStyle.paragraphSpacing = lineProperties.paragraphSpacing
        attributes[.paragraphStyle] = paragraphStyle
		
		
		for token in finalTokens {
			attributes[.font] = self.font(for: line)
			attributes[.link] = nil
			attributes[.strikethroughStyle] = nil
			attributes[.foregroundColor] = self.color(for: line)
            attributes[.underlineStyle] = nil
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
			
            if let linkIdx = styles.firstIndex(of: .link), linkIdx < token.metadataStrings.count {
                attributes[.foregroundColor] = self.link.color
                attributes[.font] = self.font(for: line, characterOverride: .link)
                attributes[.link] = token.metadataStrings[linkIdx] as AnyObject
                
                if underlineLinks {
                    attributes[.underlineStyle] = self.link.underlineStyle.rawValue as AnyObject
                    attributes[.underlineColor] = self.link.underlineColor
                }
            }
						
			if styles.contains(.strikethrough) {
				attributes[.font] = self.font(for: line, characterOverride: .strikethrough)
				attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue as AnyObject
				attributes[.foregroundColor] = self.strikethrough.color
			}
			
			#if !os(watchOS)
			if let imgIdx = styles.firstIndex(of: .image), imgIdx < token.metadataStrings.count {
				if !self.applyAttachments {
					continue
				}
				#if !os(macOS)
				let image1Attachment = ImageAttachment(imageScale: imageScale, containImageWidth: containImageWidth)
				image1Attachment.image = UIImage(named: token.metadataStrings[imgIdx])
				let str = NSAttributedString(attachment: image1Attachment)
				finalAttributedString.append(str)
				#elseif !os(watchOS)
				let image1Attachment = ImageAttachment(imageScale: imageScale, containImageWidth: containImageWidth)
				image1Attachment.image = NSImage(named: token.metadataStrings[imgIdx])
				let str = NSAttributedString(attachment: image1Attachment)
				finalAttributedString.append(str)
				#endif
				continue
			}
			#endif
			
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
