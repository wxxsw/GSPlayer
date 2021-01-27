Pod::Spec.new do |s|
  s.name         = 'GSPlayer'
  s.version      = '0.2.19'
  s.summary      = '⏯ Video player, support for caching, fullscreen transition and custom control view. 视频播放器，支持边下边播、全屏转场和自定义控制层'
  s.homepage     = 'https://github.com/wxxsw/GSPlayer'
  
  s.license      = 'MIT'
  s.author       = { 'Gesen' => 'i@gesen.me' }
  s.source       = { :git => 'https://github.com/wxxsw/GSPlayer.git', :tag => s.version.to_s }
  
  s.source_files = 'GSPlayer/Classes/**/*.swift'
  
  s.ios.deployment_target = '10.0'
  s.swift_versions = ['5.0']
end
