
class ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap < 
      ::Array::Compositing::CascadeController::IndexMap
  
  ###########################
  #  index_for_local_index  #
  ###########################
  
  def index_for_local_index( local_index_number )

    index_of_nth_local_index = nil
    local_indexes_found = 0
    
    each_with_index do |this_local_index, this_parent_index|
      if this_local_index
        local_indexes_found += 1
        if local_indexes_found == local_index_number
          index_of_nth_local_index = this_parent_index
          break
        end
      end
    end

    return index_of_nth_local_index
    
  end
  
  #################
  #  local_index  #
  #################
  
  def local_index( local_index_number )
    
    index_of_nth_local_index = index_for_local_index( local_index_number )
    
    return index_of_nth_local_index ? self[ index_of_nth_local_index ] : nil
    
  end
  
  ######################
  #  next_local_index  #
  ######################
  
  def next_local_index( parent_index )
    
    next_local_index = nil
    
    each_range( parent_index ) { |this_local_index, this_parent_index| break if next_local_index = this_local_index }
    
    return next_local_index

  end

  #############################
  #  next_local_insert_index  #
  #############################
  
  def next_local_insert_index( parent_index )
    
    unless next_local_insert_index = next_local_index( parent_index )
      reverse_each_range( parent_index - 1 ) do |this_local_index, this_parent_index|
        if this_local_index
          next_local_insert_index = this_local_index + 1
          break
        end
      end
    end
    
    return next_local_insert_index

  end
  
end
