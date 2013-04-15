# -*- encoding : utf-8 -*-

class ::Array::Compositing::CascadeController::IndexMap < ::Array
  
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
  
  ################
  #  each_range  #
  ################
  
  ###
  # Iterates a range in self between index_one and index_two from left to right.
  #
  def each_range( index_one, index_two = size )

    return to_enum unless block_given?
    
    count = nil
    index_one = index_one < 0 ? ( count = size ) + index_one : index_one
    index_two = index_two < 0 ? ( count || size ) + index_two : index_two

    range_start = nil
    range_end = nil
    
    # renumber local => parent in range
    if index_one < index_two
      range_start = index_one
      range_end = index_two
    else
      range_start = index_two
      range_end = index_one
    end
    
    # copy parent => local to local => parent as appropriate
    number_of_indexes_modified = range_end - range_start
    number_of_indexes_modified.times do |this_time|
      this_index = range_start + this_time
      this_object = self[ this_index ]
      yield( this_object, this_index )
    end
    
    return self
    
  end

  ########################
  #  reverse_each_range  #
  ########################
  
  ###
  # Iterates a range in self between index_one and index_two from right to left.
  #
  def reverse_each_range( index_one, index_two = 0 )

    return to_enum unless block_given?

    count = nil
    index_one = index_one < 0 ? ( count = size ) + index_one : index_one
    index_two = index_two < 0 ? ( count || size ) + index_two : index_two

    range_start = nil
    range_end = nil
    
    # renumber local => parent in range
    if index_one < index_two
      range_start = index_two
      range_end = index_one
    else
      range_start = index_one
      range_end = index_two
    end
    
    # copy parent => local to local => parent as appropriate
    number_of_indexes_modified = range_start - range_end
    number_of_indexes_modified.times do |this_time|
      this_index = range_start - this_time
      this_object = self[ this_index ]
      yield( this_object, this_index )
    end
    
    return self

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
