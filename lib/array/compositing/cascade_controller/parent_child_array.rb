# -*- encoding : utf-8 -*-

class ::Array::Compositing::CascadeController::ParentChildArray < ::Array
  
  ############
  #  delete  #
  ############
  
  def delete( object )
    
    deleted = nil

    if delete_at_index = index( object )
      deleted = delete_at( delete_at_index )
    end
    
    return deleted
    
  end
  
  ##############
  #  include?  #
  ##############
  
  def include?( object )
    
    includes = false
    
    self.each {  |this_member| break if includes = this_member.equal?( object ) }
    
    return includes
    
  end

  ###########
  #  index  #
  ###########
  
  def index( object = nil, & block )
    
    return block_given? ? super( & block ) : super() {  |this_member| this_member.equal?( object ) }
    
  end
  
end
