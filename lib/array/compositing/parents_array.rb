# -*- encoding : utf-8 -*-

class ::Array::Compositing::ParentsArray < ::Array
  
  ############
  #  delete  #
  ############
  
  def delete( object )
    
    deleted = nil
    
    delete_at_index = nil
    
    self.each_with_index do |this_member, this_index|
      if this_member.equal?( object )
        delete_at_index = this_index
        break
      end
    end
    
    if delete_at_index
      deleted = delete_at( delete_at_index )
    end
    
    return deleted
    
  end
  
  ##############
  #  include?  #
  ##############
  
  def include?( object )
    
    includes = false
    
    self.each do |this_member|
      break if includes = this_member.equal?( object )
    end
    
    return includes
    
  end
  
end
