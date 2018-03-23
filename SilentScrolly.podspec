Pod::Spec.new do |s|
    s.name        = "SilentScrolly"
    s.version     = "1.0.6"
    s.summary     = "Scroll to hide navigationBar, tabBar and toolBar."
    s.description = <<-DESC
                    Adding too much UIGestureRecognizer to the UIView makes handling difficult, so it was handled by UIScrollViewDelegate.
                    DESC
    s.homepage         = "https://github.com/horitaku46/SilentScrolly"
    s.license          = { :type => "MIT", :file => "./LICENSE" }
    s.author           = { "Takuma Horiuchi" => "horitaku46@gmail.com" }
    s.social_media_url = "https://twitter.com/horitaku46"
    s.platform         = :ios, "11.0"
    s.source           = { :git => "https://github.com/horitaku46/SilentScrolly.git", :tag => "#{s.version}" }
    s.source_files     = "SilentScrolly/**/*.{swift}"
    s.swift_version    = "4.0"
end
