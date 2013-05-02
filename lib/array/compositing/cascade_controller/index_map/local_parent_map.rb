# -*- encoding : utf-8 -*-

class ::Array::Compositing::CascadeController::IndexMap::LocalParentMap < 
      ::Array::Compositing::CascadeController::IndexMap
  
  ##################################
  #  next_parent_controlled_index  #
  ##################################
  
  def next_parent_controlled_index( starting_after_index = nil )
    
    nth_parent_index = nil
    
    each_range( starting_after_index ? starting_after_index + 1 : 0 ) do |this_parent_index, this_local_index|
      if this_parent_index
        nth_parent_index = this_local_index
        break
      end
    end
    
    return nth_parent_index
    
  end
  
end
