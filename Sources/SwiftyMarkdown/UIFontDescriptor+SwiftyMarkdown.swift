//
//  UIFontDescriptor+SwiftyMarkdown.swift
//  SwiftyMarkdown
//
//  Created by Massimo Oliviero on 17/06/21.
//

#if !os(macOS)

import UIKit

extension UIFontDescriptor {
    static let textStyleSizeTable: [UIFont.TextStyle: [UIContentSizeCategory: CGFloat]] = [
        .title1: [
            .accessibilityExtraExtraExtraLarge: 58,
            .accessibilityExtraExtraLarge: 53,
            .accessibilityExtraLarge: 48,
            .accessibilityLarge: 43,
            .accessibilityMedium: 38,
            .extraExtraExtraLarge: 34,
            .extraExtraLarge: 32,
            .extraLarge: 30,
            .large: 28,
            .medium: 27,
            .small: 26,
            .extraSmall: 25
        ],
        .title2: [
            .accessibilityExtraExtraExtraLarge: 56,
            .accessibilityExtraExtraLarge: 50,
            .accessibilityExtraLarge: 44,
            .accessibilityLarge: 39,
            .accessibilityMedium: 34,
            .extraExtraExtraLarge: 28,
            .extraExtraLarge: 26,
            .extraLarge: 24,
            .large: 22,
            .medium: 21,
            .small: 20,
            .extraSmall: 19
        ],
        .title3: [
            .accessibilityExtraExtraExtraLarge: 55,
            .accessibilityExtraExtraLarge: 49,
            .accessibilityExtraLarge: 43,
            .accessibilityLarge: 37,
            .accessibilityMedium: 31,
            .extraExtraExtraLarge: 26,
            .extraExtraLarge: 24,
            .extraLarge: 22,
            .large: 20,
            .medium: 19,
            .small: 18,
            .extraSmall: 17
        ],
        .callout: [
            .accessibilityExtraExtraExtraLarge: 51,
            .accessibilityExtraExtraLarge: 44,
            .accessibilityExtraLarge: 38,
            .accessibilityLarge: 32,
            .accessibilityMedium: 26,
            .extraExtraExtraLarge: 22,
            .extraExtraLarge: 20,
            .extraLarge: 18,
            .large: 16,
            .medium: 15,
            .small: 14,
            .extraSmall: 13
        ],
        .headline: [
            .accessibilityExtraExtraExtraLarge: 53,
            .accessibilityExtraExtraLarge: 47,
            .accessibilityExtraLarge: 40,
            .accessibilityLarge: 33,
            .accessibilityMedium: 28,
            .extraExtraExtraLarge: 23,
            .extraExtraLarge: 21,
            .extraLarge: 19,
            .large: 17,
            .medium: 16,
            .small: 15,
            .extraSmall: 14
        ],
        .subheadline: [
            .accessibilityExtraExtraExtraLarge: 49,
            .accessibilityExtraExtraLarge: 42,
            .accessibilityExtraLarge: 36,
            .accessibilityLarge: 30,
            .accessibilityMedium: 25,
            .extraExtraExtraLarge: 21,
            .extraExtraLarge: 19,
            .extraLarge: 17,
            .large: 15,
            .medium: 14,
            .small: 13,
            .extraSmall: 12
        ],
        .body: [
            .accessibilityExtraExtraExtraLarge: 53,
            .accessibilityExtraExtraLarge: 47,
            .accessibilityExtraLarge: 40,
            .accessibilityLarge: 33,
            .accessibilityMedium: 28,
            .extraExtraExtraLarge: 23,
            .extraExtraLarge: 21,
            .extraLarge: 19,
            .large: 17,
            .medium: 16,
            .small: 15,
            .extraSmall: 14
        ],
        .caption1: [
            .accessibilityExtraExtraExtraLarge: 43,
            .accessibilityExtraExtraLarge: 37,
            .accessibilityExtraLarge: 32,
            .accessibilityLarge: 26,
            .accessibilityMedium: 22,
            .extraExtraExtraLarge: 18,
            .extraExtraLarge: 16,
            .extraLarge: 14,
            .large: 12,
            .medium: 11,
            .small: 11,
            .extraSmall: 11
        ],
        .caption2: [
            .accessibilityExtraExtraExtraLarge: 40,
            .accessibilityExtraExtraLarge: 34,
            .accessibilityExtraLarge: 29,
            .accessibilityLarge: 24,
            .accessibilityMedium: 20,
            .extraExtraExtraLarge: 17,
            .extraExtraLarge: 15,
            .extraLarge: 13,
            .large: 11,
            .medium: 11,
            .small: 11,
            .extraSmall: 11
        ],
        .footnote: [
            .accessibilityExtraExtraExtraLarge: 44,
            .accessibilityExtraExtraLarge: 38,
            .accessibilityExtraLarge: 33,
            .accessibilityLarge: 27,
            .accessibilityMedium: 23,
            .extraExtraExtraLarge: 19,
            .extraExtraLarge: 17,
            .extraLarge: 15,
            .large: 13,
            .medium: 12,
            .small: 12,
            .extraSmall: 12
        ]
    ]

    static func scaledFont(for font: UIFont, with textStyle: UIFont.TextStyle) -> UIFont {
        let contentSize = UIApplication.shared.preferredContentSizeCategory
        let fontSize = textStyleSizeTable[textStyle]?[contentSize] ?? UIFont.systemFontSize
        let descriptor = UIFontDescriptor(name: font.fontName, size: fontSize)
        return UIFont(descriptor: descriptor, size: 0)
    }
}

#endif
