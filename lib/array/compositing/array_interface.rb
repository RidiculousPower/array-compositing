
module ::Array::Compositing::ArrayInterface

  include ::Array::Hooked::ArrayInterface
  
  instances_identify_as!( ::Array::Compositing )

  ParentIndexStruct = ::Struct.new( :local_index, :replaced )

  extend ::Module::Cluster
  
  cluster( :compositing_array_interface ).before_include.cascade_to( :class ) do |hooked_instance|
    
    hooked_instance.class_eval do
      
      unless method_defined?( :non_cascading_set )
        alias_method :non_cascading_set, :[]=
      end

      unless method_defined?( :non_cascading_insert )
        alias_method :non_cascading_insert, :insert
      end

      unless method_defined?( :non_cascading_delete_at )
        alias_method :non_cascading_delete_at, :delete_at
      end
      
    end
    
  end
  
  ################
  #  initialize  #
  ################

  def initialize( parent_composite_array = nil, configuration_instance = nil, *args )

    super( configuration_instance, *args )
    
    # arrays that inherit from us
    @sub_composite_arrays = [ ]

    initialize_for_parent( parent_composite_array )

  end

  ###################################  Sub-Array Management  #######################################

  ###########################
  #  initialize_for_parent  #
  ###########################

  def initialize_for_parent( parent_composite_array )

    if @parent_composite_object = parent_composite_array

      @parent_index_map = ::Array::Compositing::ParentIndexMap.new

      @parent_composite_object.register_sub_composite_array( self )
      
      # record in our parent index map that parent has elements that have been inserted      
      parent_element_count = @parent_composite_object.count
      @parent_index_map.parent_insert( 0, parent_element_count )
      
      # initialize contents of self from parent contents
      parent_element_count.times do |this_time|
        # placeholders so we don't have to stub :count, etc.
        undecorated_insert( 0, nil )
      end
      
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

  ########
  #  ==  #
  ########

  def ==( object )
    
    load_parent_state

    return super
    
  end

  #############
  #  inspect  #
  #############
  
  def inspect

    load_parent_state
   
    super
    
  end

  ##########
  #  each  #
  ##########
  
  def each( *args, & block )

    return to_enum unless block_given?

    for index in 0...count
      block.call( self[ index ] )
    end
    
    return self
    
  end

  ##############
  #  include?  #
  ##############

  def include?( object )

    includes = false
    
    each do |this_member|
      if this_member == object
        includes = true 
        break
      end
    end

    return includes
    
  end

  ########
  #  []  #
  ########

  def []( local_index )

    return_value = nil

    if @parent_index_map and @parent_index_map.requires_lookup?( local_index )
      return_value = lazy_set_parent_element_in_self( local_index )
    else
      return_value = super
    end

    return return_value

  end

  #########
  #  []=  #
  #########

  def []=( local_index, object )
    
    super

    @sub_composite_arrays.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_for_parent_set( local_index, object )
      end
    end

    return object

  end
  
  alias_method :store, :[]=

  ###############
  #  delete_at  #
  ###############

  def delete_at( local_index )
    
    if @parent_index_map
      @parent_index_map.local_delete_at( local_index )
    end
    
    deleted_object = non_cascading_delete_at( local_index )

    @sub_composite_arrays.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_for_parent_delete_at( local_index, deleted_object )
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

  ######################################################################################################################
      private ##########################################################################################################
  ######################################################################################################################

  ###############################
  #  perform_set_between_hooks  #
  ###############################

  def perform_set_between_hooks( local_index, object )
    
    did_set = false
    
    if did_set = super and @parent_index_map
      @parent_index_map.local_set( local_index )
    else
    end
    
    return did_set
    
  end
  
  ################################################
  #  perform_single_object_insert_between_hooks  #
  ################################################
  
  def perform_single_object_insert_between_hooks( requested_local_index, object )

    if local_index = super
      
      if @parent_index_map
        @parent_index_map.local_insert( local_index, 1 )
      end
      
      @sub_composite_arrays.each do |this_sub_array|
        this_sub_array.instance_eval do
          update_for_parent_insert( requested_local_index, local_index, object )
        end
      end
    
    end
    
    return local_index
    
  end

  #####################################
  #  lazy_set_parent_element_in_self  #
  #####################################

  def lazy_set_parent_element_in_self( local_index, *optional_object )
    
    object = nil
    
    if @parent_index_map.requires_lookup?( local_index )
          
      case optional_object.count
        when 0
          parent_index = @parent_index_map.parent_index( local_index )
          object = @parent_composite_object[ parent_index ]
        when 1
          object = optional_object[ 0 ]
      end
        
      # We call hooks manually so that we can do a direct undecorated set.
      # This is because we already have an object we loaded as a place-holder that we are now updating.
      # So we don't want to sort/test uniqueness/etc. We just want to insert at the actual index.

      unless @without_child_hooks
        object = child_pre_set_hook( local_index, object, false )    
      end
    
      unless @without_hooks
        object = pre_set_hook( local_index, object, false )    
      end
    
      undecorated_set( local_index, object )

      @parent_index_map.looked_up!( local_index )

      unless @without_hooks
        post_set_hook( local_index, object, false )
      end

      unless @without_child_hooks
        child_post_set_hook( local_index, object, false )
      end

    else
      
      object = undecorated_get( local_index )
      
    end
    
    return object
    
  end

  ###########################
  #  update_for_parent_set  #
  ###########################

  def update_for_parent_set( parent_index, object )

    unless @parent_index_map.replaced_parent_element_with_parent_index?( parent_index )

      local_index = @parent_index_map.parent_set( parent_index )
    
      undecorated_set( local_index, nil )
    
      if @parent_index_map.requires_lookup?( local_index )

        @sub_composite_arrays.each do |this_array|
          this_array.instance_eval do
            update_for_parent_set( local_index, object )
          end
        end

      end

    end

  end

  ##############################
  #  update_for_parent_insert  #
  ##############################

  def update_for_parent_insert( requested_parent_index, parent_index, object )

    local_index = @parent_index_map.parent_insert( parent_index, 1 )

    undecorated_insert( local_index, nil )

    @sub_composite_arrays.each do |this_array|
      this_array.instance_eval do
        update_for_parent_insert( local_index, local_index, object )
      end
    end
    
  end

  #################################
  #  update_for_parent_delete_at  #
  #################################

  def update_for_parent_delete_at( parent_index, object )

    did_delete = false

    unless @parent_index_map.replaced_parent_element_with_parent_index?( parent_index )
      
      local_index = @parent_index_map.local_index( parent_index )
      
      if @without_child_hooks
        child_pre_delete_hook_result = true
      else
        child_pre_delete_hook_result = child_pre_delete_hook( local_index )
      end
    
      if child_pre_delete_hook_result

        @parent_index_map.parent_delete_at( parent_index )

        # I'm unclear why if we call perform_delete_between_hooks (including through non_cascading_delete_at)
        # we end up smashing the last index's lazy lookup value, turning it false
        # for now simply adding hooks manually here works; the only loss is a little duplicate code
        # to call the local (non-child) hooks
        if @without_hooks
          pre_delete_hook_result = true
        else
          pre_delete_hook_result = pre_delete_hook( local_index )
        end

        if pre_delete_hook_result

          object = undecorated_delete_at( local_index )

          did_delete = true

          unless @without_hooks
            object = post_delete_hook( local_index, object )
          end

          unless @without_child_hooks
            child_post_delete_hook( local_index, object )
          end

          @sub_composite_arrays.each do |this_array|
            this_array.instance_eval do
              update_for_parent_delete_at( local_index, object )
            end
          end

        end
        
      else

        if @parent_index_map.requires_lookup?( local_index )
          lazy_set_parent_element_in_self( local_index, object )
        end
      
      end
    
    end
    
    return did_delete
    
  end

  ######################
  #  parent_reversed!  #
  ######################
  
  def parent_reversed!
    
    @sort_order_reversed = ! @sort_order_reversed
    
  end

  #######################
  #  load_parent_state  #
  #######################

  def load_parent_state

    # if is used for case where duplicate is created (like :uniq) and initialization not called during dupe process
    if @parent_index_map
      @parent_index_map.indexes_requiring_lookup.each do |this_local_index|
        lazy_set_parent_element_in_self( this_local_index )
      end
    end
    
  end
  
end