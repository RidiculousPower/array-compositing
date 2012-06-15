
module ::CompositingArray::Interface
  
  instances_identify_as!( ::CompositingArray )
  
  ################
  #  initialize  #
  ################

  def initialize( parent_composite_array = nil, configuration_instance = nil, *args )

    super( configuration_instance, *args )
    
    # arrays that inherit from us
    @sub_composite_arrays = [ ]

    # hash tracking index in self corresponding to index in parent
    # this is since objects can be inserted before/between parent objects
    @replaced_parents = { }

    # initialize corresponding indexes in self to indexes in parent
    @local_index_for_parent_index = { }

    # we keep track of how many objects are interpolated between parent objects
    # plus number of parent objects
    @parent_and_interpolated_object_count = 0    

    initialize_for_parent( parent_composite_array )

  end

  ###################################  Sub-Array Management  #######################################

  ###########################
  #  initialize_for_parent  #
  ###########################

  def initialize_for_parent( parent_composite_array )

    if @parent_composite_object = parent_composite_array

      # initialize contents of self from parent contents
      unless @parent_composite_object.empty?
        update_as_sub_array_for_parent_insert( 0, *@parent_composite_object )
      end
      
      @parent_composite_object.register_sub_composite_array( self )

    end
    
  end
  
  #############################
  #  parent_composite_object  #
  #  parent_composite_array   #
  #############################

  attr_accessor :parent_composite_object

  alias_method :parent_composite_array, :parent_composite_object

  ##################################
  #  register_sub_composite_array  #
  ##################################

  def register_sub_composite_array( sub_composite_array )

    @sub_composite_arrays.push( sub_composite_array )

    return self

  end

  ####################################
  #  unregister_sub_composite_array  #
  ####################################

  def unregister_sub_composite_array( sub_composite_array )

    @sub_composite_arrays.delete( sub_composite_array )

    return self

  end

  ######################################  Subclass Hooks  ##########################################

  ########################
  #  child_pre_set_hook  #
  ########################

  def child_pre_set_hook( index, object, is_insert = false )

    return object
    
  end

  #########################
  #  child_post_set_hook  #
  #########################

  def child_post_set_hook( index, object, is_insert = false )
    
    return object
    
  end

  ###########################
  #  child_pre_delete_hook  #
  ###########################

  def child_pre_delete_hook( index )
    
    # false means delete does not take place
    return true
    
  end

  ############################
  #  child_post_delete_hook  #
  ############################

  def child_post_delete_hook( index, object )
    
    return object
    
  end

  #####################################  Self Management  ##########################################

  #########
  #  []=  #
  #########

  def []=( index, object )

    super
    
    if index_inside_parent_objects?( index )
      @replaced_parents[ index ] = true
    end
    
    @sub_composite_arrays.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_as_sub_array_for_parent_set( index, object )
      end
    end

    return object

  end
  
  ############
  #  insert  #
  ############

  def insert( index, *objects )
    
    super_objects = super
    
    # super might have inserted nils at the start if insert was after end of array
    index -= super_objects.count - objects.count
    objects = super_objects
    
    if index_inside_parent_objects?( index )
      update_corresponding_index_for_local_change( index, objects.count )
    end

    @sub_composite_arrays.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_as_sub_array_for_parent_insert( index, *objects )
      end
    end

    return objects

  end

  ###############
  #  delete_at  #
  ###############

  def delete_at( index )

    deleted_object = super( index )

    @replaced_parents.delete( index )

    if index_inside_parent_objects?( index )
      update_corresponding_index_for_local_change( index, -1 )      
    end

    @sub_composite_arrays.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_as_sub_array_for_parent_delete( index )
      end
    end

    return deleted_object

  end
      
  #############
  #  freeze!  #
  #############

  # freezes configuration and prevents ancestors from changing this configuration in the future
  def freeze!

    # unregister with parent composite so we don't get future updates from it
    if @parent_composite_object
      @parent_composite_object.unregister_sub_composite_array( self )
    end

    return self

  end

  ##################################################################################################
      private ######################################################################################
  ##################################################################################################

	################  Self Management for Inserts between Parent-Provided Elements  ##################

  ##################################
  #  index_inside_parent_objects?  #
  ##################################

  def index_inside_parent_objects?( index )

    index_inside_parent_objects = false

    if index < @parent_and_interpolated_object_count

      index_inside_parent_objects = true

    end

    return index_inside_parent_objects

  end

  #################################################
  #  update_corresponding_index_for_local_change  #
  #################################################

  def update_corresponding_index_for_local_change( index, step_value )

    # update corresponding indexes for changes in self

    indexes_to_delete = [ ]

    @local_index_for_parent_index.each do |this_parent_index, this_local_index|
      if this_parent_index >= index
        existing_corresponding_value = @local_index_for_parent_index[ this_parent_index ]
        new_corresponding_value = existing_corresponding_value + step_value
        if new_corresponding_value >= 0
          @local_index_for_parent_index[ this_parent_index ] = new_corresponding_value
        else
          indexes_to_delete.push( this_parent_index )
        end
      end
    end

    step_parent_and_interpolated_object_count( step_value )

  end

  #########################  Self-as-Sub Management for Parent Updates  ############################

  ########################################
  #  update_as_sub_array_for_parent_set  #
  ########################################

  def update_as_sub_array_for_parent_set( index, object )

    # if our index is bigger than current parent set we are inserting
    if index >= @parent_and_interpolated_object_count

      update_as_sub_array_for_parent_insert( index, object )

    # otherwise we are replacing and have a corresponding element defined already
    else

      unless @replaced_parents[ index ]

        corresponding_index = @local_index_for_parent_index[ index ]

        update_parent_element_in_self( corresponding_index, object )

        @sub_composite_arrays.each do |this_array|
          this_array.instance_eval do
            update_as_sub_array_for_parent_set( corresponding_index, object )
          end
        end

      end

    end

  end

  ###################################
  #  update_parent_element_in_self  #
  ###################################

  def update_parent_element_in_self( corresponding_index, object )

    unless @without_hooks
      
      object = pre_set_hook( corresponding_index, object, false )
    
      object = child_pre_set_hook( corresponding_index, object, false )
    
    end
    
    perform_set_between_hooks( corresponding_index, object )

    unless @without_hooks
      child_post_set_hook( corresponding_index, object, false )
    end
    
  end

  ###########################################
  #  update_as_sub_array_for_parent_insert  #
  ###########################################

  def update_as_sub_array_for_parent_insert( index, *objects )

    # new parent indexes have been inserted at index in parent

    # we need the corresponding index in self where parallel insert will occur
    if corresponding_index = @local_index_for_parent_index[ index ]

      if corresponding_index < 0
        corresponding_index = 0
      else
        update_corresponding_index_for_parent_change( index, objects.count )
      end

    else

      corresponding_index = @parent_and_interpolated_object_count
      @parent_and_interpolated_object_count += objects.count

    end

    # then we're going to increment existing correspondences
    # now since we added a space for the new elements we can add their new correspondences
    objects.count.times do |this_time|
      new_parent_index = index + this_time
      new_corresponding_index = corresponding_index + this_time
      @local_index_for_parent_index[ new_parent_index ] = new_corresponding_index
    end

    insert_parent_elements_in_self( corresponding_index, *objects )
    
    @sub_composite_arrays.each do |this_array|
      this_array.instance_eval do
        update_as_sub_array_for_parent_insert( corresponding_index, *objects )
      end
    end

  end

  ####################################
  #  insert_parent_elements_in_self  #
  ####################################

  def insert_parent_elements_in_self( corresponding_index, *objects )

    objects_to_insert = [ ]
    objects.each_with_index do |this_object, this_index|
      unless @without_hooks
        this_object = pre_set_hook( corresponding_index + this_index, this_object, true )
        this_object = child_pre_set_hook( corresponding_index + this_index, this_object, true )
      end
      # only keep objects the pre-set hook says to keep
      objects_to_insert.push( this_object )
    end
    objects = objects_to_insert
    
    perform_insert_between_hooks( corresponding_index, *objects )

    unless @without_hooks
      objects.each_with_index do |this_object, this_index|
        post_set_hook( corresponding_index + this_index, this_object, true )
        child_post_set_hook( corresponding_index + this_index, this_object, true )
      end
    end
    
  end

  ###########################################
  #  update_as_sub_array_for_parent_delete  #
  ###########################################

  def update_as_sub_array_for_parent_delete( index )

    corresponding_index = @local_index_for_parent_index[ index ]
    
    if @without_hooks
      child_pre_delete_hook_result = true
    else
      child_pre_delete_hook_result = child_pre_delete_hook( index )
    end
    
    if child_pre_delete_hook_result
      object = perform_delete_between_hooks( corresponding_index )
    end
    
    @parent_and_interpolated_object_count -= 1

    unless @without_hooks
      child_post_delete_hook( index, object )
    end
    
    @sub_composite_arrays.each do |this_array|
      this_array.instance_eval do
        update_as_sub_array_for_parent_delete( corresponding_index )
      end
    end

  end

  ##################################################
  #  update_corresponding_index_for_parent_change  #
  ##################################################

  def update_corresponding_index_for_parent_change( parent_index, step_value )

      # update corresponding indexes for changes in parent

    stepped_indices = { }

    # iterate the hash with all indices included and increment/decrement any >= parent_index
    @local_index_for_parent_index.each do |this_parent_index, this_local_index|
      if this_parent_index >= parent_index
        new_index = this_parent_index + step_value
        new_local_index = @local_index_for_parent_index.delete( this_parent_index ) + step_value
        stepped_indices[ new_index ] = new_local_index
      end
    end

    # merge stepped indices back in
    @local_index_for_parent_index.merge!( stepped_indices )

    step_parent_and_interpolated_object_count( step_value )

  end

  ###############################################
  #  step_parent_and_interpolated_object_count  #
  ###############################################

  def step_parent_and_interpolated_object_count( step_value )

    @parent_and_interpolated_object_count += step_value

    if @parent_and_interpolated_object_count < 0
      @parent_and_interpolated_object_count = 0
    end

  end
  
end