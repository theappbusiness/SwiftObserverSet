
Pod::Spec.new do |s|
  s.name            = 'TABObserverSet'
  s.version         = '1.1.1'
  s.summary         = 'NotificationCenter re-conceptualization for Swift.'
  s.description     = <<-DESC
	TABObserverSet provides a Swift-y alternative to the traditional NotificationCenter style of reactive programming.
	With a simple syntax, TABObserverSet is easy to use and read in your code.
                       DESC
  s.homepage        = 'https://github.com/theappbusiness/TABObserverSet'
  s.license         = { :type => 'BSD', :file => 'LICENSE' }
  s.authors         = { 'Kane Cheshire' => 'kane.cheshire@theappbusiness.com' }
  s.source          = { :git => 'https://github.com/theappbusiness/TABObserverSet.git', :tag => s.version.to_s }
  s.platforms       = { :ios => "8.0", :osx => "10.10", :watchos => "2.0", :tvos => "9.0" }
  s.source_files    = 'TABObserverSet/Classes/**/*', 'ObserverSet.swift'
end
