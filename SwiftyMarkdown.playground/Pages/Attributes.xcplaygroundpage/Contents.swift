import UIKit
import XCPlayground

var str = "Hello, playground"

let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 600))
XCPlaygroundPage.currentPage.liveView = containerView
let label = UITextView(frame: containerView.frame)
containerView.addSubview(label)


let markdownString = "# Chuck Norris Facts\n\n## Economics\n\nChuck Norris' face has appeared on *every* coin and banknote since 1918. No one has ever noticed because **he is always in disguise**.\n\nThe chief export of Chuck Norris is **Pain**.\n\n## Physics\n\nChuck Norris Fell Down The Stairs And Broke *Somebody Else's* Leg.\n\nWhen Chuck Norris does a pushup, he isn't lifting himself up, he's pushing the Earth **down**.\n\n## Legal\n\nChuck Norris is currently suing NBC, claiming *Law and Order* are trademarked names for his left and right legs."



let markdownParser = SwiftyMarkdown(string: markdownString)

let h1ParagraphStyle = NSMutableParagraphStyle()
h1ParagraphStyle.paragraphSpacing = 5

markdownParser.h1 = [NSFontAttributeName: UIFont(name: "Optima", size: 17)!,
                     NSParagraphStyleAttributeName: h1ParagraphStyle
]

let h2ParagraphStyle = NSMutableParagraphStyle()
h2ParagraphStyle.paragraphSpacing = 2

markdownParser.h2 = [NSFontAttributeName: UIFont(name: "Optima", size: 15)!,
                     NSParagraphStyleAttributeName: h2ParagraphStyle
]


markdownParser.body = [NSFontAttributeName: UIFont(name: "Optima-Regular", size: 13)!,]

markdownParser.italic = [NSFontAttributeName: UIFont(name: "Optima-Italic", size: 13)!]
markdownParser.bold = [NSFontAttributeName: UIFont(name: "Optima-Bold", size: 14)!]

label.attributedText = markdownParser.attributedString()
