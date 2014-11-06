Pod::Spec.new do |s|
  s.name           	= 'BDGShare'
  s.version        	= '0.0.2'
  s.summary        	= 'Lightweight sharing class with completion blocks for facebook, twitter, whatsapp, e-mail, sms, etc.'
  s.description 	= 'Share using facebook, twitter, whatsapp, email, text message, activitycontroller, documentinteractioncontroller, all with 1 line and great completion blocks'
  s.homepage       	= 'https://github.com/BobDG/BDGShare'
  s.authors        	= {'Bob de Graaf' => 'graafict@gmail.com'}
  s.license 		= 'MIT'
  s.source         	= { :git => 'https://github.com/BobDG/BDGShare.git', :tag => '0.0.2' }
  s.source_files   	= '**/*.{h,m}'
  s.resources          = ['**/*.{png}', '**/*.lproj']
  s.frameworks 	    	= 'Social', 'MessageUI'
  s.platform       	= :ios
  s.requires_arc   	= true
end
