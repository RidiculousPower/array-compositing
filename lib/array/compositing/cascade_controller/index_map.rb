# -*- encoding : utf-8 -*-

class ::Array::Compositing::CascadeController::IndexMap < ::Array
  
  include ::Array::Hooked::ArrayInterface::EachRange
  
  ##########
  #  hash  #
  ##########

  def hash
    
    return __id__
    
  end

  #################
  #  ensure_size  #
  #################
  
  def ensure_size( element_count, value = nil )
    
    add_element_count = element_count - size
    
    if add_element_count > 0
      add_element_count.times { |this_time| push( block_given? ? yield( this_time ) : value ) }
    end
    
    return add_element_count
    
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
  
  #######################
  #  renumber_for_move  #
  #######################
  
  def renumber_for_move( existing_index, new_index, include_new_index = false )
    
    # parent is below requested location
    if existing_index < new_index

      # modify any index in range [original index .. new index ] by subtracting 1
      collect! { |this_index| ( this_index                                     and 
                                this_index >= existing_index                   and 
                                include_new_index ? this_index <= new_index
                                                    : this_index < new_index )   ? this_index - 1
                                                                                 : this_index }
    
    # parent is above requested location
    elsif existing_index > new_index

      # modify any index in range [new index .. original index ] by adding 1
      collect! { |this_index| ( this_index                                  and 
                                include_new_index ? this_index >= new_index
                                                  : this_index > new_index  and 
                                this_index <= existing_index )                ? this_index + 1
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
