Pod::Spec.new do |s|
  s.name         = "Sherpa"
  s.version      = "0.1.0"
  s.summary      = "A drop-in view controller for displaying a User Guide or FAQ."
  s.homepage     = "https://github.com/jellybeansoup/ios-sherpa"
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { "Daniel Farrelly" => "daniel@jellystyle.com" }
  s.source       = { :git => "https://github.com/jellybeansoup/ios-sherpa.git", :tag => "v#{spec.version}" }
  s.platform     = :ios, '9.0'
  s.source_files = 'src/Sherpa/*.{swift,h}'
end
