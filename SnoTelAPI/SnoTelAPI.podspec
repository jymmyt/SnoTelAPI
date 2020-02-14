#
# Be sure to run `pod lib lint SnoTelAPI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SnoTelAPI'
  s.version          = '0.1.0'
  s.summary          = 'An iOS SDK for the Powder lines api at : http://powderlin.es/api.html'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An iOS SDK for the Powder lines api at : http://powderlin.es/api.html
The sdk uses Swift 5, and the new Combine iOS framework
                       DESC

  s.homepage         = 'https://github.com/jymmyt/SnoTelAPI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jim Terhorst' => 'jymter@gmail.com' }
  s.source           = { :git => 'https://github.com/jymmyt/SnoTelAPI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'Classes/**/*'
  
  
  # s.resource_bundles = {
  #   'SnoTelAPI' => ['SnoTelAPI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SwiftCSV'
end
