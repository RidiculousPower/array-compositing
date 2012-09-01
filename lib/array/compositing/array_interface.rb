
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
    
    @parent_index_map = ::Array::Compositing::ParentIndexMap.new
    
    # arrays from which we inherit
    @parent_composite_objects = [ ]
    
    # arrays that inherit from us
    @child_composite_objects = [ ]

    if parent_composite_array
      register_parent_composite_array( parent_composite_array )
    end
    
  end

  ###################################  Sub-Array Management  #######################################

  #####################################
  #  register_parent_composite_array  #
  #####################################

  def register_parent_composite_array( parent_composite_array )
    
    @parent_composite_objects.push( parent_composite_array )

    @parent_index_map.register_parent_composite_array( parent_composite_array )
    
    parent_composite_array.register_child_composite_array( self )
    
    # where do we insert new parents?
    # * beginning of self
    # * end of existing parent elements in self
    # * end of self
    # we choose #2 for now - this could be made an option later.
    insert_at_index = @parent_index_map.first_index_after_last_parent_element

    inheriting_element_count = parent_composite_array.count

    # record in our parent index map that parent has elements that have been inserted      
    @parent_index_map.parent_insert( parent_composite_array, insert_at_index, inheriting_element_count )
    
    # placeholders so we don't have to stub :count, etc.
    inheriting_element_count.times do |this_time|
      undecorated_insert( insert_at_index, nil )
    end    
    
  end
  
  #######################################
  #  unregister_parent_composite_array  #
  #######################################

  def unregister_parent_composite_array( parent_composite_array )
    
    
    
  end
  
  ####################
  #  replace_parent  #
  ####################
  
  def replace_parent( existing_parent_composite_array, replacement_parent_composite_array )
    
    
    
  end
  
  #############################
  #  parent_composite_object  #
  #  parent_composite_array   #
  #############################

  attr_accessor :parent_composite_object

  alias_method :parent_composite_array, :parent_composite_object

  ####################################
  #  register_child_composite_array  #
  ####################################

  def register_child_composite_array( child_composite_array )

    @child_composite_objects.push( child_composite_array )

    return self

  end

  ######################################
  #  unregister_child_composite_array  #
  ######################################

  def unregister_child_composite_array( child_composite_array )

    @child_composite_objects.delete( child_composite_array )

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
   
    return super
    
  end

  ##########
  #  each  #
  ##########
  
  def each( *args, & block )

    load_parent_state
   
    return super
    
  end

  ##############
  #  include?  #
  ##############

  def include?( object )

    includes = false
    
    each do |this_member|
      if this_member.equal?( object ) or this_member == object
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

    @child_composite_objects.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_for_parent_set( self, local_index, object )
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

    @child_composite_objects.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_for_parent_delete_at( self, local_index, deleted_object )
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
    @parent_composite_objects.each do |this_parent_composite_array|
      this_parent_composite_array.unregister_child_composite_array( self )
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
      
      @child_composite_objects.each do |this_sub_array|
        this_sub_array.instance_eval do
          update_for_parent_insert( self, requested_local_index, local_index, object )
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
    
    if parent_array_instance = @parent_index_map.requires_lookup?( local_index )
          
      case optional_object.count
        when 0
          parent_index = @parent_index_map.parent_index( local_index )
          object = parent_array_instance[ parent_index ]
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

  def update_for_parent_set( parent_instance, parent_index, object )

    unless @parent_index_map.replaced_parent_element_with_parent_index?( parent_instance, parent_index )

      local_index = @parent_index_map.parent_set( parent_instance, parent_index )
    
      undecorated_set( local_index, nil )
    
      if @parent_index_map.requires_lookup?( local_index )

        @child_composite_objects.each do |this_array|
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

  def update_for_parent_insert( parent_instance, requested_parent_index, parent_index, object )

    local_index = @parent_index_map.parent_insert( parent_instance, parent_index, 1 )

    undecorated_insert( local_index, nil )

    @child_composite_objects.each do |this_array|
      this_array.instance_eval do
        update_for_parent_insert( self, local_index, local_index, object )
      end
    end
    
  end

  #################################
  #  update_for_parent_delete_at  #
  #################################

  def update_for_parent_delete_at( parent_instance, parent_index, object )

    did_delete = false

    unless @parent_index_map.replaced_parent_element_with_parent_index?( parent_instance, parent_index )
      
      local_index = @parent_index_map.local_index( parent_instance, parent_index )
      
      if @without_child_hooks
        child_pre_delete_hook_result = true
      else
        child_pre_delete_hook_result = child_pre_delete_hook( local_index )
      end
    
      if child_pre_delete_hook_result

        @parent_index_map.parent_delete_at( parent_instance, parent_index )

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

          @child_composite_objects.each do |this_array|
            this_array.instance_eval do
              update_for_parent_delete_at( self, local_index, object )
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