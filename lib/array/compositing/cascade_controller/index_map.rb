
class ::Array::Compositing::CascadeController::IndexMap < ::Array
  
  ##########
  #  hash  #
  ##########

  def hash
    
    return __id__
    
  end
  
  ########################################
  #  renumber_mapped_indexes_for_delete  #
  ########################################

  def renumber_mapped_indexes_for_delete( index, count = 1 )
    
    collect! { |this_index| ( this_index           and 
                              this_index > index )   ? this_index - count 
                                                     : this_index }
    
    return self
    
  end

  ########################################
  #  renumber_mapped_indexes_for_insert  #
  ########################################

  def renumber_mapped_indexes_for_insert( index, count = 1 )
    
    collect! { |this_index| ( this_index            and 
                              this_index >= index )   ? this_index + count 
                                                      : this_index }
    
    return self
    
  end
  
  ##########
  #  move  #
  ##########
  
  def move( existing_index, new_index )
    
    # parent is below requested location
    if existing_index < new_index

      # modify any index in range [original index .. new index ] by subtracting 1
      collect! { |this_index| ( this_index                     and 
                                this_index >= existing_index   and 
                                this_index < new_index )         ? this_index - 1
                                                                 : this_index }
    
    # parent is above requested location
    elsif existing_index > new_index

      # modify any index in range [new index .. original index ] by adding 1
      collect! { |this_index| ( this_index                     and 
                                this_index > new_index         and 
                                this_index <= existing_index )   ? this_index + 1
                                                                 : this_index }
    
    end

    return self
    
  end
  
  ##########
  #  swap  #
  ##########

  def swap( index_one, index_two )

    existing_value_for_index_one = self[ index_one ]
    self[ index_one ] = self[ index_two ]
    self[ index_two ] = existing_value_for_index_one
    
    return self
    
  end
  
end
