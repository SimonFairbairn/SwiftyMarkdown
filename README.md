# SwiftyMarkdown

SwiftyMarkdown converts Markdown files and strings into NSAttributedString using sensible defaults and a Swift-style syntax. It uses dynamic type to set the font size correctly with whatever font you'd like to use

## Installation

CocoaPods:

`pod 'SwiftyMarkdown'`

## Usage

Text string
```swift
let md = SwiftyMarkdown(string: "# Heading\nMy *Markdown* string")
md.attributedString()
```

URL 
```swift
if let url = Bundle.main.url(forResource: "file", withExtension: "md"), md = SwiftyMarkdown(url: url ) {
	md.attributedString()
}
```

## Supported Features

    *italics* or _italics_
    **bold** or __bold__

    # Header 1
    ## Header 2
    ### Header 3
    #### Header 4
    ##### Header 5
    ###### Header 6
    
    `code`
    [Links](http://voyagetravelapps.com/)

## Customisation 
```swift
md.body.fontName = "AvenirNextCondensed-Medium"

md.h1.color = UIColor.red // NSColor.red
md.h1.fontName = "AvenirNextCondensed-Bold"
md.h1.fontSize = 16
md.italic.color = UIColor.blue // NSColor.blue
```

## Screenshot

![Screenshot](http://f.cl.ly/items/12332k3f2s0s0C281h2u/swiftymarkdown.png)


