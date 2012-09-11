
module ::Array::Compositing::ArrayInterface

  include ::Array::Hooked::ArrayInterface
  
  instances_identify_as!( ::Array::Compositing )

  ParentIndexStruct = ::Struct.new( :local_index, :replaced )

  extend ::Module::Cluster
  
  ###
  # @method non_cascading_set( index, object )
  #
  # Perform Array#set without cascading to children.
  #
  # @param index
  #
  #        Index for set.
  #
  # @param object
  #
  #        Object to set at index.
  #
  # @return [Object]
  #
  #         Object set.
  #
  cluster( :non_cascading_set ).before_include.cascade_to( :class ) do |hooked_instance|
    
    hooked_instance.class_eval do
      
      unless method_defined?( :non_cascading_set )
        alias_method :non_cascading_set, :[]=
      end
      
    end

  end

  ###
  # @method non_cascading_insert( index, object )
  #
  # Perform Array#insert without cascading to children.
  #
  # @param index
  #
  #        Index for insert.
  #
  # @param objects
  #
  #        Objects to insert at index.
  #
  # @return [Object]
  #
  #         Objects inserted.
  #
  cluster( :non_cascading_insert ).before_include.cascade_to( :class ) do |hooked_instance|
    
    hooked_instance.class_eval do
      
      unless method_defined?( :non_cascading_insert )
        alias_method :non_cascading_insert, :insert
      end

    end
    
  end
  
  ###
  # @method non_cascading_delete_at( index, object )
  #
  # Perform Array#delete_at without cascading to children.
  #
  # @param index
  #
  #        Index for delete.
  #
  # @return [Object]
  #
  #         Object set.
  #
  cluster( :non_cascading_delete_at ).before_include.cascade_to( :class ) do |hooked_instance|
    
    hooked_instance.class_eval do
      
      unless method_defined?( :non_cascading_delete_at )
        alias_method :non_cascading_delete_at, :delete_at
      end
      
    end
    
  end
    
  ################
  #  initialize  #
  ################
  
  ###
  # @param parent_instance
  #
  #        Array::Compositing instance from which instance will inherit elements.
  #
  # @param configuration_instance
  #
  #        Object instance associated with instance.
  #
  # @param array_initialize_args
  #
  #        Arguments passed to Array#initialize.
  #
  def initialize( parent_instance = nil, configuration_instance = nil, *array_initialize_args )

    super( configuration_instance, *array_initialize_args )
    
    @parent_index_map = ::Array::Compositing::ParentIndexMap.new
    
    # arrays from which we inherit
    @parents = [ ]
    
    # arrays that inherit from us
    @children = [ ]

    if parent_instance
      register_parent( parent_instance )
    end
    
  end

  ###################################  Sub-Array Management  #######################################

  #####################
  #  register_parent  #
  #####################
  
  ###
  # Register a parent for element inheritance.
  #
  # @param parent_instance
  #
  #        Array::Compositing instance from which instance will inherit elements.
  #
  # @param insert_at_index
  #
  #        Index where parent elements will be inserted.
  #        Default is that new parent elements will be inserted after last existing parent element.
  #
  # @return [Array::Compositing] Self.
  #
  def register_parent( parent_instance, 
                       insert_at_index = @parent_index_map.first_index_after_last_parent_element )
    
    unless @parents.include?( parent_instance )
      
      @parents.push( parent_instance )

      @parent_index_map.register_parent( parent_instance )
    
      parent_instance.register_child( self )

      inheriting_element_count = parent_instance.count

      # record in our parent index map that parent has elements that have been inserted      
      @parent_index_map.parent_insert( parent_instance, 0, inheriting_element_count )
    
      # placeholders so we don't have to stub :count, etc.
      inheriting_element_count.times do |this_time|
        undecorated_insert( insert_at_index, nil )
      end    
    
    end
    
    return self

  end
  
  #######################
  #  unregister_parent  #
  #######################

  ###
  # Unregister a parent for element inheritance and remove all associated elements.
  #
  # @param parent_instance
  #
  #        Array::Compositing instance from which instance will inherit elements.
  #
  # @return [Array::Compositing] Self.
  #
  def unregister_parent( parent_instance )
    
    local_indexes_to_delete = @parent_index_map.unregister_parent( parent_instance )
    
    @parents.delete( parent_instance )
    
    parent_instance.unregister_child( self )

    delete_at_indexes( *local_indexes_to_delete )

    return self
    
  end

  ####################
  #  replace_parent  #
  ####################

  ###
  # Replace a registered parent for element inheritance with a different parent,
  #   removing all associated elements of the existing parent and adding those
  #   from the new parent.
  #
  # @param parent_instance
  #
  #        Existing Array::Compositing instance from which instance is inheriting elements.
  #
  # @param parent_instance
  #
  #        New Array::Compositing instance from which instance will inherit elements instead.
  #
  # @return [Array::Compositing] Self.
  #
  def replace_parent( parent_instance, new_parent_instance  )
    
    unregister_parent( parent_instance )
    
    register_parent( new_parent_instance )
    
    return self
    
  end
  
  ##################
  #  has_parents?  #
  ##################
  
  ###
  # Query whether instance has parent instances from which it inherits elements.
  #
  # @return [true,false] Whether instance has one or more parent instances.
  #
  def has_parents?
    
    return ! @parents.empty?
    
  end

  #############
  #  parents  #
  #############
  
  ###
  # @!attribute [r]
  #
  # Parents of instance from which instance inherits elements.
  #
  # @return [Array<Array::Compositing>]
  #
  attr_reader :parents

  #################
  #  has_parent?  #
  #################
  
  def has_parent?( parent_instance )
    
    return @parents.include?( parent_instance )
    
  end

  ####################
  #  register_child  #
  ####################
  
  ###
  # Register child instance that will inherit elements.
  #
  # @param child_composite_array
  #
  #        Instance that will inherit elements from this instance.
  #
  # @return [Array::Compositing] Self.
  #
  def register_child( child_composite_array )

    @children.push( child_composite_array )

    return self

  end

  ######################
  #  unregister_child  #
  ######################

  ###
  # Unregister child instance so that it will no longer inherit elements.
  #
  # @param child_composite_array
  #
  #        Instance that should no longer inherit elements from this instance.
  #
  # @return [Array::Compositing] Self.
  #
  def unregister_child( child_composite_array )

    @children.delete( child_composite_array )

    return self

  end

  ######################################  Subclass Hooks  ##########################################

  ########################
  #  child_pre_set_hook  #
  ########################

  def child_pre_set_hook( index, object, is_insert = false, parent_instance = nil )

    return object
    
  end

  #########################
  #  child_post_set_hook  #
  #########################

  def child_post_set_hook( index, object, is_insert = false, parent_instance = nil )
    
    return object
    
  end

  ###########################
  #  child_pre_delete_hook  #
  ###########################

  def child_pre_delete_hook( index, parent_instance = nil )
    
    # false means delete does not take place
    return true
    
  end

  ############################
  #  child_post_delete_hook  #
  ############################

  def child_post_delete_hook( index, object, parent_instance = nil )
    
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

    if @parent_index_map.requires_lookup?( local_index )
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

    parent_instance = self

    @children.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_for_parent_set( parent_instance, local_index, object )
      end
    end

    return object

  end
  
  alias_method :store, :[]=

  ###############
  #  delete_at  #
  ###############

  def delete_at( local_index )
    
    @parent_index_map.local_delete_at( local_index )
    
    deleted_object = non_cascading_delete_at( local_index )

    parent_instance = self

    @children.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_for_parent_delete_at( parent_instance, local_index, deleted_object )
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
    @parents.each do |this_parent_instance|
      this_parent_instance.unregister_child( self )
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
    
    if did_set = super
      @parent_index_map.local_set( local_index )
    end
    
    return did_set
    
  end
  
  ################################################
  #  perform_single_object_insert_between_hooks  #
  ################################################
  
  def perform_single_object_insert_between_hooks( requested_local_index, object )

    if local_index = super
      
      @parent_index_map.local_insert( local_index, 1 )
      
      parent_instance = self
      
      @children.each do |this_sub_array|
        this_sub_array.instance_eval do
          update_for_parent_insert( parent_instance, requested_local_index, local_index, object )
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

      parent_index_struct = @parent_index_map.parent_index( local_index )
      parent_instance = parent_index_struct.parent_instance
          
      # if we deleted in parent and then child delete hook prevented local delete
      # then we have an object passed since our parent can no longer provide it
      case optional_object.count
        when 0
          object = parent_instance[ parent_index_struct.parent_index ]
        when 1
          object = optional_object[ 0 ]
      end
        
      # We call hooks manually so that we can do a direct undecorated set.
      # This is because we already have an object we loaded as a place-holder that we are now updating.
      # So we don't want to sort/test uniqueness/etc. We just want to insert at the actual index.

      unless @without_child_hooks
        object = child_pre_set_hook( local_index, object, false, parent_instance )    
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
        child_post_set_hook( local_index, object, false, parent_instance )
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
    
      @children.each do |this_array|
        this_array.instance_eval do
          update_for_parent_set( local_index, object )
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

    parent_instance = self

    @children.each do |this_array|
      this_array.instance_eval do
        update_for_parent_insert( parent_instance, local_index, local_index, object )
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
        child_pre_delete_hook_result = child_pre_delete_hook( local_index, parent_instance )
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
            child_post_delete_hook( local_index, object, parent_instance )
          end

          parent_instance = self

          @children.each do |this_array|
            this_array.instance_eval do
              update_for_parent_delete_at( parent_instance, local_index, object )
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