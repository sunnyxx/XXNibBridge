
Pod::Spec.new do |s|
  s.name         = "XXNibBridge"
  s.version      = "2.0"
  s.summary      = "XXNibBridge"
  s.description  = "Bridge a nib file to another nib or storyboard"
  s.homepage     = "https://github.com/sunnyxx/XXNibBridge"
  s.screenshots  = "https://camo.githubusercontent.com/79e8b3019e36b99f796966f8df118e18576ff781/687474703a2f2f7777322e73696e61696d672e636e2f6c617267652f353135333035383367773165687a676b6c696b34326a32306d3830676f3075612e6a7067"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "sunnyxx" => "sunyuan1713@gmail.com" }
  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "6.0"
  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/sunnyxx/XXNibBridge.git", :tag => "2.0" }
  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "XXNibBridge/*.{h,m}"
  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true
end
