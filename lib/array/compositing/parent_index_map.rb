
class ::Array::Compositing::ParentIndexMap
  
  ################
  #  initialize  #
  ################

  def initialize
    
    @parent_local_map = [ ]
    @local_parent_map = [ ]
    
    @parent_lazy_lookup = [ ]
    
    @parent_and_interpolated_object_count = 0
    
  end
  
  ######################
  #  index_for_offset  #
  ######################
  
  def index_for_offset( index_offset )
    
    index = nil
    
    if index_offset >= 0
      index = index_offset
    else
      index = @local_parent_map.count + index_offset
    end    
  
    if index < 0
      index = 0
    end
    
    return index
    
  end

  #############################
  #  inside_parent_elements?  #
  #############################
  
  def inside_parent_elements?( local_index )
    
    local_index = index_for_offset( local_index )
    
    return local_index < @parent_and_interpolated_object_count
    
  end

  ################################################
  #  replaced_parent_element_with_parent_index?  #
  ################################################

  def replaced_parent_element_with_parent_index?( parent_index )
    
    replaced = false

    parent_index = index_for_offset( parent_index )

    # if parent index is greater than interpolated count we have a new parent, so not replaced
    if @parent_and_interpolated_object_count == 0
      
      if @local_parent_map.count > 0
        replaced = true
      end

    elsif parent_index < @parent_and_interpolated_object_count

      if local_index_for_parent = @parent_local_map[ parent_index ] and local_index_for_parent >= 0
        replaced = replaced_parent_element_with_local_index?( local_index_for_parent )
      else
        replaced = true
      end
    
    elsif parent_index == @parent_and_interpolated_object_count
      
      if local_index_for_parent = @parent_local_map[ parent_index ] and local_index_for_parent >= 0
        replaced = replaced_parent_element_with_local_index?( local_index_for_parent )
      end

    end

    return replaced
    
  end
  
  ###############################################
  #  replaced_parent_element_with_local_index?  #
  ###############################################

  def replaced_parent_element_with_local_index?( local_index )
    
    local_index = index_for_offset( local_index )
    
    return parent_index( local_index ).nil?
    
  end
  
  ######################
  #  requires_lookup?  #
  ######################
  
  def requires_lookup?( local_index )
    
    local_index = index_for_offset( local_index )
    
    return @parent_lazy_lookup[ local_index ]
    
  end

  ##############################
  #  indexes_requiring_lookup  #
  ##############################
  
  def indexes_requiring_lookup
    
    indexes = [ ]
    
    @parent_lazy_lookup.each_with_index do |true_or_false, this_index|
      if true_or_false
        indexes.push( this_index )
      end
    end
    
    return indexes
    
  end
  
  ################
  #  looked_up!  #
  ################
  
  def looked_up!( local_index )
    
    local_index = index_for_offset( local_index )

    @parent_lazy_lookup[ local_index ] = false
    
  end

  ##################
  #  parent_index  #
  ##################
  
  def parent_index( local_index )
    
    local_index = index_for_offset( local_index )
    
    return @local_parent_map[ local_index ]
    
  end

  #################
  #  local_index  #
  #################
  
  def local_index( parent_index )
    
    parent_index = index_for_offset( parent_index )
    
    if local_index = @parent_local_map[ parent_index ] and
       local_index < 0
      local_index = 0
    end
    
    return local_index
    
  end

  ###################
  #  parent_insert  #
  ###################
  
  def parent_insert( parent_insert_index, object_count )

    parent_insert_index = index_for_offset( parent_insert_index )

    local_insert_index = nil

    # It's possible we have no parent map yet (if the first insert is from an already-initialized parent
    # that did not previously have any members).
    case parent_insert_index
      when 0
        local_insert_index = @parent_local_map[ parent_insert_index ] || 0
      else
        unless local_insert_index = @parent_local_map[ parent_insert_index ]
          local_insert_index = @parent_and_interpolated_object_count
        end
    end
    
    if local_insert_index < 0
      local_insert_index = 0
    end
    
    # Insert new parent index correspondences.
    object_count.times do |this_time|
      this_parent_index = parent_insert_index + this_time
      this_local_index = local_insert_index + this_time
      @parent_local_map.insert( this_parent_index, this_local_index )
      @local_parent_map.insert( this_local_index, this_parent_index )
      @parent_lazy_lookup.insert( this_local_index, true )
    end
    
    # Update any correspondences whose parent indexes are above the insert.
    parent_index_at_end_of_insert = parent_insert_index + object_count
    remaining_count = @parent_local_map.count - parent_index_at_end_of_insert
    remaining_count.times do |this_time|
      this_parent_index = parent_index_at_end_of_insert + this_time
      @parent_local_map[ this_parent_index ] += object_count
    end

    local_index_at_end_of_insert = local_insert_index + object_count

    remaining_count = @local_parent_map.count - local_index_at_end_of_insert
    remaining_count.times do |this_time|
      this_local_index = local_index_at_end_of_insert + this_time
      if existing_parent_index = @local_parent_map[ this_local_index ]
        existing_parent_index += object_count
        @local_parent_map[ this_local_index ] += object_count
      end
    end
    
    # Update count of parent + interpolated objects since we inserted inside the collection.
    @parent_and_interpolated_object_count += object_count

    return local_insert_index
    
  end
  
  ##################
  #  local_insert  #
  ##################

  def local_insert( local_index, object_count )

    local_index = index_for_offset( local_index )

    # account for insert in parent-local    
    # if we're inside the set of parent elements then we need to tell the parent map to adjust
    if inside_parent_elements?( local_index )

      unless parent_insert_index = @local_parent_map[ local_index ]
        next_local_index = local_index
        begin
          parent_insert_index = @local_parent_map[ next_local_index ]
          next_local_index += 1
        end while parent_insert_index.nil? and next_local_index < @local_parent_map.count
      end
      
      if parent_insert_index
        remaining_count = @parent_local_map.count - parent_insert_index
        remaining_count.times do |this_time|
          this_parent_index = parent_insert_index + this_time
          @parent_local_map[ this_parent_index ] += object_count
        end
      end
      
    end
    
    # account for insert in local-parent
    object_count.times do |this_time|
      this_local_insert_index = local_index + this_time
      @local_parent_map.insert( this_local_insert_index, nil )
      @parent_lazy_lookup.insert( this_local_insert_index, false )
    end
    
  end
  
  ################
  #  parent_set  #
  ################

  def parent_set( parent_index )

    parent_index = index_for_offset( parent_index )
    
    # if we are setting an index that already exists then we have a parent to local map - we never delete those
    # except when we delete the parent
    if local_index = @parent_local_map[ parent_index ]
      unless replaced_parent_element_with_local_index?( local_index )
        @parent_lazy_lookup[ local_index ] = true
      end
    else
      local_index = @parent_and_interpolated_object_count
      parent_insert( local_index, 1 )
    end
    
    return local_index
    
  end

  ###############
  #  local_set  #
  ###############
  
  def local_set( local_index )

    local_index = index_for_offset( local_index )

    if parent_index = @local_parent_map[ local_index ]
      @local_parent_map[ local_index ] = nil
    end
    
    @parent_lazy_lookup[ local_index ] = false

  end

  ######################
  #  parent_delete_at  #
  ######################

  def parent_delete_at( parent_delete_at_index )

    parent_delete_at_index = index_for_offset( parent_delete_at_index )

    # get local index for parent index where delete is occuring
    local_delete_at_index = @parent_local_map.delete_at( parent_delete_at_index )
    
    # update any correspondences whose parent indexes are below the delete
    remaining_count = @parent_local_map.count - parent_delete_at_index
    remaining_count.times do |this_time|
      this_parent_index = parent_delete_at_index + this_time
      @parent_local_map[ this_parent_index ] -= 1
    end

    remaining_count = @local_parent_map.count - local_delete_at_index
    remaining_count.times do |this_time|
      this_local_index = local_delete_at_index + this_time
      if parent_index = @local_parent_map[ this_local_index ]
        @local_parent_map[ this_local_index ] = parent_index - 1
      end
    end

    if @parent_and_interpolated_object_count > 0
      @parent_and_interpolated_object_count -= 1
    end
    
    # if local => parent is already nil then we've overridden the corresponding index already
    # (we used to call this "replaced_parents")
    unless @local_parent_map[ local_delete_at_index ].nil?
      @local_parent_map.delete_at( local_delete_at_index )
      @parent_lazy_lookup.delete_at( local_delete_at_index )
    end

    return local_delete_at_index
    
  end

  #####################
  #  local_delete_at  #
  #####################
  
  def local_delete_at( local_index )

    local_index = index_for_offset( local_index )

    parent_index = @local_parent_map.delete_at( local_index )
    @parent_lazy_lookup.delete_at( local_index )

    if inside_parent_elements?( local_index )

      # if we don't have a parent index corresponding to this index, find the next one that corresponds
      unless parent_index
        next_local_index = local_index
        begin
          parent_index = @local_parent_map[ next_local_index ]
          next_local_index += 1
        end while parent_index.nil? and next_local_index < @local_parent_map.count
      end

      if parent_index
        remaining_count = @parent_local_map.count - parent_index
        remaining_count.times do |this_time|
          this_parent_index = parent_index + this_time
          @parent_local_map[ this_parent_index ] -= 1
        end
        if @parent_and_interpolated_object_count > 0
          @parent_and_interpolated_object_count -= 1
        end
      end
      
    end

  end
  
end
