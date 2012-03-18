require 'date'

Gem::Specification.new do |spec|

  spec.name                      =  'compositing-array'
  spec.rubyforge_project         =  'compositing-array'
  spec.version                   =  '1.0.3'

  spec.summary                   =  "Provides CompositingArray."
  spec.description               =  "An implementation of Array that permits chaining, where children inherit changes to parent and where parent settings can be overridden in children."

  spec.authors                   =  [ 'Asher' ]
  spec.email                     =  'asher@ridiculouspower.com'
  spec.homepage                  =  'http://rubygems.org/gems/compositing-array'

  spec.date                      =  Date.today.to_s
  
  spec.files                     = Dir[ '{lib,spec}/**/*',
                                        'README*', 
                                        'LICENSE*' ]

end
