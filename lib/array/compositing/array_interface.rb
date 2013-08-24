# -*- encoding : utf-8 -*-

module ::Array::Compositing::ArrayInterface

  include ::Array::Hooked::ArrayInterface
  
  instances_identify_as!( ::Array::Compositing )

  ################
  #  initialize  #
  ################
  
  ###
  # @overload initialize( parent_array, configuration_instance, array_initialization_arg, ... )
  #
  #   @param [Array::Compositing] parent_array
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
  def initialize( parent_array = nil, configuration_instance = nil, *array_initialization_args )

    super( configuration_instance, *array_initialization_args )
    
    @cascade_controller = ::Array::Compositing::CascadeController.new( self )
    
    # arrays from which we inherit
    @parents = ::Array::Compositing::CascadeController::ParentChildArray.new
    # arrays that inherit from us
    @children = ::Array::Compositing::CascadeController::ParentChildArray.new

    register_parent( parent_array ) if parent_array
    
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
  alias_method :non_cascading_set, :[]=

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
  alias_method :non_cascading_insert, :insert
  
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
  alias_method :non_cascading_delete_at, :delete_at

  #####################################
  #  non_cascading_delete_at_indexes  #
  #####################################
  
  ###
  # Perform delete_at on multiple indexes.
  #
  # @overload non_cascading_delete_at_indexes( index, ... )
  #
  #   @param [Integer] index
  #
  #          Index that should be deleted.
  #
  # @return [Array<Object>]
  #
  #         Objects deleted.
  #
  alias_method :non_cascading_delete_at_indexes, :delete_at_indexes

  ########################
  #  cascade_controller  #
  ########################

  ###
  # @!attribute [r]
  #
  # @return [Array::Compositing:CascadeController] 
  #
  #        The parent index map tracking array instance.
  #
  attr_reader :cascade_controller

  ###################################  Sub-Array Management  #######################################

  #####################
  #  register_parent  #
  #####################
  
  ###
  # Register a parent for element inheritance.
  #
  # @param [Array::Compositing] parent_array
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
  def register_parent( parent_array, insert_at_index = size )
    
    unless @parents.include?( parent_array )
      parent_array.register_child( self )
      @parents.push( parent_array )
      @cascade_controller.register_parent( parent_array, insert_at_index, false )
      insert_at_index ||= size
      parent_local_map = @cascade_controller.parent_local_map( parent_array )
      local_parent_map = @cascade_controller.local_parent_map( parent_array )
      filtered_objects = 0
      parent_array.size.times do |this_parent_index|
        unless register_parent_index( parent_array, 
                                      this_parent_index, 
                                      insert_at_index + this_parent_index - filtered_objects )
          filtered_objects += 1
        end
      end
    end
    
    return self

  end
  
  ###########################
  #  register_parent_index  #
  ###########################
  
  def register_parent_index( parent_array, parent_index, insert_at_index )
    
    # insert placeholders so we don't have to stub :count, etc.
    # we want undecorated because we are just inserting placeholders, hooks are called at lazy-load
    undecorated_insert( insert_at_index, nil )

    @cascade_controller.parent_insert( parent_array, parent_index, 1, insert_at_index )
    
    return true
    
  end
  
  #######################
  #  unregister_parent  #
  #######################

  ###
  # Unregister a parent for element inheritance and remove all associated elements.
  #
  # @param [Array::Compositing] parent_array
  #
  #        Instance from which instance will inherit elements.
  #
  # @return [Array::Compositing] 
  #
  #         Self.
  #
  def unregister_parent( parent_array )
    
    if @parents.delete( parent_array )
      parent_array.reverse_each_range do |this_object, this_parent_index|
        update_for_parent_delete_at( parent_array, this_parent_index, this_object )
      end
      @cascade_controller.unregister_parent( parent_array )
      parent_array.unregister_child( self )
    end
    
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
  # @param [Array::Compositing] parent_array
  #
  #        Existing instance from which instance is inheriting elements.
  #
  # @param [Array::Compositing] parent_array
  #
  #        New instance from which instance will inherit elements instead.
  #
  # @return [Array::Compositing] 
  #
  #         Self.
  #
  def replace_parent( parent_array, new_parent_array  )
    
    unregister_parent( parent_array )    
    register_parent( new_parent_array )
    
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

  ################
  #  is_parent?  #
  ################
  
  ###
  # Query whether instance has instance as a parent instance from which it inherits elements.
  #
  # @params [Array::Compositing] potential_parent_array
  # 
  #         Instance being queried.
  # 
  # @return [true,false] 
  #
  #         Whether potential_parent_array is a parent of instance.
  #
  def is_parent?( potential_parent_array )
    
    is_parent = false
    
    @parents.each do |this_parent|
      break if is_parent = this_parent.equal?( potential_parent_array )     or 
               is_parent = this_parent.is_parent?( potential_parent_array )
    end
    
    return is_parent
    
  end

  ##########################
  #  is_immediate_parent?  #
  ##########################
  
  ###
  # Query whether instance has instance as a first-level parent instance from which it inherits elements.
  #
  # @params [Array::Compositing] potential_parent_array
  # 
  #         Instance being queried.
  # 
  # @return [true,false] 
  #
  #         Whether potential_parent_array is a parent of instance.
  #
  def is_immediate_parent?( potential_parent_array )
    
    return @parents.include?( potential_parent_array )
    
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
  # @param [Array::Compositing] parent_array 
  #
  #        Instance that initiated set or insert.
  #
  # @param [Array::Compositing] parent_array 
  #
  #        Instance that initiated set or insert.
  #
  # @return [true,false] 
  #
  #         Return value is used in place of object.
  #
  def child_pre_set_hook( index, object, is_insert = false, parent_array = nil )

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
  # @param [Array::Compositing] parent_array 
  #
  #        Instance that initiated set or insert.
  #
  # @return [Object] Ignored.
  #
  def child_post_set_hook( index, object, is_insert = false, parent_array = nil )
    
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
  # @param [Array::Compositing] parent_array 
  #
  #        Instance that initiated delete.
  #
  # @return [true,false] 
  #
  #         If return value is false, delete does not occur.
  #
  def child_pre_delete_hook( index, parent_array = nil )
    
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
  # @param [Array::Compositing] parent_array 
  #
  #        Instance that initiated delete.
  #
  # @return [Object] 
  #
  #         Object returned in place of delete result.
  #
  def child_post_delete_hook( index, object, parent_array = nil )
    
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

  ##########
  #  to_a  #
  ##########
  
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

  #############
  #  collect  #
  #############
  
  ###
  # Invokes block once for each element of self. Creates a new array containing the values 
  #   returned by the block. See also Enumerable#collect.
  #   If no block is given, an enumerator is returned instead.
  #
  def collect( & block )
    
    load_parent_state
    
    return super

  end

  #################
  #  combination  #
  #################
  
  ###
  # When invoked with a block, yields all combinations of length n of elements from ary and 
  #   then returns ary itself. The implementation makes no guarantees about the order in 
  #   which the combinations are yielded.
  #   If no block is given, an enumerator is returned instead.
  #
  def combination( number, & block )

    load_parent_state
    
    return super

  end

  #############
  #  compact  #
  #############
  
  ###
  # Returns a copy of self with all nil elements removed.
  #
  def compact

    load_parent_state
    
    return super

  end

  ##########
  #  drop  #
  ##########
  
  ###
  # Drops first n elements from ary and returns the rest of the elements in an array.
  #
  def drop( number )

    load_parent_state
    
    return super

  end
  
  ################
  #  drop_while  #
  ################
  
  ###
  # Drops elements up to, but not including, the first element for which the block returns 
  #   nil or false and returns an array containing the remaining elements.
  #   If no block is given, an enumerator is returned instead.
  #
  def drop_while( & block )

    load_parent_state
    
    return super

  end

  ##############
  #  include?  #
  ##############

  def include?( object )

    includes = false
    
    each { |this_member| break if includes = ( this_member.equal?( object ) or this_member == object ) }

    return includes
    
  end

  #############
  #  flatten  #
  #############
  
  ###
  # Returns a new array that is a one-dimensional flattening of this array (recursively). That is, 
  #   for every element that is an array, extract its elements into the new array. 
  #   If the optional level argument determines the level of recursion to flatten.
  #
  def flatten( level = 1 )

    load_parent_state
    
    return super

  end

  #############
  #  product  #
  #############
  
  ###
  # Returns an array of all combinations of elements from all arrays. The length of the 
  #   returned array is the product of the length of self and the argument arrays. 
  #   If given a block, product will yield all combinations and return self instead.
  #
  def product( *other_arrays, & block )

    load_parent_state
    
    return super

  end

  ############
  #  reject  #
  ############
  
  ###
  # Returns a new array containing the items in self for which the block is not true. 
  #   See also Array#delete_if
  #   If no block is given, an enumerator is returned instead.
  #
  def reject( & block )

    load_parent_state
    
    return super

  end
  
  #############
  #  reverse  #
  #############
  
  ###
  # Returns a new array containing self‘s elements in reverse order.
  #
  def reverse

    load_parent_state
    
    return super

  end
  
  ############
  #  rotate  #
  ############
  
  ###
  # Returns new array by rotating self so that the element at cnt in self is the first element of the 
  #   new array. If cnt is negative then it rotates in the opposite direction.
  #
  def rotate( rotate_count = 1 )
    
    load_parent_state
    
    return super
    
  end

  ############
  #  select  #
  ############
  
  ###
  # Invokes the block passing in successive elements from self, returning an array containing those 
  #   elements for which the block returns a true value (equivalent to Enumerable#select).
  #   If no block is given, an enumerator is returned instead.
  #
  def select( & block )

    load_parent_state
    
    return super

  end
  
  #############
  #  shuffle  #
  #############
  
  ###
  # Returns a new array with elements of this array shuffled.
  #   If rng is given, it will be used as the random number generator.
  #
  def shuffle( random_number_generator = nil )

    load_parent_state
    
    return super
  
  end
  
  ###########
  #  slice  #
  ###########
  
  ###
  # Element Reference—Returns the element at index, or returns a subarray starting at start and 
  #   continuing for length elements, or returns a subarray specified by range. Negative indices 
  #   count backward from the end of the array (-1 is the last element). Returns nil if the index 
  #   (or starting index) are out of range.
  #
  def slice( index_start_or_range, slice_length = nil )

    load_parent_state
    
    return super

  end
  
  ##########
  #  sort  #
  ##########
  
  ###
  # Returns a new array created by sorting self. Comparisons for the sort will be done using 
  #   the <=> operator or using an optional code block. The block implements a comparison between 
  #   a and b, returning -1, 0, or +1. See also Enumerable#sort_by.
  #
  def sort( & block )

    load_parent_state
    
    return super
  
  end
  
  #############
  #  sort_by  #
  #############

  ###
  # Returns a new array created by using a set of keys generated by mapping the values in self through 
  #   the given block.
  #   If no block is given, an enumerator is returned instead.
  #
  def sort_by( & block )

    load_parent_state
    
    return super

  end
  
  ################
  #  take_while  #
  ################
  
  ###
  # Passes elements to the block until the block returns nil or false, then stops iterating 
  #   and returns an array of all prior elements.
  #   If no block is given, an enumerator is returned instead.
  #
  def take_while( & block )
  
    load_parent_state
    
    return super

  end
  
  ###############
  #  transpose  #
  ###############
  
  ###
  # Assumes that self is an array of arrays and transposes the rows and columns.
  #
  def transpose
  
    load_parent_state
    
    return super

  end
  
  ##########
  #  uniq  #
  ##########
  
  ###
  # Returns a new array by removing duplicate values in self. If a block is given, it will use the 
  #   return value of the block for comparison.
  #
  def uniq( & block )
  
    load_parent_state
    
    return super

  end
  
  ###############
  #  values_at  #
  ###############
  
  ###
  # Returns an array containing the elements in self corresponding to the given selector(s). 
  #   The selectors may be either integer indices or ranges. See also Array#select.
  #
  def values_at( *selectors )
  
    load_parent_state
    
    return super

  end
  
  #########
  #  zip  #
  #########
  
  ###
  # Converts any arguments to arrays, then merges elements of self with corresponding elements 
  #   from each argument. This generates a sequence of self.size n-element arrays, where n is 
  #   one more that the count of arguments. If the size of any argument is less than enumObj.size, 
  #   nil values are supplied. If a block is given, it is invoked for each output array, otherwise 
  #   an array of arrays is returned.
  #
  def zip( *other_arrays, & block )

    load_parent_state
    
    return super
  
  end
  
  ########
  #  []  #
  ########

  def []( local_index )

    return @cascade_controller.requires_lookup?( local_index ) ? lazy_set_parent_element_in_self( local_index ) 
                                                               : super

  end

  #########
  #  []=  #
  #########

  def []=( local_index, object )
    
    super

    @children.each { |this_array| this_array.update_for_parent_set( self, local_index, object ) }

    return object

  end

  ###########
  #  store  #
  ###########
  
  alias_method :store, :[]=

  ###########
  #  sort!  #
  ###########

  ###
  # Sorts self. Comparisons for the sort will be done using the <=> operator or using an optional 
  #   code block. The block implements a comparison between a and b, returning -1, 0, or +1. 
  #   See also Enumerable#sort_by.
  #
  def sort!( & block )
    
    block ||= @sort_order_reversed ? ::Array::ReverseSortBlock
                                   : ::Array::SortBlock
    
    new_local_sort_order = [ ]
    @internal_array.size.times { |this_time| new_local_sort_order.push( this_time ) }
    new_local_sort_order.sort! do |index_one, index_two| 
      block.call( @internal_array[ index_one ], @internal_array[ index_two ] )
    end

    reorder_from_sort( new_local_sort_order )
    
    return self

  end
  
  ##############
  #  sort_by!  #
  ##############

  ###
  # Sorts self in place using a set of keys generated by mapping the values in self through 
  #   the given block.
  #   If no block is given, an enumerator is returned instead.
  #
  def sort_by!( & block )

    return to_enum unless block_given?

    new_local_sort_order = [ ]
    @internal_array.size.times { |this_time| new_local_sort_order.push( this_time ) }
    new_local_sort_order.sort_by! { |this_index| block.call( @internal_array[ this_index ] ) }

    reorder_from_sort( new_local_sort_order )

    return self

  end
  
  #######################
  #  reorder_from_sort  #
  #######################
  
  def reorder_from_sort( new_local_sort_order )

    @cascade_controller.local_sort( new_local_sort_order )

    existing_data = @internal_array
    @internal_array = [ ]
    new_local_sort_order.each_with_index do |this_existing_index, this_new_index|
      @internal_array[ this_new_index ] = existing_data[ this_existing_index ]
    end

    @children.each { |this_array| this_array.update_for_parent_sort( self, new_local_sort_order ) }
    
    return self
    
  end

  ###############
  #  delete_at  #
  ###############

  def delete_at( local_index )
    
    @cascade_controller.local_delete_at( local_index )
    deleted_object = non_cascading_delete_at( local_index )
    @children.each { |this_array| this_array.update_for_parent_delete_at( self, local_index, deleted_object ) }

    return deleted_object

  end

  ##############
  #  shuffle!  #
  ##############
  
  def shuffle!( random_number_generator = nil )
    
    # We can't simply shuffle the internal array (like Array::Hooked) because the index maps will be corrupted. 
    # We can declare elements have moved, but to do so we need to know where they moved.
    # To achieve this, we shuffle an array of our indexes and then use the result to track shuffled elements.
    shuffled_index_order = @cascade_controller.local_shuffle( random: random_number_generator )
    
    existing_data = @internal_array
    @internal_array = [ ]
    shuffled_index_order.each_with_index do |this_new_index, this_existing_index|
      @internal_array[ this_new_index ] = existing_data[ this_existing_index ]
    end
    
    @children.each { |this_array| this_array.update_for_parent_reorder( self, shuffled_index_order ) }
    
    return self
    
  end
  
  #############
  #  reorder  #
  #############
  
  def reorder( new_local_index_order )
    
    @cascade_controller.local_reorder( new_local_index_order )

    existing_data = @internal_array
    @internal_array = [ ]
    new_local_index_order.each_with_index do |this_new_index, this_existing_index|
      @internal_array[ this_new_index ] = existing_data[ this_existing_index ]
    end

    @children.each { |this_array| this_array.update_for_parent_reorder( self, new_local_index_order ) }
    
    return self
    
  end
  
  ##########
  #  move  #
  ##########
  
  def move( index, new_index )
    
    # if we have less elements in self than the index we are inserting at
    # we need to make sure the nils inserted cascade
    
    elements = size
    
    if index > elements or -index > elements

      if new_index > elements
        nils_created = new_index - elements + 1
        nils_created.times { |this_time| push( nil ) }
      elsif -new_index > elements
        nils_created = -new_index - elements + 1
        nils_created.times { |this_time| unshift( nil ) }
      end

      insert( new_index, nil )

    else

      if new_index > elements
        nils_created = new_index - elements + 1
        nils_created.times { |this_time| push( nil ) }
      elsif -new_index > elements
        nils_created = -new_index - elements + 1
        nils_created.times { |this_time| unshift( nil ) }
        index += nils_created
        new_index -= 1
      end

      object = @internal_array.delete_at( index )

      @cascade_controller.local_move( index, new_index )
      @internal_array.insert( new_index, object )
      @children.each { |this_child| this_child.update_for_parent_move( self, index, new_index ) }

    end
    
    
    return self
    
  end

  ##########
  #  swap  #
  ##########
  
  def swap( index_one, index_two )
    
    elements = size
    
    if index_one > elements or -index_one > elements

      if index_two > elements
        nils_created = index_two - elements + 1
        nils_created.times { |this_time| push( nil ) }
      elsif -index_two > elements
        nils_created = -index_two - elements + 1
        nils_created.times { |this_time| unshift( nil ) }
      end

      insert( index_two, nil )

    else

      if index_two > elements
        nils_created = index_two - elements + 1
        nils_created.times { |this_time| push( nil ) }
      elsif -index_two > elements
        nils_created = -index_two - elements
        nils_created.times { |this_time| unshift( nil ) }
        index_one += nils_created
      end
    
      @cascade_controller.local_swap( index_one, index_two )
    
      index_two_object = @internal_array[ index_two ]
      @internal_array[ index_two ] = @internal_array[ index_one ]
      @internal_array[ index_one ] = index_two_object
    
      @children.each { |this_child| this_child.update_for_parent_swap( self, index_one, index_two ) }
    
    end
    
    return self
    
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
  def freeze!( parent_array = nil )
    
    # look up all values
    load_parent_state( parent_array )
    
    if parent_array
      
      parent_array.unregister_child( self )
      
    else
      
      # unregister with parent composite so we don't get future updates from it
      @parents.each { |this_parent_array| this_parent_array.unregister_child( self ) }
      
    end
    
    return self

  end

  #######################
  #  load_parent_state  #
  #######################

  ###
  # Load all elements not yet inherited from parent or parents (but marked to be inherited).
  #
  # @param [Array::Compositing] parent_array
  #
  #        Load state only from parent instance if specified.
  #        Otherwise all parent's state will be loaded.
  #
  # @return [Array::Compositing]
  #
  #         Self.
  #
  def load_parent_state( parent_array = nil )

    #
    # We have to check for @cascade_controller.
    #
    # This is because of cases where duplicate instance is created (like #uniq) 
    # and initialization not called during dup process.
    #
    @cascade_controller.each_index_requiring_lookup( parent_array ) do |this_local_index|
      lazy_set_parent_element_in_self( this_local_index )
    end if @cascade_controller

    return self
    
  end

  ###############################
  #  perform_set_between_hooks  #
  ###############################

  def perform_set_between_hooks( local_index, object )
    
    did_set = false
    
    if did_set = super
      @cascade_controller.local_set( local_index )
    end
    
    return did_set
    
  end
  
  ################################################
  #  perform_single_object_insert_between_hooks  #
  ################################################
  
  def perform_single_object_insert_between_hooks( requested_local_index, object )

    if local_index = super
      @cascade_controller.local_insert( local_index, 1 )
      @children.each do |this_array|
        this_array.update_for_parent_insert( self, requested_local_index, local_index, object )
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
  # @param [Integer] local_index
  # 
  #        Index in instance for which value requires look-up/set.
  # 
  # @param [Object] optional_object
  # 
  #        If we deleted in parent and then child delete hook prevented local delete
  #        then we have an object passed since our parent can no longer provide it
  #
  # @return [Object]
  #
  #         Lazy set value.
  #
  def lazy_set_parent_element_in_self( local_index, optional_object = nil, passed_optional_object = false )

    object = nil
    if @cascade_controller.requires_lookup?( local_index )

      parent_array = @cascade_controller.parent_array( local_index )
      parent_index = @cascade_controller.parent_index( local_index, parent_array )

      object = passed_optional_object ? optional_object : parent_array[ parent_index ]
        
      # We call hooks manually so that we can do a direct undecorated set.
      # This is because we already have an object we loaded as a place-holder that we are now updating.
      # So we don't want to sort/test uniqueness/etc. We just want to insert at the actual index.

      unless @without_child_hooks
        object = child_pre_set_hook( local_index, object, false, parent_array )
        if ::Array::Compositing::DoNotInherit === object
          delete_at( local_index )
          return lazy_set_parent_element_in_self( local_index, optional_object, passed_optional_object )
        end
      end
    
      object = pre_set_hook( local_index, object, false, 1 ) unless @without_hooks

      undecorated_set( local_index, object )

      @cascade_controller.looked_up!( local_index )
      
      post_set_hook( local_index, object, false ) unless @without_hooks
      child_post_set_hook( local_index, object, false, parent_array ) unless @without_child_hooks

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
  # @param [Array::Compositing] parent_array
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
  def update_for_parent_set( parent_array, parent_index, object )
    
    parent_local_map = @cascade_controller.parent_local_map( parent_array )
    
    if @cascade_controller.parent_controls_parent_index?( parent_array, parent_index, parent_local_map ) or
       parent_index >= parent_local_map.size
      local_index = @cascade_controller.parent_set( parent_array, parent_index )
      undecorated_set( local_index, nil )
      @children.each { |this_array| this_array.update_for_parent_set( local_index, object ) }
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
  # @param [Array::Compositing] parent_array
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
  def update_for_parent_insert( parent_array, requested_parent_index, parent_index, object )

    local_index = @cascade_controller.parent_insert( parent_array, parent_index, 1 )
    undecorated_insert( local_index, nil )
    @children.each { |this_array| this_array.update_for_parent_insert( self, local_index, local_index, object ) }

    return self
    
  end

  #################################
  #  update_for_parent_delete_at  #
  #################################

  ###
  # Perform #set in self inherited from #delete_at requested on parent (or parent of parent).
  #
  # @param [Array::Compositing] parent_array
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
  def update_for_parent_delete_at( parent_array, parent_index, object )

    did_delete = false

    if @cascade_controller.parent_controls_parent_index?( parent_array, parent_index )

      local_index = @cascade_controller.local_index( parent_array, parent_index )
      
      if @without_child_hooks || child_pre_delete_hook( local_index, parent_array )

        @cascade_controller.parent_delete_at( parent_array, parent_index )

        # I'm unclear why if we call perform_delete_between_hooks (including through non_cascading_delete_at)
        # we end up smashing the last index's lazy lookup value, turning it false
        # for now simply adding hooks manually here works; the only loss is a little duplicate code
        # to call the local (non-child) hooks
        if @without_hooks || pre_delete_hook( local_index )
          did_delete = true
          object = undecorated_delete_at( local_index )
          object = post_delete_hook( local_index, object ) unless @without_hooks
          child_post_delete_hook( local_index, object, parent_array ) unless @without_child_hooks
          @children.each { |this_array| this_array.update_for_parent_delete_at( self, local_index, object ) }
        end
        
      else

        if @cascade_controller.requires_lookup?( local_index )
          lazy_set_parent_element_in_self( local_index, object, true )
        end
        
      end
    
    end

    return did_delete
    
  end

  ###############################
  #  update_for_parent_reorder  #
  ###############################
  
  def update_for_parent_reorder( parent_array, new_parent_index_order_array )

    new_local_index_order = @cascade_controller.parent_reorder( parent_array, new_parent_index_order_array )
    
    existing_data = @internal_array
    @internal_array = [ ]
    new_local_index_order.each_with_index do |this_new_local_index, this_existing_local_index|
      @internal_array[ this_new_local_index ] = existing_data[ this_existing_local_index ]
    end

    @children.each { |this_array| this_array.update_for_parent_reorder( self, new_local_index_order ) }

    return self

  end

  ############################
  #  update_for_parent_sort  #
  ############################
  
  def update_for_parent_sort( parent_array, new_parent_sort_order )
    
    new_local_index_order = @cascade_controller.parent_sort( parent_array, new_parent_sort_order )
    
    existing_data = @internal_array
    @internal_array = [ ]
    new_local_index_order.each_with_index do |this_new_local_index, this_existing_local_index|
      @internal_array[ this_new_local_index ] = existing_data[ this_existing_local_index ]
    end

    @children.each { |this_array| this_array.update_for_parent_sort( self, new_local_index_order ) }

    return self
    
  end

  ############################
  #  update_for_parent_move  #
  ############################

  def update_for_parent_move( parent_array, existing_parent_index, new_parent_index )

    existing_local_index = @cascade_controller.local_index( parent_array, existing_parent_index )
    new_local_index = @cascade_controller.parent_move( parent_array, existing_parent_index, new_parent_index )
    @internal_array.insert( new_local_index, @internal_array.delete_at( existing_local_index ) )
    @children.each { |this_child| this_child.update_for_parent_move( self, index, new_index ) }

    return self

  end

  ############################
  #  update_for_parent_swap  #
  ############################

  def update_for_parent_swap( parent_array, index, new_index )
    
    return self
    
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
