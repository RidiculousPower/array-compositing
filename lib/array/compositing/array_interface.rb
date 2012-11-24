
module ::Array::Compositing::ArrayInterface

  include ::Array::Hooked::ArrayInterface
  
  instances_identify_as!( ::Array::Compositing )

  ParentIndexStruct = ::Struct.new( :local_index, :replaced )

  extend ::Module::Cluster
    
  ################
  #  initialize  #
  ################
  
  ###
  # @overload initialize( parent_instance, configuration_instance, array_initialization_arg, ... )
  #
  #   @param [Array::Compositing] parent_instance
  #   
  #          Instance from which instance will inherit elements.
  #   
  #   @param [Object] configuration_instance
  #   
  #          Instance associated with instance.
  #   
  #   @param array_initialization_arg
  #   
  #          Arguments passed to Array#initialize.
  #
  def initialize( parent_instance = nil, configuration_instance = nil, *array_initialization_args )

    super( configuration_instance, *array_initialization_args )
    
    @parent_index_map = ::Array::Compositing::ParentIndexMap.new
    
    # arrays from which we inherit
    @parents = ::Array::Compositing::ParentsArray.new
    
    # arrays that inherit from us
    @children = [ ]

    if parent_instance
      register_parent( parent_instance )
    end
    
  end

  ###################################  Non-Cascading Behavior  ####################################

  #######################
  #  non_cascading_set  #
  #######################
  
  ###
  # @method non_cascading_set( index, object )
  #
  # Perform Array#[]= without cascading to children.
  #
  # @param [Integer] index
  #
  #        Index for set.
  #
  # @param [Object] object
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

  ##########################
  #  non_cascading_insert  #
  ##########################

  ###
  # @method non_cascading_insert( index, object, ... )
  #
  # Perform Array#insert without cascading to children.
  #
  # @param [Integer] index
  #
  #        Index for insert.
  #
  # @param [Object] object
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
  
  #############################
  #  non_cascading_delete_at  #
  #############################
  
  ###
  # @method non_cascading_delete_at( index, object )
  #
  # Perform Array#delete_at without cascading to children.
  #
  # @param [Integer] index
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

  ###################################  Sub-Array Management  #######################################

  #####################
  #  register_parent  #
  #####################
  
  ###
  # Register a parent for element inheritance.
  #
  # @param [Array::Compositing] parent_instance
  #
  #        Instance from which instance will inherit elements.
  #
  # @param [Integer] insert_at_index
  #
  #        Index where parent elements will be inserted.
  #        Default is that new parent elements will be inserted after last existing parent element.
  #
  # @return [Array::Compositing] 
  #
  #         Self.
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
  # @param [Array::Compositing] parent_instance
  #
  #        Instance from which instance will inherit elements.
  #
  # @return [Array::Compositing] 
  #
  #         Self.
  #
  def unregister_parent( parent_instance )
    
    if local_indexes_to_delete = @parent_index_map.unregister_parent( parent_instance )
      delete_at_indexes( *local_indexes_to_delete )
    end
    
    @parents.delete( parent_instance )
    parent_instance.unregister_child( self )

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
  # @param [Array::Compositing] parent_instance
  #
  #        Existing instance from which instance is inheriting elements.
  #
  # @param [Array::Compositing] parent_instance
  #
  #        New instance from which instance will inherit elements instead.
  #
  # @return [Array::Compositing] 
  #
  #         Self.
  #
  def replace_parent( parent_instance, new_parent_instance  )
    
    unregister_parent( parent_instance )
    
    register_parent( new_parent_instance )
    
    return self
    
  end
  
  ####################
  #  register_child  #
  ####################
  
  ###
  # Register child instance that will inherit elements.
  #
  # @param [Array::Compositing] child_composite_array
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
  # @param [Array::Compositing] child_composite_array
  #
  #        Instance that should no longer inherit elements from this instance.
  #
  # @return [Array::Compositing] 
  #
  #         Self.
  #
  def unregister_child( child_composite_array )

    @children.delete( child_composite_array )

    return self

  end

  ##################
  #  has_parents?  #
  ##################
  
  ###
  # Query whether instance has parent instances from which it inherits elements.
  #
  # @return [true,false] 
  #
  #         Whether instance has one or more parent instances.
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
  #         Array of parents.
  #
  attr_reader :parents

  #################
  #  is_parent?  #
  #################
  
  ###
  # Query whether instance has instance as a parent instance from which it inherits elements.
  #
  # @params [Array::Compositing] potential_parent_instance
  # 
  #         Instance being queried.
  # 
  # @return [true,false] 
  #
  #         Whether potential_parent_instance is a parent of instance.
  #
  def is_parent?( potential_parent_instance )
    
    return @parents.include?( potential_parent_instance )
    
  end

  ######################################  Subclass Hooks  ##########################################

  ########################
  #  child_pre_set_hook  #
  ########################

  ###
  # A hook that is called before setting a value inherited from a parent set; 
  #   return value is used in place of object.
  #
  # @param [Integer] index 
  #
  #        Index at which set/insert is taking place.
  #
  # @param [Object] object 
  #
  #        Element being set/inserted.
  #
  # @param [true,false] is_insert 
  #
  #        Whether this set or insert is inserting a new index.
  #
  # @param [Array::Compositing] parent_instance 
  #
  #        Instance that initiated set or insert.
  #
  # @param [Array::Compositing] parent_instance 
  #
  #        Instance that initiated set or insert.
  #
  # @return [true,false] 
  #
  #         Return value is used in place of object.
  #
  def child_pre_set_hook( index, object, is_insert = false, parent_instance = nil )

    return object
    
  end

  #########################
  #  child_post_set_hook  #
  #########################

  ###
  # A hook that is called after setting a value inherited from a parent set.
  #
  # @param [Integer] index 
  #
  #        Index at which set/insert is taking place.
  #
  # @param [Object] object 
  #
  #        Element being set/inserted.
  #
  # @param [true,false] is_insert 
  #
  #        Whether this set or insert is inserting a new index.
  #
  # @param [Array::Compositing] parent_instance 
  #
  #        Instance that initiated set or insert.
  #
  # @return [Object] Ignored.
  #
  def child_post_set_hook( index, object, is_insert = false, parent_instance = nil )
    
    return object
    
  end

  ###########################
  #  child_pre_delete_hook  #
  ###########################

  ###
  # A hook that is called before deleting a value inherited from a parent delete; 
  #   if return value is false, delete does not occur.
  #
  # @param [Integer] index 
  #
  #        Index at which delete is taking place.
  #
  # @param [Array::Compositing] parent_instance 
  #
  #        Instance that initiated delete.
  #
  # @return [true,false] 
  #
  #         If return value is false, delete does not occur.
  #
  def child_pre_delete_hook( index, parent_instance = nil )
    
    # false means delete does not take place
    return true
    
  end

  ############################
  #  child_post_delete_hook  #
  ############################

  ###
  # A hook that is called after deleting a value inherited from a parent delete.
  #
  # @param [Integer] index 
  #
  #        Index at which delete took place.
  #
  # @param [Object] object 
  #
  #        Element deleted.
  #
  # @param [Array::Compositing] parent_instance 
  #
  #        Instance that initiated delete.
  #
  # @return [Object] 
  #
  #         Object returned in place of delete result.
  #
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

  ############
  #  to_a  #
  ############
  
  def to_a

    load_parent_state
   
    super
    
  end

  ############
  #  to_ary  #
  ############
  
  def to_ary

    load_parent_state
   
    super
    
  end

  ##########
  #  to_s  #
  ##########
  
  def to_s
   
    load_parent_state
   
    super
    
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
  
  ###
  # Unregisters all parents without removing values inherited from them.
  #
  # @return [Array::Compositing]
  #
  #         Self.
  #
  def freeze!( parent_instance = nil )
    
    # look up all values
    load_parent_state( parent_instance )
    
    if parent_instance
      
      parent_instance.unregister_child( self )
      
    else
      
      # unregister with parent composite so we don't get future updates from it
      @parents.each do |this_parent_instance|
        this_parent_instance.unregister_child( self )
      end
      
    end
    
    return self

  end

  #######################
  #  load_parent_state  #
  #######################

  ###
  # Load all elements not yet inherited from parent or parents (but marked to be inherited).
  #
  # @param [Array::Compositing] parent_instance
  #
  #        Load state only from parent instance if specified.
  #        Otherwise all parent's state will be loaded.
  #
  # @return [Array::Compositing]
  #
  #         Self.
  #
  def load_parent_state( parent_instance = nil )

    #
    # We have to check for @parent_index_map.
    #
    # This is because of cases where duplicate instance is created (like #uniq) 
    # and initialization not called during dup process.
    #
    if @parent_index_map
    
      if parent_instance

        @parent_index_map.indexes_requiring_lookup.each do |this_local_index, this_parent_struct|
          if this_parent_struct.parent_instance == parent_instance
            lazy_set_parent_element_in_self( this_local_index )
          end
        end
      
      else
      
        @parent_index_map.indexes_requiring_lookup.each do |this_local_index, this_parent_struct|
          lazy_set_parent_element_in_self( this_local_index )
        end
      
      end
        
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
  
  ###
  # Perform look-up of local index in parent or load value delivered from parent
  #   when parent delete was prevented in child.
  #
  # @overload lazy_set_parent_element_in_self( local_index, optional_object, ... )
  #
  #   @param [Integer] local_index
  #
  #          Index in instance for which value requires look-up/set.
  #
  #   @param [Object] optional_object
  #
  #          If we deleted in parent and then child delete hook prevented local delete
  #          then we have an object passed since our parent can no longer provide it
  #
  # @return [Object]
  #
  #         Lazy set value.
  #
  def lazy_set_parent_element_in_self( local_index, *optional_object )

    object = nil
    
    if @parent_index_map.requires_lookup?( local_index )

      parent_index_struct = @parent_index_map.parent_index( local_index )
      parent_instance = parent_index_struct.parent_instance
          
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
  
  ###
  # Perform #set in self inherited from #set requested on parent (or parent of parent).
  #
  # @param [Array::Compositing] parent_instance
  #
  #        Instance where #set occurred that is now cascading downward.
  #
  # @param [Integer] parent_index
  #
  #        Index in parent where #set occurred.
  #
  # @param [Object] object
  #
  #        Object set at index.
  #
  # @return [Array::Compositing]
  #
  #         Self.
  #
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
    
    return self

  end

  ##############################
  #  update_for_parent_insert  #
  ##############################

  ###
  # Perform #insert in self inherited from #insert requested on parent (or parent of parent).
  #   Inserts cascade individually, even if #insert was called on the parent with multiple
  #   objects.
  #
  # @param [Array::Compositing] parent_instance
  #
  #        Instance where #insert occurred that is now cascading downward.
  #
  # @param [Integer] parent_index
  #
  #        Index in parent where #insert occurred.
  #
  # @param [Object] object
  #
  #        Object to insert at index.
  #
  # @return [Array::Compositing]
  #
  #         Self.
  #
  def update_for_parent_insert( parent_instance, requested_parent_index, parent_index, object )

    local_index = @parent_index_map.parent_insert( parent_instance, parent_index, 1 )

    undecorated_insert( local_index, nil )

    parent_instance = self

    @children.each do |this_array|
      this_array.instance_eval do
        update_for_parent_insert( parent_instance, local_index, local_index, object )
      end
    end

    return self
    
  end

  #################################
  #  update_for_parent_delete_at  #
  #################################

  ###
  # Perform #set in self inherited from #delete_at requested on parent (or parent of parent).
  #
  # @param [Array::Compositing] parent_instance
  #
  #        Instance where #delete_at occurred that is now cascading downward.
  #
  # @param [Integer] parent_index
  #
  #        Index in parent where #delete_at occurred.
  #
  # @param [Object] object
  #
  #        Object returned from parent #delete_at.
  #
  # @return [true,false]
  #
  #        Whether delete occurred.
  #
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
  
  ###
  # Tell instance that parent has reversed its order.
  #   This is necessary because cascading changes will already cause 
  #   elements to have reversed, but instance needs to know it was
  #   reversed so that sorting can continue appropriately.
  #
  # @return [true,false]
  #
  #         Whether resulting sort order is reversed.
  #   
  def parent_reversed!
    
    return @sort_order_reversed = ! @sort_order_reversed
    
  end
  
end