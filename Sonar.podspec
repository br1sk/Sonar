Pod::Spec.new do |s|
  s.name                  = "Sonar"
  s.version               = "0.0.1"
  s.summary               = "Apple's radar communication in Swift"
  s.homepage              = "https://github.com/br1sk/Sonar"
  s.license               = "MIT"
  s.author                = { "Martin Conte Mac Donell" => "reflejo@gmail.com" }
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"
  s.source                = { :git => "https://github.com/br1sk/Sonar.git" }
  s.source_files          = "Sources/Sonar/**/*.swift"
  s.requires_arc          = true
  s.dependency              "Alamofire", "~> 4.7.2"
end
