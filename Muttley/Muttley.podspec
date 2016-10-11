Pod::Spec.new do |s|
    s.name        = "Muttley"
    s.version     = "1.0"
    s.summary     = "Lightweight Networking for Swift"
    s.homepage    = "https://github.com/zolomatok/Muttley"
    s.license     = { :type => "MIT" }
    s.authors     = { "Zoltán Matók" => "bellamycpt@gmail.com" }

    s.source   = { :git => "https://github.com/zolomatok/Muttley.git", :tag => "1.0"}
    s.requires_arc = true
    s.module_name = 'Muttley'

    s.ios.deployment_target = "8.0"

    s.ios.source_files = 'Muttley/*.swift'
    s.ios.frameworks = 'UIKit', 'Foundation'

    s.dependency 'AsyncSwift'
end
