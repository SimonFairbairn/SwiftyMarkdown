//
//  SwiftyMarkdownAttributedStringTests.swift
//  SwiftyMarkdownTests
//
//  Created by Simon Fairbairn on 17/12/2019.
//  Copyright © 2019 Voyage Travel Apps. All rights reserved.
//

import XCTest
@testable import SwiftyMarkdown

class SwiftyMarkdownAttributedStringTests: XCTestCase {
	
	func testThatAttributesAreAppliedCorrectly() {
		
		let string = """
# Heading 1

A more *complicated* example. This one has **it all**. Here is a [link](http://voyagetravelapps.com/).

## Heading 2

## Heading 3

> This one is a blockquote
"""
		let md = SwiftyMarkdown(string: string)
		let attributedString = md.attributedString()
		
		XCTAssertNotNil(attributedString)
		
		XCTAssertEqual(attributedString.string, "Heading 1\n\nA more complicated example. This one has it all. Here is a link.\n\nHeading 2\n\nHeading 3\n\nThis one is a blockquote")
	}

    func testComplexPatternDoesNotHangForever() {
        let string = "**~*~~~*~*~**~*~* h e a r d ***~*~*~**~*~~~*"

        let md = SwiftyMarkdown(string: string)
        let attributedString = md.attributedString()

        XCTAssertNotNil(attributedString)
        XCTAssertEqual(attributedString.string, "**~~*~**~~ h e a r d ***~~~**~")
    }
}
