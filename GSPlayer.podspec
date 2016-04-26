#
# Be sure to run `pod lib lint GSPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

  s.name             = "GSPlayer"
  s.version          = "0.1.0"
  s.summary          = "Swift, video player, based on AVPlayer."

  s.homepage         = "https://github.com/wxxsw/GSPlayer"

  s.license          = 'MIT'
  s.author           = { "Ge Sen" => "wxxsw2@gmail.com" }
  s.source           = { :git => "https://github.com/wxxsw/GSPlayer.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'GSPlayer' => ['Pod/Assets/*.png']
  }

end
