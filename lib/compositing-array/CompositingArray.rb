
class ::CompositingArray < ::Array

  attr_reader :parent_composite_array

  ################
  #  initialize  #
  ################

  def initialize( parent_composite_array = nil )

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

    if @parent_composite_array = parent_composite_array

      # initialize contents of self from parent contents
      push( *@parent_composite_array )

      @parent_composite_array.count.times do |this_time|
        @local_index_for_parent_index[ this_time ] = this_time
      end

      @parent_composite_array.register_sub_composite_array( self )

      # since we have a super array we have to note how many objects it has before we insert any
      @parent_and_interpolated_object_count = @parent_composite_array.count

    end
    
  end

  ###################################  Sub-Array Management  #######################################

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

  #####################################  Self Management  ##########################################

  #########
  #  []=  #
  #########

  private
    alias_method :non_cascading_set, :[]=
  public

  def []=( index, object )

    # we are either replacing or adding at the end
    # if we are replacing we are either replacing a parent element or an element in self
    # * if replacing parent element, track and exclude parent changes

    non_cascading_set( index, object )

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

  private
    alias_method :non_cascading_insert, :insert
  public

  def insert( index, *objects )

    # if we have less elements in self than the index we are inserting at
    # we need to make sure the nils inserted cascade
    if index > count
      nils_created = index - count
      index -= nils_created
      nils = [ ]
      nils_created.times do |this_time|
        nils.push( nil )
      end
      objects = nils.concat( objects )
    end

    non_cascading_insert( index, *objects )

    if index_inside_parent_objects?( index )
      update_corresponding_index_for_local_change( index, objects.count )
    end

    @sub_composite_arrays.each do |this_sub_array|
      this_sub_array.instance_eval do
        update_as_sub_array_for_parent_insert( index, *objects )
      end
    end

    return self

  end

  ##########
  #  push  #
  ##########

  def push( *objects )

    insert( count, *objects )

    return self

  end
  alias_method :<<, :push

  ############
  #  concat  #
  ############

  def concat( *arrays )

    arrays.each do |this_array|
      push( *this_array )
    end

    return self

  end
  alias_method :+, :concat

  ############
  #  delete  #
  ############

  def delete( object )

    return_value = nil

    if index = index( object )
      return_value = delete_at( index )
    end

    return return_value

  end

  ####################
  #  delete_objects  #
  ####################

  def delete_objects( *objects )

    return_value = nil

    indexes = [ ]
    objects.each do |this_object|
      this_index = index( this_object )
      if this_index
        indexes.push( this_index )
      end
    end

    unless indexes.empty?
      return_value = delete_at_indexes( *indexes )
    end

    return return_value

  end

  #######
  #  -  #
  #######

  def -( *arrays )

    arrays.each do |this_array|
      delete_objects( *this_array )
    end

    return self

  end

  ###############
  #  delete_at  #
  ###############

  private
    alias_method :non_cascading_delete_at, :delete_at
  public

  def delete_at( index )

    deleted_object = non_cascading_delete_at( index )

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

  #######################
  #  delete_at_indexes  #
  #######################

  def delete_at_indexes( *indexes )

    indexes = indexes.sort.uniq.reverse

    objects = [ ]

    indexes.each do |this_index|
      objects.push( delete_at( this_index ) )
    end

    return objects

  end

  ###############
  #  delete_if  #
  ###############

  def delete_if

    return to_enum unless block_given?

    indexes = [ ]

    self.each_with_index do |this_object, index|
      if yield( this_object )
        indexes.push( index )
      end
    end

    delete_at_indexes( *indexes )

    return self

  end

  #############
  #  keep_if  #
  #############

  def keep_if

    indexes = [ ]

    self.each_with_index do |this_object, index|
      unless yield( this_object )
        indexes.push( index )
      end
    end

    delete_at_indexes( *indexes )

    return self

  end

  ##############
  #  compact!  #
  ##############

  def compact!

    return keep_if do |object|
      object != nil
    end

  end

  ##############
  #  flatten!  #
  ##############

  def flatten!

    return_value = nil

    indexes = [ ]

    self.each_with_index do |this_object, index|
      if this_object.is_a?( Array )
        indexes.push( index )
      end
    end

    unless indexes.empty?
      indexes.sort!.reverse!
      indexes.each do |this_index|
        this_array = delete_at( this_index )
        insert( this_index, *this_array )
      end
      return_value = self
    end

    return return_value

  end

  #############
  #  reject!  #
  #############

  def reject!

    return to_enum unless block_given?

    return_value = nil

    deleted_objects = 0

    iteration_dup = dup
    iteration_dup.each_with_index do |this_object, index|
      if yield( this_object )
        delete_at( index - deleted_objects )
        deleted_objects += 1
      end
    end

    if deleted_objects > 0
      return_value = self
    end

    return return_value

  end

  #############
  #  replace  #
  #############

  def replace( other_array )

    clear

    other_array.each_with_index do |this_object, index|
      unless self[ index ] == this_object
        self[ index ] = this_object
      end
    end

    return self

  end

  ##############
  #  reverse!  #
  ##############

  def reverse!

    reversed_array = reverse

    clear

    reversed_array.each_with_index do |this_object, index|
      self[ index ] = this_object
    end

    return self

  end

  #############
  #  rotate!  #
  #############

  def rotate!( rotate_count = 1 )

    reversed_array = rotate( rotate_count )

    clear

    reversed_array.each_with_index do |this_object, index|
      self[ index ] = this_object
    end

    return self

  end

  #############
  #  select!  #
  #############

  def select!

    return to_enum unless block_given?

    deleted_objects = 0

    iteration_dup = dup
    iteration_dup.each_with_index do |this_object, index|
      unless yield( this_object )
        delete_at( index - deleted_objects )
        deleted_objects += 1
      end
    end

    return self

  end

  ##############
  #  shuffle!  #
  ##############

  def shuffle!( random_number_generator = nil )

    shuffled_array = shuffle( random: random_number_generator )

    clear

    shuffled_array.each_with_index do |this_object, index|
      self[ index ] = this_object
    end

    return self

  end

  ##############
  #  collect!  #
  #  map!      #
  ##############

  def collect!

    return to_enum unless block_given?

    self.each_with_index do |this_object, index|
      replacement_object = yield( this_object )
      self[ index ] = replacement_object
    end

    return self

  end
  alias_method :map!, :collect!

  ###########
  #  sort!  #
  ###########

  def sort!( & block )

    sorted_array = sort( & block )

    unless sorted_array == self

      replace( sorted_array )

    end

    return self

  end

  ##############
  #  sort_by!  #
  ##############

  def sort_by!( & block )

    return to_enum unless block_given?

    sorted_array = sort_by( & block )

    unless sorted_array == self

      replace( sorted_array )

    end

    return self

  end

  ###########
  #  uniq!  #
  ###########

  def uniq!

    return_value = nil

    uniq_array = uniq

    unless uniq_array == self

      clear

      replace( uniq_array )

    end

    return return_value

  end

  #############
  #  unshift  #
  #############

  def unshift( object )

    insert( 0, object )

  end

  #########
  #  pop  #
  #########

  def pop

    object = delete_at( count - 1 )

    return object

  end

  ###########
  #  shift  #
  ###########

  def shift

    object = delete_at( 0 )

    return object

  end

  ############
  #  slice!  #
  ############

  def slice!( index_start_or_range, length = nil )

    slice = nil

    start_index = nil
    end_index = nil

    if index_start_or_range.is_a?( Range )

      start_index = index_start_or_range.begin
      end_index = index_start_or_range.end

    elsif length

      start_index = index_start_or_range
      end_index = index_start_or_range + length

    end

    if end_index

      indexes = [ ]

      ( end_index - start_index ).times do |this_time|
        indexes.push( end_index - this_time - 1 )
      end

      slice = delete_at_indexes( *indexes )

    else

      slice = delete_at( start_index )

    end


    return slice

  end

  ###########
  #  clear  #
  ###########

  def clear

    indexes = [ ]

    count.times do |this_time|
      indexes.push( count - this_time - 1 )
    end

    delete_at_indexes( *indexes )

    return self

  end

  #############
  #  freeze!  #
  #############

  # freezes configuration and prevents ancestors from changing this configuration in the future
  def freeze!

    # unregister with parent composite so we don't get future updates from it
    if @parent_composite_array
      @parent_composite_array.unregister_sub_composite_array( self )
    end

    return self

  end

  ##################################################################################################
      private ######################################################################################
  ##################################################################################################

	################  Self Management for Inserts between Parent-Provided Elements  ##################

  ###################################
  #  index_inside_parent_objects?  #
  ###################################

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

    non_cascading_set( corresponding_index, object )

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

    non_cascading_insert( corresponding_index, *objects )

  end

  ###########################################
  #  update_as_sub_array_for_parent_delete  #
  ###########################################

  def update_as_sub_array_for_parent_delete( index )

    corresponding_index = @local_index_for_parent_index[ index ]

    object = non_cascading_delete_at( corresponding_index )

    @parent_and_interpolated_object_count -= 1

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
        stepped_indices[ new_index ] = @local_index_for_parent_index.delete( this_parent_index ) + step_value
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
