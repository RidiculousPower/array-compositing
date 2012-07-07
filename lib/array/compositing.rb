
require 'array/hooked'
#require_relative '../../../../hooked_objects/array-hooked/lib/array-hooked.rb'

# namespaces that have to be declared ahead of time for proper load order
require_relative './namespaces'

# source file requires
require_relative './requires.rb'

class ::Array::Compositing < ::Array::Hooked

  include ::Array::Compositing::ArrayInterface
  
end
