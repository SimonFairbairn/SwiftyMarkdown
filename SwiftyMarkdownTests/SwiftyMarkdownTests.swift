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
		XCTAssertEqual(md.attributedString().string, "Header 1\nHeader 2\nHeader 3\nHeader 4\nHeader 5\nHeader 6")
		
		 md = SwiftyMarkdown(string: headerStringWithBold)
		XCTAssertEqual(md.attributedString().string, "Bold Header 1")
		
		md = SwiftyMarkdown(string: headerStringWithItalic)
		XCTAssertEqual(md.attributedString().string, "Header 2 With Italics")
		
	}
	
	func testThatUndelinedHeadersAreHandledCorrectly() {
		let h1String = "Header 1\n===\nSome following text"
		let h2String = "Header 2\n---\nSome following text"
		
		let h1StringWithBold = "Header 1 **With Bold**\n===\nSome following text"
		let h2StringWithItalic = "Header 2 _With Italic_\n---\nSome following text"
		let h2StringWithCode = "Header 2 `With Code`\n---\nSome following text"
		
		var md = SwiftyMarkdown(string: h1String)
		XCTAssertEqual(md.attributedString().string, "Header 1\nSome following text")
		
		md = SwiftyMarkdown(string: h2String)
		XCTAssertEqual(md.attributedString().string, "Header 2\nSome following text")
		
		md = SwiftyMarkdown(string: h1StringWithBold)
		XCTAssertEqual(md.attributedString().string, "Header 1 With Bold\nSome following text")
		
		md = SwiftyMarkdown(string: h2StringWithItalic)
		XCTAssertEqual(md.attributedString().string, "Header 2 With Italic\nSome following text")
		
		md = SwiftyMarkdown(string: h2StringWithCode)
		XCTAssertEqual(md.attributedString().string, "Header 2 With Code\nSome following text")
	}
	
	func testThatRegularTraitsAreParsedCorrectly() {
		let boldAtStartOfString = "**A bold string**"
		let boldWithinString = "A string with a **bold** word"
		let codeAtStartOfString = "`Code (should be indented)`"
		let codeWithinString = "A string with `code` (should not be indented)"
		let italicAtStartOfString = "*An italicised string*"
		let italicWithinString = "A string with *italicised* text"
        let strikethroughAtStartOfString = "~~A strikethrough string~~"
        let strikethroughWithinString = "A string with a ~~strikethrough~~ word"
		
		let multipleBoldWords = "__A bold string__ with a **mix** **of** bold __styles__"
		let multipleCodeWords = "`A code string` with multiple `code` `instances`"
		let multipleItalicWords = "_An italic string_ with a *mix* _of_ italic *styles*"
		
		let longMixedString = "_An italic string_, **follwed by a bold one**, `with some code`, \\*\\*and some\\*\\* \\_escaped\\_ \\`characters\\`, `ending` *with* __more__ variety."
		
		
		var md = SwiftyMarkdown(string: boldAtStartOfString)
		XCTAssertEqual(md.attributedString().string, "A bold string")
		
		md = SwiftyMarkdown(string: boldWithinString)
		XCTAssertEqual(md.attributedString().string, "A string with a bold word")
		
		md = SwiftyMarkdown(string: codeAtStartOfString)
		XCTAssertEqual(md.attributedString().string, "\tCode (should be indented)")
		
		md = SwiftyMarkdown(string: codeWithinString)
		XCTAssertEqual(md.attributedString().string, "A string with code (should not be indented)")
		
		md = SwiftyMarkdown(string: italicAtStartOfString)
		XCTAssertEqual(md.attributedString().string, "An italicised string")
		
		md = SwiftyMarkdown(string: italicWithinString)
		XCTAssertEqual(md.attributedString().string, "A string with italicised text")

        md = SwiftyMarkdown(string: strikethroughAtStartOfString)
        XCTAssertEqual(md.attributedString().string, "A strikethrough string")

        md = SwiftyMarkdown(string: strikethroughWithinString)
        XCTAssertEqual(md.attributedString().string, "A string with a strikethrough word")
		
		md = SwiftyMarkdown(string: multipleBoldWords)
		XCTAssertEqual(md.attributedString().string, "A bold string with a mix of bold styles")
		
		md = SwiftyMarkdown(string: multipleCodeWords)
		XCTAssertEqual(md.attributedString().string, "\tA code string with multiple code instances")
		
		md = SwiftyMarkdown(string: multipleItalicWords)
		XCTAssertEqual(md.attributedString().string, "An italic string with a mix of italic styles")

		md = SwiftyMarkdown(string: longMixedString)
		XCTAssertEqual(md.attributedString().string, "An italic string, follwed by a bold one, with some code, **and some** _escaped_ `characters`, ending with more variety.")
		
	}
	
	func testThatMarkdownMistakesAreHandledAppropriately() {
		let mismatchedBoldCharactersAtStart = "**This should be bold*"
		let mismatchedBoldCharactersWithin = "A string *that should be italic**"
		
		var md = SwiftyMarkdown(string: mismatchedBoldCharactersAtStart)
		XCTAssertEqual(md.attributedString().string, "This should be bold")
		
		md = SwiftyMarkdown(string: mismatchedBoldCharactersWithin)
		XCTAssertEqual(md.attributedString().string, "A string that should be italic")
		
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
		XCTAssertEqual(md.attributedString().string, "**A normal string**")

		md = SwiftyMarkdown(string: escapedBoldWithin)
		XCTAssertEqual(md.attributedString().string, "A string with **escaped** asterisks")
		
		md = SwiftyMarkdown(string: escapedItalicAtStart)
		XCTAssertEqual(md.attributedString().string, "_A normal string_")
		
		md = SwiftyMarkdown(string: escapedItalicWithin)
		XCTAssertEqual(md.attributedString().string, "A string with _escaped_ underscores")
		
		md = SwiftyMarkdown(string: escapedBackticksAtStart)
		XCTAssertEqual(md.attributedString().string, "`A normal string`")
		
		md = SwiftyMarkdown(string: escapedBacktickWithin)
		XCTAssertEqual(md.attributedString().string, "A string with `escaped` backticks")
		
		md = SwiftyMarkdown(string: oneEscapedAsteriskOneNormalAtStart)
		XCTAssertEqual(md.attributedString().string, "*A normal string*")
		
		md = SwiftyMarkdown(string: oneEscapedAsteriskOneNormalWithin)
		XCTAssertEqual(md.attributedString().string, "A string with *escaped* asterisks")
		
		md = SwiftyMarkdown(string: oneEscapedAsteriskTwoNormalAtStart)
		XCTAssertEqual(md.attributedString().string, "*A normal string*")
		
		md = SwiftyMarkdown(string: oneEscapedAsteriskTwoNormalWithin)
		XCTAssertEqual(md.attributedString().string, "A string with *escaped* asterisks")
		
	}
	
	func testThatAsterisksAndUnderscoresNotAttachedToWordsAreNotRemoved() {
		let asteriskSpace = """
An asterisk followed by a space: *
Line break
"""
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
		XCTAssertEqual(md.attributedString().string, asteriskSpace)
		
		md = SwiftyMarkdown(string: backtickSpace)
		XCTAssertEqual(md.attributedString().string, backtickSpace)
		
		md = SwiftyMarkdown(string: underscoreSpace)
		XCTAssertEqual(md.attributedString().string, underscoreSpace)
		
		md = SwiftyMarkdown(string: asteriskFullStop)
		XCTAssertEqual(md.attributedString().string, asteriskFullStop)
		
		md = SwiftyMarkdown(string: backtickFullStop)
		XCTAssertEqual(md.attributedString().string, backtickFullStop)
		
		md = SwiftyMarkdown(string: underscoreFullStop)
		XCTAssertEqual(md.attributedString().string, underscoreFullStop)
		
		md = SwiftyMarkdown(string: asteriskComma)
		XCTAssertEqual(md.attributedString().string, asteriskComma)
		
		md = SwiftyMarkdown(string: backtickComma)
		XCTAssertEqual(md.attributedString().string, backtickComma)
		
		md = SwiftyMarkdown(string: underscoreComma)
		XCTAssertEqual(md.attributedString().string, underscoreComma)
		
		md = SwiftyMarkdown(string: asteriskWithBold)
		XCTAssertEqual(md.attributedString().string, "A bold word followed by an asterisk * ")
		
		md = SwiftyMarkdown(string: backtickWithCode)
		XCTAssertEqual(md.attributedString().string, "A code word followed by a backtick ` ")
		
		md = SwiftyMarkdown(string: underscoreWithItalic)
		XCTAssertEqual(md.attributedString().string, "An italic word followed by an underscore _ ")
		
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
		XCTAssertEqual(md.attributedString().string, "Link at start")
		
		md = SwiftyMarkdown(string: linkWithin)
		XCTAssertEqual(md.attributedString().string, "A Link")
		
		md = SwiftyMarkdown(string: headerLink)
		XCTAssertEqual(md.attributedString().string, "Header link")
		
		md = SwiftyMarkdown(string: multipleLinks)
		XCTAssertEqual(md.attributedString().string, "Link 1, Link 2")
		
		md = SwiftyMarkdown(string: syntaxErrorSquareBracketAtStart)
		XCTAssertEqual(md.attributedString().string, "Link with missing square")
		
		md = SwiftyMarkdown(string: syntaxErrorSquareBracketWithin)
		XCTAssertEqual(md.attributedString().string, "A Link")
		
		md = SwiftyMarkdown(string: syntaxErrorParenthesisAtStart)
		XCTAssertEqual(md.attributedString().string, "Link with missing parenthesis")
		
		md = SwiftyMarkdown(string: syntaxErrorParenthesisWithin)
		XCTAssertEqual(md.attributedString().string, "A Link")
		
		md = SwiftyMarkdown(string: mailtoAndTwitterLinks)
		XCTAssertEqual(md.attributedString().string, "Email us at simon@voyagetravelapps.com Twitter @VoyageTravelApp")
		
	
		
//		let mailtoAndTwitterLinks = "Twitter [@VoyageTravelApp](twitter://user?screen_name=VoyageTravelApp)"
//		let md = SwiftyMarkdown(string: mailtoAndTwitterLinks)
//		XCTAssertEqual(md.attributedString().string, "Twitter @VoyageTravelApp")
	}
	
    /*
        The reason for this test is because the list of items dropped every other item in bullet lists marked with "-"
        The faulty result was: "A cool title\n \n- Här har vi svenska ÅÄÖåäö tecken\n \nA Link"
        As you can see, "- Point number one" and "- Point number two" are mysteriously missing.
        It incorrectly identified rows as `Alt-H2` 
     */
    func testInternationalCharactersInList() {
        
        let extected = "A cool title\n \n- Point number one\n- Här har vi svenska ÅÄÖåäö tecken\n- Point number two\n \nA Link"
        let input = "# A cool title\n\n- Point number one\n- Här har vi svenska ÅÄÖåäö tecken\n- Point number two\n\n[A Link](http://dooer.com)"
        let output = SwiftyMarkdown(string: input).attributedString().string

        XCTAssertEqual(output, extected)
        
    }
	
}
