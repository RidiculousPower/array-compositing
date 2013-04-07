
class ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap < 
      ::Array::Compositing::CascadeController::IndexMap
  
  #################################
  #  ensure_no_nil_local_indexes  #
  #################################
  
  def ensure_no_nil_local_indexes( local_array_size )
  
    # any nil entries get the index of the next local
    next_local = local_array_size
    
    # from right to left
    this_parent_index = size - 1
    while this_parent_index >= 0
      if this_local_index = self[ this_parent_index ]
        # if we have a local index, record it as our next
        next_local = this_local_index
      else
        # if we have nil, set local index to local index of element to the right
        # this means the index was deleted and inserts in part in relation to index take place here
        self[ this_parent_index ] = next_local
      end
      this_parent_index -= 1
    end
  
  end
  
end
