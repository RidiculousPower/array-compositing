# -*- encoding : utf-8 -*-

###
# @private
#
# Each compositing array instance has a corresponding index map, which manages 
#   internal index correspondence for downward compositing of elements from parent to child.
#
class ::Array::Compositing::CascadeController
  
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
  def initialize( array_instance )
    
    @array_instance = array_instance
    
  end

  ####################
  #  array_instance  #
  ####################

  ###
  # @!attribute [r]
  #
  # @return [Array] 
  #
  #        The array instance for which this parent index map is tracking parent elements.
  #
  attr_reader :array_instance
  
  ###############################
  #  local_index_to_parent_map  #
  ###############################

  ###
  # @!attribute [r]
  #
  # @return [Array] 
  #
  #        Array of parent array instances corresponding to local indexes controlled by parents.
  #
  attr_reader :local_index_to_parent_map
  
  ######################
  #  parent_local_map  #
  ######################
  
  ###
  # Get parent to local map for parent instance.
  #
  # @params [Array::Compositing] parent_map
  # 
  #         Parent array instance for which parent index is being queried.
  #
  def parent_local_map( parent_array )
    
    return @parent_local_maps ? @parent_local_maps[ parent_array.__id__ ] : nil
    
  end

  ######################
  #  local_parent_map  #
  ######################
  
  ###
  # Get parent to local map for parent instance.
  #
  # @params [Array::Compositing] parent_map
  # 
  #         Parent array instance for which parent index is being queried.
  #
  def local_parent_map( parent_array )
    
    return @local_parent_maps ? @local_parent_maps[ parent_array.__id__ ] : nil
    
  end

  ##########################
  #  new_parent_local_map  #
  ##########################
  
  ###
  # Create parent to local map for parent instance.
  #
  # @params [Array::Compositing] parent_map
  # 
  #         Parent array instance for which parent index is being queried.
  #
  def new_parent_local_map( parent_array )
    
    new_parent_local_map = ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap.new
    @parent_local_maps[ parent_array.__id__ ] = new_parent_local_map
    
    return new_parent_local_map
    
  end

  ##########################
  #  new_local_parent_map  #
  ##########################
  
  ###
  # Create parent to local map for parent instance.
  #
  # @params [Array::Compositing] parent_map
  # 
  #         Parent array instance for which parent index is being queried.
  #
  def new_local_parent_map( parent_array )
    
    new_local_parent_map = ::Array::Compositing::CascadeController::IndexMap::LocalParentMap.new
    @local_parent_maps[ parent_array.__id__ ] = new_local_parent_map
    
    return new_local_parent_map
    
  end

  #####################
  #  register_parent  #
  #####################

  ###
  # Register a parent to track element inheritance.
  #
  # @param [Array::Compositing] parent_map
  #
  #        Instance from which instance will inherit elements.
  #
  # @param [Integer] insert_at_index
  #
  #        Index where parent array will be inserted.
  #
  # @param [True,False] cc_auto_inserts
  #
  #        Whether the Array instance handles inserting parent elements 
  #        to the cascade controller or the cascade controller should.
  #
  # @return [Array::Compositing::CascadeController] 
  #
  #         Self.
  #
  def register_parent( parent_array, insert_at_index = @array_instance.size, cc_auto_inserts = true )
    
    @parent_local_maps ||= { }
    @local_parent_maps ||= { }
    @local_index_to_parent_map ||= [ ]
    @requires_lookup ||= [ ]
    
    parent_local_map = new_parent_local_map( parent_array )
    local_parent_map = new_local_parent_map( parent_array )
    
    # map each element to corresponding local
    parent_element_count = parent_array.size
    if cc_auto_inserts and parent_element_count > 0
      parent_insert( parent_array, 0, parent_element_count, insert_at_index, parent_local_map, local_parent_map )
    end
    
    return self
    
  end

  #######################
  #  unregister_parent  #
  #######################

  ###
  # Account for removal of all indexes corresponding to parent and return
  #   array containing local indexes to be deleted.
  #
  # @param [Array::Compositing] parent_map
  #
  #        Instance from which instance will inherit elements.
  #
  # @return [Array<Integer>] 
  #
  #         Array of indexes corresponding to parent elements to be removed 
  #         from local instance.
  #
  def unregister_parent( parent_array )
  
    if @parent_local_maps
      @parent_local_maps.delete( parent_id = parent_array.__id__ )
      @local_parent_maps.delete( parent_id )
    end
    
    return self

  end
  
  ##################
  #  parent_array  #
  ##################

  def parent_array( local_index )
    
    return @local_index_to_parent_map ? @local_index_to_parent_map[ local_index ] : nil
    
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
  # @return [Integer]
  #
  #         Parent index.
  #
  def parent_index( local_index, parent_array = parent_array( local_index ), local_parent_map = nil )
    
    parent_index = nil
    
    if parent_array
      local_parent_map ||= local_parent_map( parent_array )
      parent_index = local_parent_map[ local_index ]
    end
    
    return parent_index
    
  end

  #################
  #  local_index  #
  #################
  
  ###
  # Get local index for parent instance and index.
  #
  # @params [Array::Compositing] parent_map
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
  def local_index( parent_array, parent_index, 
                   parent_local_map = parent_local_map( parent_array ) )

    size = @array_instance.size
    if local_index = parent_local_map[ parent_index ]
      local_index = size if local_index > size
    else
      # local index is after last parent element in array
      this_parent_index = parent_index - 1
      while this_parent_index >= 0
        break if local_index = parent_local_map[ this_parent_index ]
        this_parent_index -= 1
      end
      if parent_index >= parent_local_map.size
        local_index = local_index ? local_index + 1 : size
      end
    end
    
    return local_index
    
  end

  ###################################
  #  parent_controls_parent_index?  #
  ###################################

  ###
  # Query whether parent index in parent instance has been replaced in local instance.
  # 
  # @params [Array::Compositing] parent_map
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
  def parent_controls_parent_index?( parent_array, parent_index, 
                                     parent_local_map = parent_local_map( parent_array ), 
                                     local_parent_map = local_parent_map( parent_array ) )
    
    parent_controls_parent_index = false
    
    # when local takes control of a parent index, parent => local index mapping does not cease
    # instead, we track where it moves so that we can insert at precisely that point later if needed    
    if @local_index_to_parent_map                                       and
       local_index = parent_local_map[ parent_index ]                   and
       @local_index_to_parent_map[ local_index ].equal?( parent_array ) and
       parent_index == local_parent_map[ local_index ]

      parent_controls_parent_index = true

    end
    
    return parent_controls_parent_index
    
  end
  
  ##################################
  #  parent_controls_local_index?  #
  ##################################

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
  def parent_controls_local_index?( local_index, 
                                    parent_array = parent_array( local_index ), 
                                    parent_local_map = nil, 
                                    local_parent_map = nil )
    
    parent_controls_local_index = false
        
    if parent_array
      parent_local_map ||= parent_local_map( parent_array )
      local_parent_map ||= local_parent_map( parent_array )
      if parent_index = local_parent_map[ local_index ]
        parent_controls_local_index = parent_controls_parent_index?( parent_array, 
                                                                     parent_index, 
                                                                     parent_local_map, 
                                                                     local_parent_map )
      end
    end
    
    return parent_controls_local_index
    
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
    
    return @requires_lookup ? @requires_lookup[ local_index ] || false : false
    
  end

  #################################
  #  each_index_requiring_lookup  #
  #################################
  
  ###
  # Iterate indexes requiring lookup in a parent instance.
  # 
  # @return [Array<Integer>,Enumerator]
  #
  #         list of indexes requiring lookup in a parent instance or enumerator if no block is given.
  #
  def each_index_requiring_lookup( parent_array = nil )
    
    return to_enum unless block_given?
    
    if @requires_lookup
      if parent_array
        @requires_lookup.each_with_index do |true_or_false, this_local_index|
          yield( this_local_index ) if true_or_false and parent_array( this_local_index ).equal?( parent_array )
        end
      else
        @requires_lookup.each_with_index do |true_or_false, this_local_index|
          yield( this_local_index ) if true_or_false
        end
      end
    end
    
    return self
    
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
    
    @requires_lookup[ local_index ] = false
    
    return self
    
  end

  ######################
  #  requires_lookup!  #
  ######################
  
  ###
  # Declare that local index requires look up.
  #
  # @params [Integer] local_index
  # 
  #         Index in local array instance.
  # 
  # @return [self] 
  #
  #         Self.
  #
  def requires_lookup!( local_index )
    
    @requires_lookup[ local_index ] = true
    
    return self
    
  end

  #######################################
  #  renumber_local_indexes_for_delete  #
  #######################################
  
  def renumber_local_indexes_for_delete( local_index, count = 1 )
    
    if @parent_local_maps
    
      local_index = local_index < 0 ? @array_instance.size + local_index : local_index

      # renumber any indexes in any parent to local map where local > local_index
      @parent_local_maps.each do |this_parent_array, this_parent_local_map|
        this_parent_local_map.renumber_mapped_indexes_for_delete( local_index, count )
      end

    end
    
    return self

  end

  #######################################
  #  renumber_local_indexes_for_insert  #
  #######################################
  
  def renumber_local_indexes_for_insert( local_index, count = 1 )
    
    if @parent_local_maps
      
      local_index = local_index < 0 ? @array_instance.size + local_index : local_index

      # renumber any indexes in any parent to local map where local > local_index
      @parent_local_maps.each do |this_parent_array, this_parent_local_map|
        this_parent_local_map.renumber_mapped_indexes_for_insert( local_index, count )
      end
    
    end
    
    return self

  end

  ########################################
  #  parent_insert_without_child_insert  #
  ########################################
  
  ###
  # Update index information to represent insert in parent instance when insert should not cascade.
  #
  # @params [Array::Compositing] parent_map
  # 
  #         Parent array instance for which insert is happening.
  # 
  # @params [Integer] parent_index
  # 
  #         Index in parent array instance for insert.
  # 
  # @params [Integer] count
  # 
  #         Number of elements inserted.
  # 
  # @return [Integer] 
  #
  #         Parent index where insert took place.
  #
  def parent_insert_without_child_insert( parent_array, parent_index, count, 
                                          parent_local_map = parent_local_map( parent_array ), 
                                          local_parent_map = local_parent_map( parent_array ) )
    
    # Insert new parent index correspondences.
    parent_index = parent_index < 0 ? parent_array.size + parent_index : parent_index
    count.times { |this_time| parent_local_map.insert( parent_index + this_time, nil ) }
    
    # Update any correspondences whose parent indexes are above the insert.
    local_parent_map.renumber_mapped_indexes_for_insert( parent_index, count )

    return parent_index

  end
  
  ###################
  #  parent_insert  #
  ###################
  
  ###
  # Update index information to represent insert in parent instance.
  #
  # @params [Array::Compositing] parent_map
  # 
  #         Parent array instance for which insert is happening.
  # 
  # @params [Integer] parent_index
  # 
  #         Index in parent array instance for insert.
  # 
  # @params [Integer] count
  # 
  #         Number of elements inserted.
  # 
  # @return [Integer] 
  #
  #         Local index where insert took place.
  #
  def parent_insert( parent_array, parent_index, count, insert_at_index = nil,
                     parent_local_map = parent_local_map( parent_array ), 
                     local_parent_map = local_parent_map( parent_array ) )

    # We track parent location in locals even after local idex has been replaced.
    # This permits inserts before a given parent index to be mapped to the appropriate location in local.
    #
    # For example:
    # * parent [ 0, 1, 2, 3, 4 ]
    # * child inserts A, B, C as [ 0, 1, A, 2, B, C, 3, 4 ] (parent index 2 => child index 3)
    # * child delete parent index 2 and 3 (child [0, 1, A, B, C, 4]) (parent index 2 => child index 3)
    # * parent inserts at 2 (parent [ 0, 1, i, 2, 3, 4 ])
    #   => child inserts at location where 2 would have been (parent index 2 => child index 3)
    #   => child [0, 1, A, i, B, C, 4]

    parent_index = parent_index < 0 ? parent_array.size + parent_index 
                                    : parent_index
    local_index  = insert_at_index  ? insert_at_index
                                    : local_index( parent_array, parent_index, parent_local_map )

    # renumber parent indexes for insert
    local_parent_map.renumber_mapped_indexes_for_insert( parent_index, count )
    
    # insert nil count times for local_parent_maps other than the one owned by this array
    @local_parent_maps.each do |this_parent_array_id, this_local_parent_map|
      next if this_local_parent_map.equal?( local_parent_map )
      count.times do |this_time|
        this_local_index = local_index + this_time
        this_local_parent_map.insert( this_local_index, nil )
      end
    end
    
    # renumber all local indexes for insert
    renumber_local_indexes_for_insert( local_index, count )

    count.times do |this_time|
      this_local_index = local_index + this_time
      this_parent_index = parent_index + this_time
      # insert requires lookup for each new local index
      @requires_lookup.insert( this_local_index, true )
      # insert parent instance for each new local index
      @local_index_to_parent_map.insert( this_local_index, parent_array )
      # insert local index for parent index
      parent_local_map.insert( this_parent_index, this_local_index )
      # insert parent index for local index
      local_parent_map.insert( this_local_index, this_parent_index )
    end

    return local_index

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
  # @params [Integer] count
  # 
  #         Number of elements inserted.
  # 
  # @return [Integer] 
  #
  #         Local index where insert took place.
  #
  def local_insert( local_index, count )
    
    # renumber all local indexes for insert
    renumber_local_indexes_for_insert( local_index, count )
    
    if @local_index_to_parent_map
      count.times do |this_time|
        this_local_index = local_index + this_time
        # insert no lookup required for each new local index
        @requires_lookup.insert( this_local_index, false )
        # insert nil parent instance for each new local index
        @local_index_to_parent_map.insert( this_local_index, nil )
        # insert nil parent index for local index
        @local_parent_maps.each do |this_parent_array_id, this_local_parent_map|
          this_local_parent_map.insert( this_local_index, nil )
        end
      end
    end
    
    return local_index
    
  end
  
  ##################################
  #  parent_set_without_child_set  #
  ##################################

  ###
  # Update index information to represent set in parent instance when set should not cascade.
  #
  # @params [Array::Compositing] parent_map
  # 
  #         Parent array instance for which parent index is being set.
  # 
  # @params [Integer] parent_index
  # 
  #         Index in parent array instance being queried in local array instance.
  # 
  # @return [Integer] 
  #
  #         Parent index where insert took place.
  #
  def parent_set_without_child_set( parent_array, parent_index, 
                                    parent_local_map = parent_local_map( parent_array ) )
    
    parent_index = parent_index < 0 ? parent_array.size + parent_index : parent_index
    
    if parent_index < parent_array.size
      parent_local_map[ parent_index ] = nil    
    else
      parent_insert_without_child_insert( parent_array, parent_index, 1, parent_local_map )
    end
    
    return parent_index

  end
  
  ################
  #  parent_set  #
  ################

  ###
  # Update index information to represent set in parent instance.
  #
  # @params [Array::Compositing] parent_map
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
  def parent_set( parent_array, parent_index, 
                  parent_local_map = parent_local_map( parent_array ), 
                  local_parent_map = local_parent_map( parent_array ) )
    
    local_index = nil

    if parent_index >= parent_local_map.size
      local_index = parent_insert( parent_array, parent_index, 1, nil, parent_local_map, local_parent_map )
    elsif parent_controls_parent_index?( parent_array, parent_index, parent_local_map, local_parent_map )
      local_index = local_index( parent_array, parent_index, parent_local_map )
      @requires_lookup[ local_index ] = true
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
    
    local_index = local_index < 0 ? @array_instance.size + local_index : local_index
    
    if local_index >= @array_instance.size
      local_index = local_insert( local_index, 1 )
    elsif @local_index_to_parent_map and parent_array = @local_index_to_parent_map[ local_index ]
      local_parent_map = local_parent_map( parent_array )
      local_parent_map[ local_index ] = nil
      @local_index_to_parent_map[ local_index ] = nil
      @requires_lookup[ local_index ] = false
    end

    return local_index
    
  end

  ######################
  #  parent_delete_at  #
  ######################

  ###
  # Update index information to represent set in parent instance.
  #
  # @params [Array::Compositing] parent_map
  # 
  #         Parent array instance for which delete is happening.
  # 
  # @params [Integer] parent_index
  # 
  #         Index in parent array instance for delete in local array instance.
  # 
  # @return [Integer] 
  #
  #         Local index where insert took place.
  #
  def parent_delete_at( parent_array, parent_index, 
                        parent_local_map = parent_local_map( parent_array ), 
                        local_parent_map = local_parent_map( parent_array ) )
    
    local_index = nil

    if parent_controls_parent_index?( parent_array, parent_index, parent_local_map, local_parent_map )
      local_index = parent_local_map.delete_at( parent_index )
      @requires_lookup.delete_at( local_index )
      @local_index_to_parent_map.delete_at( local_index )
      local_parent_map.delete_at( local_index )
      renumber_local_indexes_for_delete( local_index )
    else
      local_index = parent_local_map.delete_at( parent_index )
    end

    # renumber any indexes in local to parent map where parent > parent_index
    local_parent_map.renumber_mapped_indexes_for_delete( parent_index )

    return local_index
    
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
    
    if @local_index_to_parent_map
      @local_index_to_parent_map.delete_at( local_index )
      @requires_lookup.delete_at( local_index )
      @local_parent_maps.each do |this_parent_array_id, this_local_parent_map|
        this_local_parent_map.delete_at( local_index )
      end
    end
    
    renumber_local_indexes_for_delete( local_index )

    return local_index
    
  end

  ##############################
  #  local_indexes_for_parent  #
  ##############################

  def local_indexes_for_parent( parent_array )
    
    local_indexes_for_parent = [ ]
    
    local_parent_map( parent_array ).each_with_index do |this_parent_index, this_local_index|
      local_indexes_for_parent.push( this_local_index ) if this_parent_index
    end
    
    return local_indexes_for_parent
    
  end
  
  ###################
  #  local_shuffle  #
  ###################
  
  def local_shuffle( random_number_generator = nil )
    
    shuffled_local_indexes = ( 0...@array_instance.size ).to_a.shuffle
    
    local_reorder( shuffled_local_indexes )
    
    return shuffled_local_indexes
    
  end

  ####################
  #  parent_reorder  #
  ####################
  
  def parent_reorder( parent_array, new_parent_order, 
                      parent_local_map = parent_local_map( parent_array ),
                      local_parent_map = local_parent_map( parent_array ) )
    
    new_local_order = [ ]

    nth_parent_index = nil
    new_parent_order.each_with_index do |this_new_parent_index, this_existing_parent_index|
      if parent_controls_parent_index?( parent_array, this_new_parent_index, parent_local_map, local_parent_map )        
        # existing_local_index: the local index controlled by new_parent_index
        this_existing_local_index = parent_local_map[ this_new_parent_index ]
        # new_local_index: the first (or next) local index controlled by parent
        if parent_controls_parent_index?( parent_array, this_existing_parent_index, parent_local_map, local_parent_map )
          this_new_local_index = nth_parent_index = parent_local_map[ this_existing_parent_index ]
        else
          this_new_local_index = nth_parent_index = local_parent_map.next_parent_controlled_index( nth_parent_index )
        end
        new_local_order[ this_new_local_index ] = this_existing_local_index
      end
    end
    
    existing_requires_lookup = @requires_lookup
    @requires_lookup = [ ]
    new_local_order.each_with_index do |this_new_local_index, this_existing_local_index|
      if this_new_local_index
        @requires_lookup[ this_new_local_index ] = existing_requires_lookup[ this_existing_local_index ]
      end
    end

    return new_local_order
        
  end

  ###################
  #  local_reorder  #
  ###################
  
  def local_reorder( new_local_order )

    if @local_index_to_parent_map
      
      new_local_to_parent_map = @local_index_to_parent_map.dup
      this_existing_local_index = -1
      @local_index_to_parent_map.collect! do |this_parent_array| 
        this_new_local_index = new_local_order[ this_existing_local_index += 1 ]
        this_new_parent_array = new_local_to_parent_map[ this_new_local_index ]
        this_new_parent_array
      end
      
      @parent_local_maps.each do |this_parent_array_id, this_parent_local_map|
        this_existing_parent_index = -1
        this_parent_local_map.collect! do |this_existing_local_index|
          this_new_local_index = new_local_order[ this_existing_local_index ]
          @local_parent_maps[ this_parent_array_id ][ this_new_local_index ] = this_existing_parent_index += 1
          this_new_local_index
        end
      end
    
      existing_requires_lookup = @requires_lookup
      @requires_lookup = [ ]
      new_local_order.each_with_index do |this_new_local_index, this_existing_local_index|
        if this_new_local_index
          @requires_lookup[ this_new_local_index ] = existing_requires_lookup[ this_existing_local_index ]
        end
      end
      
    end
    
    return new_local_order
    
  end
  
  #################
  #  parent_sort  #
  #################
  
  def parent_sort( parent_array, new_parent_order, 
                   parent_local_map = parent_local_map( parent_array ),
                   local_parent_map = local_parent_map( parent_array ) )
                   
    # parent elements in child should end up in same order as new parent order
    new_local_order = [ ]

    nth_parent_index = nil
    new_parent_order.each_with_index do |this_new_parent_index, this_existing_parent_index|
      if parent_controls_parent_index?( parent_array, this_new_parent_index, parent_local_map, local_parent_map )        
        # existing_local_index: the local index controlled by new_parent_index
        this_existing_local_index = parent_local_map[ this_new_parent_index ]
        # new_local_index: the next local index controlled by parent
        this_new_local_index = nth_parent_index = local_parent_map.next_parent_controlled_index( nth_parent_index )
        new_local_order[ this_new_local_index ] = this_existing_local_index
      end
    end
    
    existing_requires_lookup = @requires_lookup
    @requires_lookup = [ ]
    new_local_order.each_with_index do |this_new_local_index, this_existing_local_index|
      if this_new_local_index
        @requires_lookup[ this_new_local_index ] = existing_requires_lookup[ this_existing_local_index ]
      end
    end

    return new_local_order
    
  end
  
  ################
  #  local_sort  #
  ################
  
  alias_method :local_sort, :local_reorder

  #################
  #  parent_move  #
  #################
  
  def parent_move( parent_array, existing_parent_index, new_parent_index, 
                   parent_local_map = parent_local_map( parent_array ),
                   local_parent_map = local_parent_map( parent_array ) )
    
    new_local_index = nil
    
    # if we're asked to move in place we don't need to do anything
    unless new_parent_index == existing_parent_index
            
      new_local_index = parent_local_map[ new_parent_index ]
      existing_local_index = parent_local_map.delete_at( existing_parent_index )

      # insert new in parent => local
      parent_local_map.renumber_for_move( existing_local_index, new_local_index, true )
      parent_local_map.insert( new_parent_index, new_local_index )

      # if parent doesn't control then we don't have to track in local maps
      if parent_controls_parent_index?( parent_array, existing_parent_index, parent_local_map, local_parent_map )
        parent_local_map.each_range( existing_parent_index, new_parent_index ) do |this_local_index, this_parent_index|
          # only set parent index if one is already set for this local index
          local_parent_map[ this_local_index ] = this_parent_index if local_parent_map[ this_local_index ]
        end
      end
      
      @requires_lookup.insert( new_local_index, @requires_lookup.delete_at( existing_local_index ) )

    end
    
    return new_local_index
    
  end
  
  ################
  #  local_move  #
  ################
  
  def local_move( existing_local_index, new_local_index )
    
    # if we're asked to move in place we don't need to do anything
    unless new_local_index == existing_local_index
      
      if @local_index_to_parent_map
        
        # adjust local => parent maps by moving index (parent stays the same)
        @local_parent_maps.each do |this_parent_array_id, this_local_parent_map|
          this_local_parent_map.insert( new_local_index, this_local_parent_map.delete_at( existing_local_index ) )
        end

        # adjust local => parent array map by moving index (parent array stays the same)
        parent_array = @local_index_to_parent_map.delete_at( existing_local_index )
        @local_index_to_parent_map.insert( new_local_index, parent_array )

        # adjust parent => local maps by renumbering and filling in from local => parent
        @parent_local_maps.each do |this_parent_array_id, this_parent_local_map|
          this_parent_local_map.renumber_for_move( existing_local_index, new_local_index )
          this_local_parent_map = @local_parent_maps[ this_parent_array_id ]
          this_local_parent_map.each_range( existing_local_index, 
                                            new_local_index ) do |this_parent_index, this_local_index|
            # only set parent index if one is already set for this local index
            this_parent_local_map[ this_parent_index ] = this_local_index if this_parent_index
          end
        end
    
        @requires_lookup.insert( new_local_index, @requires_lookup.delete_at( existing_local_index ) )
      
      end
      
    end
    
    return new_local_index
    
  end

  #################
  #  parent_swap  #
  #################

  def parent_swap( parent_array, parent_index_one, parent_index_two, 
                   parent_local_map = parent_local_map( parent_array ),
                   local_parent_map = local_parent_map( parent_array ) )
    
    local_index_one = nil
    local_index_two = nil
    
    unless parent_index_one == parent_index_two

      # check whether parent controls either/both of indexes in local
      parent_controls_one = parent_controls_parent_index?( parent_array, parent_index_one, 
                                                           parent_local_map, local_parent_map )
      parent_controls_two = parent_controls_parent_index?( parent_array, parent_index_two, 
                                                           parent_local_map, local_parent_map )
      
      # 1. parent controls both
      if parent_controls_one and parent_controls_two

        # swap in local => parent
        local_index_one = parent_local_map[ parent_index_one ]
        local_index_two = parent_local_map[ parent_index_two ]
        local_parent_map.swap( local_index_one, local_index_two )
        
        requires_lookup_one = @requires_lookup[ local_index_one ]
        @requires_lookup[ local_index_one ] = @requires_lookup[ local_index_two ]
        @requires_lookup[ local_index_two ] = requires_lookup_one
      
      # 2. parent controls index one
      elsif parent_controls_one
        
        # controlled index points to new parent index
        local_index_one = parent_local_map[ parent_index_one ]
        local_parent_map[ local_index_one ] = parent_index_two
      
      # 3. parent controls index two
      elsif parent_controls_two

        # controlled index points to new parent index
        local_index_two = parent_local_map[ parent_index_two ]
        local_parent_map[ local_index_two ] = parent_index_one

      end

      # swap in parent => local
      parent_local_map.swap( parent_index_one, parent_index_two )
            
    end
    
    return local_index_one, local_index_two
    
  end

  ################
  #  local_swap  #
  ################

  def local_swap( local_index_one, local_index_two )
    
    unless local_index_one == local_index_two

      parent_array_one = nil
      parent_array_two = nil
      
      # swap in local to array      
      if @local_index_to_parent_map
        parent_array_one = @local_index_to_parent_map[ local_index_one ]
        parent_array_two = @local_index_to_parent_map[ local_index_two ]
        @local_index_to_parent_map[ local_index_one ] = parent_array_two
        @local_index_to_parent_map[ local_index_two ] = parent_array_one
      end
      
      # if both local indexes have parents
      if parent_array_one and parent_array_two
        
        local_parent_map_one = local_parent_map( parent_array_one )
        parent_local_map_one = parent_local_map( parent_array_one )

        parent_index_one = local_parent_map_one[ local_index_one ]
        
        # if same parent, swap in parent
        if parent_array_one.equal?( parent_array_two )
          parent_index_two = local_parent_map_one[ local_index_two ]
          local_parent_map_one.swap( local_index_one, local_index_two )
          parent_local_map_one.swap( parent_index_one, parent_index_two )
        # otherwise change ref in each parent
        else
          local_parent_map_two = local_parent_map( parent_array_two )
          parent_local_map_two = parent_local_map( parent_array_two )
          parent_index_two = local_parent_map_two[ local_index_two ]

          local_parent_map_one.swap( local_index_one, local_index_two )
          local_parent_map_two.swap( local_index_one, local_index_two )

          parent_local_map_two[ parent_index_one ] = local_index_two
          parent_local_map_two[ parent_index_two ] = local_index_one
        end

      # if only index one has parent
      elsif parent_array_one

        local_parent_map_one = local_parent_map( parent_array_one )
        parent_local_map_one = parent_local_map( parent_array_one )
        parent_index_one = local_parent_map_one[ local_index_one ]

        local_parent_map_one.swap( local_index_one, local_index_two )

        parent_local_map_one[ parent_index_one ] = local_index_two
        local_parent_map_one[ local_index_two ] = parent_index_one

      # if only index two has parent
      elsif parent_array_two

        local_parent_map_two = local_parent_map( parent_array_two )
        parent_local_map_two = parent_local_map( parent_array_two )
        parent_index_two = local_parent_map_two[ local_index_two ]

        parent_local_map_two[ parent_index_two ] = local_index_one
        local_parent_map_two[ local_index_one ] = parent_index_two

      end

      if @requires_lookup
        requires_lookup_one = @requires_lookup[ local_index_one ]
        @requires_lookup[ local_index_one ] = @requires_lookup[ local_index_two ]
        @requires_lookup[ local_index_two ] = requires_lookup_one
      end
      
    end
    
    return self
    
  end
  
end
