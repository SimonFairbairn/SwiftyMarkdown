Pod::Spec.new do |s|
s.name             = "SwiftyMarkdown"
s.version          = "1.2.3"
s.summary          = "Converts Markdown to NSAttributed String"
s.homepage         = "https://github.com/SimonFairbairn/SwiftyMarkdown"
s.license          = 'MIT'
s.author           = { "Simon Fairbairn" => "simon@voyagetravelapps.com" }
s.source           = { :git => "https://github.com/SimonFairbairn/SwiftyMarkdown.git", :tag => s.version }
s.social_media_url = 'https://twitter.com/SimonFairbairn'

s.ios.deployment_target = "10.0"
s.tvos.deployment_target = "11.0"
s.osx.deployment_target = "10.12"
s.watchos.deployment_target = "4.0"
s.requires_arc = true

s.source_files = 'Sources/SwiftyMarkdown/**/*'

s.swift_version = "5.0"

end
