Pod::Spec.new do |s|
  s.name = 'XXNibBridge'
  s.version = '1.0'
  s.license = 'MIT'
  s.platform = :ios
  s.summary = "Bridging interface builders, support nested nibs"
  s.homepage = 'https://github.com/sunnyxx/XXNibBridge'
  s.author = { 'sunnyxx' => 'sunnyxx.github.io' }
  s.source = { :git => 'https://github.com/sunnyxx/XXNibBridge.git'}
  s.source_files = 'XXNibBridge/*.{h,m}'
  s.requires_arc = true
end