//
//  SwiftyMarkdownTests.swift
//  SwiftyMarkdownTests
//
//  Created by Simon Fairbairn on 05/03/2016.
//  Copyright © 2016 Voyage Travel Apps. All rights reserved.
//

import XCTest
@testable import SwiftyMarkdown

class SwiftyMarkdownTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testThatOctothorpeHeadersAreHandledCorrectly() {
		
		let headerString = "# Header 1\n## Header 2 ##\n### Header 3 ### \n#### Header 4#### \n##### Header 5\n###### Header 6"
		let headerStringWithBold = "# **Bold Header 1**"
		let headerStringWithItalic = "## Header 2 _With Italics_"
		
		var md = SwiftyMarkdown(string: headerString)
		XCTAssertEqual(md.attributedString().string, "Header 1\nHeader 2\nHeader 3\nHeader 4\nHeader 5\nHeader 6\n")
		
		 md = SwiftyMarkdown(string: headerStringWithBold)
		XCTAssertEqual(md.attributedString().string, "Bold Header 1\n")
		
		md = SwiftyMarkdown(string: headerStringWithItalic)
		XCTAssertEqual(md.attributedString().string, "Header 2 With Italics\n")
		
	}
	
	func testThatUndelinedHeadersAreHandledCorrectly() {
		let h1String = "Header 1\n===\nSome following text"
		let h2String = "Header 2\n---\nSome following text"
		
		let h1StringWithBold = "Header 1 **With Bold**\n===\nSome following text"
		let h2StringWithItalic = "Header 2 _With Italic_\n---\nSome following text"
		let h2StringWithCode = "Header 2 `With Code`\n---\nSome following text"
		
		var md = SwiftyMarkdown(string: h1String)
		XCTAssertEqual(md.attributedString().string, "Header 1\nSome following text\n")
		
		md = SwiftyMarkdown(string: h2String)
		XCTAssertEqual(md.attributedString().string, "Header 2\nSome following text\n")
		
		md = SwiftyMarkdown(string: h1StringWithBold)
		XCTAssertEqual(md.attributedString().string, "Header 1 With Bold\nSome following text\n")
		
		md = SwiftyMarkdown(string: h2StringWithItalic)
		XCTAssertEqual(md.attributedString().string, "Header 2 With Italic\nSome following text\n")
		
		md = SwiftyMarkdown(string: h2StringWithCode)
		XCTAssertEqual(md.attributedString().string, "Header 2 With Code\nSome following text\n")
	}
	
	func testThatRegularTraitsAreParsedCorrectly() {
		let boldAtStartOfString = "**A bold string**"
		let boldWithinString = "A string with a **bold** word"
		let codeAtStartOfString = "`Code (should be indented)`"
		let codeWithinString = "A string with `code` (should not be indented)"
		let italicAtStartOfString = "*An italicised string*"
		let italicWithinString = "A string with *italicised* text"
    let strikethroughAtStartOfString = "~~A strikethrough string~~"
    let strikethroughWithinString = "A string with a **strikethrough** word"
		
		let multipleBoldWords = "__A bold string__ with a **mix** **of** bold __styles__"
		let multipleCodeWords = "`A code string` with multiple `code` `instances`"
		let multipleItalicWords = "_An italic string_ with a *mix* _of_ italic *styles*"
		
		let longMixedString = "_An italic string_, **follwed by a bold one**, `with some code`, \\*\\*and some\\*\\* \\_escaped\\_ \\`characters\\`, `ending` *with* __more__ variety."
		
		
		var md = SwiftyMarkdown(string: boldAtStartOfString)
		XCTAssertEqual(md.attributedString().string, "A bold string\n")
		
		md = SwiftyMarkdown(string: boldWithinString)
		XCTAssertEqual(md.attributedString().string, "A string with a bold word\n")
		
		md = SwiftyMarkdown(string: codeAtStartOfString)
		XCTAssertEqual(md.attributedString().string, "\tCode (should be indented)\n")
		
		md = SwiftyMarkdown(string: codeWithinString)
		XCTAssertEqual(md.attributedString().string, "A string with code (should not be indented)\n")
		
		md = SwiftyMarkdown(string: italicAtStartOfString)
		XCTAssertEqual(md.attributedString().string, "An italicised string\n")
		
		md = SwiftyMarkdown(string: italicWithinString)
		XCTAssertEqual(md.attributedString().string, "A string with italicised text\n")
		
    md = SwiftyMarkdown(string: strikethroughAtStartOfString)
    XCTAssertEqual(md.attributedString().string, "A strikethrough string\n")
    
    md = SwiftyMarkdown(string: strikethroughWithinString)
    XCTAssertEqual(md.attributedString().string, "A string with a strikethrough word\n")
    
		md = SwiftyMarkdown(string: multipleBoldWords)
		XCTAssertEqual(md.attributedString().string, "A bold string with a mix of bold styles\n")
		
		md = SwiftyMarkdown(string: multipleCodeWords)
		XCTAssertEqual(md.attributedString().string, "\tA code string with multiple code instances\n")
		
		md = SwiftyMarkdown(string: multipleItalicWords)
		XCTAssertEqual(md.attributedString().string, "An italic string with a mix of italic styles\n")

		md = SwiftyMarkdown(string: longMixedString)
		XCTAssertEqual(md.attributedString().string, "An italic string, follwed by a bold one, with some code, **and some** _escaped_ `characters`, ending with more variety.\n")
		
	}
	
	func testThatMarkdownMistakesAreHandledAppropriately() {
		let mismatchedBoldCharactersAtStart = "**This should be bold*"
		let mismatchedBoldCharactersWithin = "A string *that should be italic**"
		
		var md = SwiftyMarkdown(string: mismatchedBoldCharactersAtStart)
		XCTAssertEqual(md.attributedString().string, "This should be bold\n")
		
		md = SwiftyMarkdown(string: mismatchedBoldCharactersWithin)
		XCTAssertEqual(md.attributedString().string, "A string that should be italic\n")
		
	}
	
	func testThatEscapedCharactersAreEscapedCorrectly() {
		let escapedBoldAtStart = "\\*\\*A normal string\\*\\*"
		let escapedBoldWithin = "A string with \\*\\*escaped\\*\\* asterisks"
		
		let escapedItalicAtStart = "\\_A normal string\\_"
		let escapedItalicWithin = "A string with \\_escaped\\_ underscores"
		
		let escapedBackticksAtStart = "\\`A normal string\\`"
		let escapedBacktickWithin = "A string with \\`escaped\\` backticks"
		
		let oneEscapedAsteriskOneNormalAtStart = "\\**A normal string\\**"
		let oneEscapedAsteriskOneNormalWithin = "A string with \\**escaped\\** asterisks"
		
		let oneEscapedAsteriskTwoNormalAtStart = "\\***A normal string*\\**"
		let oneEscapedAsteriskTwoNormalWithin = "A string with *\\**escaped**\\* asterisks"
		
		var md = SwiftyMarkdown(string: escapedBoldAtStart)
		XCTAssertEqual(md.attributedString().string, "**A normal string**\n")

		md = SwiftyMarkdown(string: escapedBoldWithin)
		XCTAssertEqual(md.attributedString().string, "A string with **escaped** asterisks\n")
		
		md = SwiftyMarkdown(string: escapedItalicAtStart)
		XCTAssertEqual(md.attributedString().string, "_A normal string_\n")
		
		md = SwiftyMarkdown(string: escapedItalicWithin)
		XCTAssertEqual(md.attributedString().string, "A string with _escaped_ underscores\n")
		
		md = SwiftyMarkdown(string: escapedBackticksAtStart)
		XCTAssertEqual(md.attributedString().string, "`A normal string`\n")
		
		md = SwiftyMarkdown(string: escapedBacktickWithin)
		XCTAssertEqual(md.attributedString().string, "A string with `escaped` backticks\n")
		
		md = SwiftyMarkdown(string: oneEscapedAsteriskOneNormalAtStart)
		XCTAssertEqual(md.attributedString().string, "*A normal string*\n")
		
		md = SwiftyMarkdown(string: oneEscapedAsteriskOneNormalWithin)
		XCTAssertEqual(md.attributedString().string, "A string with *escaped* asterisks\n")
		
		md = SwiftyMarkdown(string: oneEscapedAsteriskTwoNormalAtStart)
		XCTAssertEqual(md.attributedString().string, "*A normal string*\n")
		
		md = SwiftyMarkdown(string: oneEscapedAsteriskTwoNormalWithin)
		XCTAssertEqual(md.attributedString().string, "A string with *escaped* asterisks\n")
		
	}
	
	func testThatAsterisksAndUnderscoresNotAttachedToWordsAreNotRemoved() {
		let asteriskSpace = "An asterisk followed by a space: * "
		let backtickSpace = "A backtick followed by a space: ` "
		let underscoreSpace = "An underscore followed by a space: _ "

		let asteriskFullStop = "Two asterisks followed by a full stop: **."
		let backtickFullStop = "Two backticks followed by a full stop: ``."
		let underscoreFullStop = "Two underscores followed by a full stop: __."
		
		let asteriskComma = "An asterisk followed by a full stop: *, *"
		let backtickComma = "A backtick followed by a space: `, `"
		let underscoreComma = "An underscore followed by a space: _, _"
		
		let asteriskWithBold = "A **bold** word followed by an asterisk * "
		let backtickWithCode = "A `code` word followed by a backtick ` "
		let underscoreWithItalic = "An _italic_ word followed by an underscore _ "
		
		var md = SwiftyMarkdown(string: asteriskSpace)
		XCTAssertEqual(md.attributedString().string, asteriskSpace + "\n")
		
		md = SwiftyMarkdown(string: backtickSpace)
		XCTAssertEqual(md.attributedString().string, backtickSpace + "\n")
		
		md = SwiftyMarkdown(string: underscoreSpace)
		XCTAssertEqual(md.attributedString().string, underscoreSpace + "\n")
		
		md = SwiftyMarkdown(string: asteriskFullStop)
		XCTAssertEqual(md.attributedString().string, asteriskFullStop + "\n")
		
		md = SwiftyMarkdown(string: backtickFullStop)
		XCTAssertEqual(md.attributedString().string, backtickFullStop + "\n")
		
		md = SwiftyMarkdown(string: underscoreFullStop)
		XCTAssertEqual(md.attributedString().string, underscoreFullStop + "\n")
		
		md = SwiftyMarkdown(string: asteriskComma)
		XCTAssertEqual(md.attributedString().string, asteriskComma + "\n")
		
		md = SwiftyMarkdown(string: backtickComma)
		XCTAssertEqual(md.attributedString().string, backtickComma + "\n")
		
		md = SwiftyMarkdown(string: underscoreComma)
		XCTAssertEqual(md.attributedString().string, underscoreComma + "\n")
		
		md = SwiftyMarkdown(string: asteriskWithBold)
		XCTAssertEqual(md.attributedString().string, "A bold word followed by an asterisk * \n")
		
		md = SwiftyMarkdown(string: backtickWithCode)
		XCTAssertEqual(md.attributedString().string, "A code word followed by a backtick ` \n")
		
		md = SwiftyMarkdown(string: underscoreWithItalic)
		XCTAssertEqual(md.attributedString().string, "An italic word followed by an underscore _ \n")
		
	}
	
	
	func testForLinks() {
		
		let linkAtStart = "[Link at start](http://voyagetravelapps.com/)"
		let linkWithin = "A [Link](http://voyagetravelapps.com/)"
		let headerLink = "## [Header link](http://voyagetravelapps.com/)"
		
		let multipleLinks = "[Link 1](http://voyagetravelapps.com/), [Link 2](http://voyagetravelapps.com/)"

		let mailtoAndTwitterLinks = "Email us at [simon@voyagetravelapps.com](mailto:simon@voyagetravelapps.com) Twitter [@VoyageTravelApp](twitter://user?screen_name=VoyageTravelApp)"
		
		let syntaxErrorSquareBracketAtStart = "[Link with missing square(http://voyagetravelapps.com/)"
		let syntaxErrorSquareBracketWithin = "A [Link(http://voyagetravelapps.com/)"
		
		let syntaxErrorParenthesisAtStart = "[Link with missing parenthesis](http://voyagetravelapps.com/"
		let syntaxErrorParenthesisWithin = "A [Link](http://voyagetravelapps.com/"
		
		var md = SwiftyMarkdown(string: linkAtStart)
		XCTAssertEqual(md.attributedString().string, "Link at start\n")
		
		md = SwiftyMarkdown(string: linkWithin)
		XCTAssertEqual(md.attributedString().string, "A Link\n")
		
		md = SwiftyMarkdown(string: headerLink)
		XCTAssertEqual(md.attributedString().string, "Header link\n")
		
		md = SwiftyMarkdown(string: multipleLinks)
		XCTAssertEqual(md.attributedString().string, "Link 1, Link 2\n")
		
		md = SwiftyMarkdown(string: syntaxErrorSquareBracketAtStart)
		XCTAssertEqual(md.attributedString().string, "Link with missing square\n")
		
		md = SwiftyMarkdown(string: syntaxErrorSquareBracketWithin)
		XCTAssertEqual(md.attributedString().string, "A Link\n")
		
		md = SwiftyMarkdown(string: syntaxErrorParenthesisAtStart)
		XCTAssertEqual(md.attributedString().string, "Link with missing parenthesis\n")
		
		md = SwiftyMarkdown(string: syntaxErrorParenthesisWithin)
		XCTAssertEqual(md.attributedString().string, "A Link\n")
		
		md = SwiftyMarkdown(string: mailtoAndTwitterLinks)
		XCTAssertEqual(md.attributedString().string, "Email us at simon@voyagetravelapps.com Twitter @VoyageTravelApp\n")
		
	
		
//		let mailtoAndTwitterLinks = "Twitter [@VoyageTravelApp](twitter://user?screen_name=VoyageTravelApp)"
//		let md = SwiftyMarkdown(string: mailtoAndTwitterLinks)
//		XCTAssertEqual(md.attributedString().string, "Twitter @VoyageTravelApp\n")
	}
	

	
}
