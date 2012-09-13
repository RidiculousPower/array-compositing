
###
# @private
#
# Each compositing array instance has a corresponding parent index map,
#   which manages internal index correspondence for downward compositing 
#   of elements from parent to child.
#
class ::Array::Compositing::ParentIndexMap
  
  ParentIndexStruct = ::Struct.new( :parent_instance, :parent_index )
  
  ################
  #  initialize  #
  ################

  ###
  # Create a parent index map for a given array instance.
  #
  # @param array_instance
  #
  #        The array instance for which this parent index map is tracking parent elements.
  #
  def initialize
    
    # parent instance => parent to local map array
    # local map array is parent index => local index
    @parent_local_maps = { }
    
    # local index => parent index in parent instance (struct)
    @local_parent_map = [ ]
    
    # The first index that is after all included parent elements
    @first_index_after_last_parent_element = 0
    
    # Tracks whether each local index has already been received from parent.
    # local index => true or nil
    @local_index_requires_lookup = [ ]
    
  end
  
  ###########################################
  #  first_index_after_last_parent_element  #
  ###########################################

  ###
  # @!attribute [r]
  #
  # @return [Integer] 
  #
  #         Index of first element in local array after all parent elements.
  #
  attr_reader :first_index_after_last_parent_element
  
  #####################
  #  register_parent  #
  #####################

  ###
  # Register a parent to track element inheritance.
  #
  # @param [Array::Compositing] parent_instance
  #
  #        Instance from which instance will inherit elements.
  #
  # @return [Array::Compositing::ParentIndexMap] 
  #
  #         Self.
  #
  def register_parent( parent_instance )
    
    @parent_local_maps[ parent_instance.__id__ ] = [ ]
    
    return self
    
  end

  #######################
  #  unregister_parent  #
  #######################

  ###
  # Account for removal of all indexes corresponding to parent and return
  #   array containing local indexes to be deleted.
  #
  # @param [Array::Compositing] parent_instance
  #
  #        Instance from which instance will inherit elements.
  #
  # @return [Array<Integer>] 
  #
  #         Array of indexes corresponding to parent elements to be removed 
  #         from local instance.
  #
  def unregister_parent( parent_instance )

    parent_local_map = @parent_local_maps.delete( parent_instance.__id__ )
    
    # get sorted local indexes
    local_indexes_to_delete = parent_local_map.select do |this_local_index|
      if this_local_index < 0
        false
      else
        true
      end
    end.sort.reverse

    # for each index, smallest to largest, 
    local_indexes_to_delete.each do |this_local_index|
      
      @local_parent_map.delete_at( this_local_index )
      
      # for each index, iterate each parent array, delete and decrement indexes > than index
      @parent_local_maps.each do |this_parent, this_parent_local_map|
        this_parent_local_map.each_with_index do |this_mapped_local_index, this_parent_index|
          if this_mapped_local_index > this_local_index
            this_parent_local_map[ this_parent_index ] = this_mapped_local_index - 1
          end
        end
      end
      
    end
    
    # note total decrease in parent elements
    @first_index_after_last_parent_element -= local_indexes_to_delete.count
    
    # return reversed indexes for non-cascading delete_at
    return local_indexes_to_delete.reverse

  end
  
  #############################
  #  inside_parent_elements?  #
  #############################
  
  ###
  # Query whether local index is inside range of indexes that include parent elements 
  #   (ie. whether local index is before the last parent index in array instance).
  #
  # @param [Integer] local_index
  #
  #        Index in local array to query against 
  #
  # @return [true,false]
  #
  #         Whether index is within the range of elements that contain parent elements.
  #
  def inside_parent_elements?( local_index )
    
    local_index = index_for_offset( local_index )
    
    return local_index < @first_index_after_last_parent_element
    
  end

  ################################################
  #  replaced_parent_element_with_parent_index?  #
  ################################################

  ###
  # Query whether parent index in parent instance has been replaced in local instance.
  # 
  # @params [Array::Compositing] parent_instance
  #
  #         Parent array instance for which parent index is being queried.
  #
  # @params [Integer] parent_index
  #
  #         Index in parent array instance being queried in local array instance.
  #
  # @return [true,false] 
  #
  #         Whether parent index in parent instance has been replaced in local instance.
  #
  def replaced_parent_element_with_parent_index?( parent_instance, parent_index )
    
    replaced = false

    parent_index = index_for_offset( parent_index )

    # if parent index is greater than interpolated count we have a new parent, so not replaced
    if @first_index_after_last_parent_element == 0
      
      if @local_parent_map.count > 0
        replaced = true
      end

    elsif parent_index < @first_index_after_last_parent_element
      
      if local_index_for_parent = parent_local_map( parent_instance )[ parent_index ] and 
         local_index_for_parent >= 0
        replaced = replaced_parent_element_with_local_index?( local_index_for_parent )
      else
        replaced = true
      end
    
    elsif parent_index == @first_index_after_last_parent_element
      
      if local_index_for_parent = parent_local_map( parent_instance )[ parent_index ] and 
         local_index_for_parent >= 0
        replaced = replaced_parent_element_with_local_index?( local_index_for_parent )
      end

    end

    return replaced
    
  end
  
  ###############################################
  #  replaced_parent_element_with_local_index?  #
  ###############################################

  ###
  # Query whether index in local instance has been replaced or created in local instance.
  # 
  # @params [Integer] local_index
  #
  #         Index in local array instance.
  #
  # @return [true,false] 
  #
  #         Whether index has been replaced or created in local instance.
  #
  def replaced_parent_element_with_local_index?( local_index )
    
    local_index = index_for_offset( local_index )
    
    return parent_index( local_index ).nil?
    
  end
  
  ######################
  #  requires_lookup?  #
  ######################
  
  ###
  # Query whether index in local instance requires lookup in a parent instance.
  # 
  # @params [Integer] local_index
  #
  #         Index in local array instance.
  #
  # @return [true,false]
  #
  #         Whether lookup is required.
  #
  def requires_lookup?( local_index )
    
    local_index = index_for_offset( local_index )
    
    return @local_index_requires_lookup[ local_index ]
    
  end

  ##############################
  #  indexes_requiring_lookup  #
  ##############################
  
  ###
  # List of indexes requiring lookup in a parent instance.
  # 
  # @return [Array<Integer>]
  #
  #         list of indexes requiring lookup in a parent instance.
  #
  def indexes_requiring_lookup
    
    indexes = [ ]
    
    @local_index_requires_lookup.each_with_index do |true_or_false, this_index|
      if true_or_false
        indexes.push( this_index )
      end
    end
    
    return indexes
    
  end
  
  ################
  #  looked_up!  #
  ################
  
  ###
  # Declare that local index has been looked up.
  #
  # @params [Integer] local_index
  # 
  #         Index in local array instance.
  # 
  # @return [self] 
  #
  #         Self.
  #
  def looked_up!( local_index )
    
    local_index = index_for_offset( local_index )

    @local_index_requires_lookup[ local_index ] = false
    
    return self
    
  end

  ##################
  #  parent_index  #
  ##################
  
  ###
  # Get parent instance and index corresponding to local index.
  #
  # @params [Integer] local_index
  # 
  #         Index in local array instance.
  #
  # @return [Array::Compositing::ParentIndexMap::ParentIndexStruct] 
  #
  #         Struct containing parent instance and index.
  #
  def parent_index( local_index )
    
    local_index = index_for_offset( local_index )
    
    return @local_parent_map[ local_index ]
    
  end

  #################
  #  local_index  #
  #################
  
  ###
  # Get local index for parent instance and index.
  #
  # @params [Array::Compositing] parent_instance
  # 
  #         Parent array instance for which parent index is being queried.
  # 
  # @params [Integer] parent_index
  # 
  #         Index in parent array instance being queried in local array instance.
  # 
  # @return [Integer] 
  #
  #         Local index.
  #
  def local_index( parent_instance, parent_index )
    
    parent_index = index_for_offset( parent_index )
    
    if local_index = parent_local_map( parent_instance )[ parent_index ] and
       local_index < 0
      local_index = 0
    end
    
    return local_index
    
  end

  ###################
  #  parent_insert  #
  ###################
  
  ###
  # Update index information to represent insert in parent instance.
  #
  # @params [Array::Compositing] parent_instance
  # 
  #         Parent array instance for which insert is happening.
  # 
  # @params [Integer] parent_index
  # 
  #         Index in parent array instance for insert.
  # 
  # @params [Integer] object_count
  # 
  #         Number of elements inserted.
  # 
  # @return [Integer] 
  #
  #         Local index where insert took place.
  #
  def parent_insert( parent_instance, parent_insert_index, object_count )

    local_insert_index = nil
    
    parent_local_map = parent_local_map( parent_instance )

    parent_insert_index = index_for_offset( parent_insert_index )
    
    unless local_insert_index = parent_local_map[ parent_insert_index ]
      # It's possible we have no parent map yet (if the first insert is from an already-initialized parent
      # that did not previously have any members).
      local_insert_index = @first_index_after_last_parent_element
    end
    
    if local_insert_index < 0
      local_insert_index = 0
    end
    
    # Insert new parent index correspondences.
    object_count.times do |this_time|
      this_parent_index = parent_insert_index + this_time
      this_local_index = local_insert_index + this_time
      parent_local_map.insert( this_parent_index, this_local_index )
      parent_index_struct = self.class::ParentIndexStruct.new( parent_instance, this_parent_index )
      @local_parent_map.insert( this_local_index, parent_index_struct )
      @local_index_requires_lookup.insert( this_local_index, true )
    end
    
    # Update any correspondences whose parent indexes are above the insert.
    parent_index_at_end_of_insert = parent_insert_index + object_count
    remaining_parent_count = parent_local_map.count - parent_index_at_end_of_insert
    remaining_parent_count.times do |this_time|
      this_parent_index = parent_index_at_end_of_insert + this_time
      parent_local_map[ this_parent_index ] += object_count
    end

    # for each index, iterate each parent array, delete and decrement indexes > than index
    @parent_local_maps.each do |this_parent, this_parent_local_map|
      # we already updated parent local map for this parent
      next if this_parent_local_map == parent_local_map
      # need to track how it affects other existing maps
      this_parent_local_map.each_with_index do |this_local_index, this_parent_index|
        if this_local_index >= local_insert_index
          this_parent_local_map[ this_parent_index ] = this_local_index + object_count
        end
      end
    end

    local_index_at_end_of_insert = local_insert_index + object_count

    remaining_local_count = @local_parent_map.count - local_index_at_end_of_insert
    remaining_local_count.times do |this_time|
      this_local_index = local_index_at_end_of_insert + this_time
      if existing_parent_index_struct = @local_parent_map[ this_local_index ]
        existing_parent_index_struct.parent_index += object_count
      end
    end
    
    # Update count of parent + interpolated objects since we inserted inside the collection.
    @first_index_after_last_parent_element += object_count

    return local_insert_index
    
  end
  
  ##################
  #  local_insert  #
  ##################

  ###
  # Update index information to represent insert in local instance.
  #
  # @params [Integer] local_index
  # 
  #         Local insert index.
  # 
  # @params [Integer] object_count
  # 
  #         Number of elements inserted.
  # 
  # @return [Integer] 
  #
  #         Local index where insert took place.
  #
  def local_insert( local_index, object_count )

    local_index = index_for_offset( local_index )

    # account for insert in parent-local    
    # if we're inside the set of parent elements then we need to tell the parent map to adjust
    if inside_parent_elements?( local_index )

      # find the parent index corresponding to nearest local index above this one
      unless parent_insert_index_struct = @local_parent_map[ local_index ]
        next_local_index = local_index
        begin
          parent_insert_index_struct = @local_parent_map[ next_local_index ]
          next_local_index += 1
        end while parent_insert_index_struct.nil? and next_local_index < @local_parent_map.count
      end
      
      # if there was a parent after insert
      # FIX - this should be superfluous? - didn't we already ensure this with :inside_parent_elements?
      if parent_insert_index_struct

        parent_local_map = parent_local_map( parent_insert_index_struct.parent_instance )
        remaining_parent_count = parent_local_map.count - parent_insert_index_struct.parent_index
        parent_insert_index = parent_insert_index_struct.parent_index
        remaining_parent_count.times do |this_time|
          this_parent_index = parent_insert_index + this_time
          parent_local_map[ this_parent_index ] += object_count
        end

        # for each index, iterate each parent array, delete and decrement indexes > than index
        @parent_local_maps.each do |this_parent, this_parent_local_map|
          # we already updated parent local map for this parent
          next if this_parent_local_map == parent_local_map
          # need to track how it affects other existing maps
          this_parent_local_map.each_with_index do |this_local_index, this_parent_index|
            if this_local_index >= local_index
              this_parent_local_map[ this_parent_index ] = this_local_index + object_count
            end
          end
        end

      end
      
    end
    
    # account for insert in local-parent
    object_count.times do |this_time|
      this_local_insert_index = local_index + this_time
      @local_parent_map.insert( this_local_insert_index, nil )
      @local_index_requires_lookup.insert( this_local_insert_index, false )
    end
    
    return local_index
    
  end
  
  ################
  #  parent_set  #
  ################

  ###
  # Update index information to represent set in parent instance.
  #
  # @params [Array::Compositing] parent_instance
  # 
  #         Parent array instance for which parent index is being set.
  # 
  # @params [Integer] parent_index
  # 
  #         Index in parent array instance being queried in local array instance.
  # 
  # @return [Integer] 
  #
  #         Local index where insert took place.
  #
  def parent_set( parent_instance, parent_index )

    parent_index = index_for_offset( parent_index )
    
    # if we are setting an index that already exists then we have a parent to local map - we never delete those
    # except when we delete the parent
    if local_index = parent_local_map( parent_instance )[ parent_index ]
      unless replaced_parent_element_with_local_index?( local_index )
        @local_index_requires_lookup[ local_index ] = true
      end
    else
      local_index = @first_index_after_last_parent_element
      parent_insert( parent_instance, local_index, 1 )
    end
    
    return local_index
    
  end

  ###############
  #  local_set  #
  ###############
  
  ###
  # Update index information to represent insert in local instance.
  #
  # @params [Integer] local_index
  # 
  #         Local index for set.
  # 
  # @return [Integer] 
  #
  #         Local index where insert took place.
  #
  def local_set( local_index )

    local_index = index_for_offset( local_index )

    @local_parent_map[ local_index ] = nil
    
    @local_index_requires_lookup[ local_index ] = false
    
    return local_index
    
  end

  ######################
  #  parent_delete_at  #
  ######################

  ###
  # Update index information to represent set in parent instance.
  #
  # @params [Array::Compositing] parent_instance
  # 
  #         Parent array instance for which delete is happening.
  # 
  # @params [Integer] parent_delete_at_index
  # 
  #         Index in parent array instance for delete in local array instance.
  # 
  # @return [Integer] 
  #
  #         Local index where insert took place.
  #
  def parent_delete_at( parent_instance, parent_delete_at_index )

    parent_delete_at_index = index_for_offset( parent_delete_at_index )

    parent_local_map = parent_local_map( parent_instance )

    # get local index for parent index where delete is occuring
    local_delete_at_index = parent_local_map.delete_at( parent_delete_at_index )
    
    # update any correspondences whose parent indexes are below the delete
    remaining_parent_count = parent_local_map.count - parent_delete_at_index
    remaining_parent_count.times do |this_time|
      this_parent_index = parent_delete_at_index + this_time
      parent_local_map[ this_parent_index ] -= 1
    end

    remaining_local_count = @local_parent_map.count - local_delete_at_index
    remaining_local_count.times do |this_time|
      this_local_index = local_delete_at_index + this_time
      if parent_index_struct = @local_parent_map[ this_local_index ]
        parent_index_struct.parent_index -= 1
      end
    end

    # for each index, iterate each parent array, delete and decrement indexes > than index
    @parent_local_maps.each do |this_parent, this_parent_local_map|
      # we already updated parent local map for this parent
      next if this_parent_local_map == parent_local_map
      # need to track how it affects other existing maps
      this_parent_local_map.each_with_index do |this_local_index, this_parent_index|
        if this_local_index >= local_delete_at_index
          this_parent_local_map[ this_parent_index ] = this_local_index - 1
        end
      end
    end

    if @first_index_after_last_parent_element > 0
      @first_index_after_last_parent_element -= 1
    end
    
    # if local => parent is already nil then we've overridden the corresponding index already
    # (we used to call this "replaced_parents")
    unless @local_parent_map[ local_delete_at_index ].nil?
      @local_parent_map.delete_at( local_delete_at_index )
      @local_index_requires_lookup.delete_at( local_delete_at_index )
    end

    return local_delete_at_index
    
  end

  #####################
  #  local_delete_at  #
  #####################
  
  ###
  # Update index information to represent delete in local instance.
  #
  # @params [Integer] local_index
  # 
  #         Local index for delete.
  # 
  # @return [Integer] 
  #
  #         Local index where delete took place.
  #
  def local_delete_at( local_index )

    local_index = index_for_offset( local_index )

    parent_index_struct = @local_parent_map.delete_at( local_index )
    @local_index_requires_lookup.delete_at( local_index )

    if inside_parent_elements?( local_index )

      # if we don't have a parent index corresponding to this index, find the next one that corresponds
      unless parent_index_struct
        next_local_index = local_index
        begin
          parent_index_struct = @local_parent_map[ next_local_index ]
          next_local_index += 1
        end while parent_index_struct.nil? and next_local_index < @local_parent_map.count
      end

      if parent_index_struct
        parent_local_map = parent_local_map( parent_index_struct.parent_instance )
        remaining_parent_count = parent_local_map.count - parent_index_struct.parent_index
        remaining_parent_count.times do |this_time|
          this_parent_index = parent_index_struct.parent_index + this_time
          parent_local_map[ this_parent_index ] -= 1
        end
        if @first_index_after_last_parent_element > 0
          @first_index_after_last_parent_element -= 1
        end
      end
      
      # for each index, iterate each parent array, delete and decrement indexes > than index
      @parent_local_maps.each do |this_parent, this_parent_local_map|
        # we already updated parent local map for this parent
        next if this_parent_local_map == parent_local_map
        # need to track how it affects other existing maps
        this_parent_local_map.each_with_index do |this_local_index, this_parent_index|
          if this_local_index >= local_index
            this_parent_local_map[ this_parent_index ] = this_local_index - 1
          end
        end
      end
      
    end
    
    return local_index
    
  end

  ######################################################################################################################
      private ##########################################################################################################
  ######################################################################################################################

  ######################
  #  parent_local_map  #
  ######################
  
  ###
  # Get parent to local map for parent instance.
  #
  # @params [Array::Compositing] parent_instance
  # 
  #         Parent array instance for which parent index is being queried.
  #
  def parent_local_map( parent_instance )
    
    return @parent_local_maps[ parent_instance.__id__ ]
    
  end

  ######################
  #  index_for_offset  #
  ######################
  
  ###
  # Translate index offset from start or end of array into offset from start.
  #
  # @param [Integer] index_offset
  # 
  #        Positive or negative offset indicating distance from start or end of array.
  # 
  # @return [Integer]
  #
  #         Positive offset indicating distance from start of array.
  #
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
  
end
