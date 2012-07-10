
require 'array/hooked'
#require_relative '../../../../hooked_objects/array-hooked/lib/array-hooked.rb'

# namespaces that have to be declared ahead of time for proper load order
require_relative './namespaces'

# source file requires
require_relative './requires.rb'

class ::Array::Compositing < ::Array::Hooked

  alias_method :non_cascading_set, :[]=

  alias_method :non_cascading_insert, :insert

  alias_method :non_cascading_delete_at, :delete_at

  include ::Array::Compositing::ArrayInterface
  
end
