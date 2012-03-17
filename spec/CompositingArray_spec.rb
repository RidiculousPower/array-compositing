
if $__compositing_array__spec__development
  require_relative '../lib/compositing-array.rb'
else
  require 'compositing-array'
end

describe ::CompositingArray do

  ################
  #  initialize  #
  ################

  it 'can add initialize with an ancestor, inheriting its values and linking to it as a child' do
  
    cascading_composite_array = ::CompositingArray.new

    cascading_composite_array.instance_variable_get( :@parent_composite_array ).should == nil
    cascading_composite_array.should == [ ]
    cascading_composite_array.push( :A, :B, :C, :D )
    
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )
    sub_cascading_composite_array.instance_variable_get( :@parent_composite_array ).should == cascading_composite_array
    sub_cascading_composite_array.should == [ :A, :B, :C, :D ]

  end

  ##################################################################################################
  #    private #####################################################################################
  ##################################################################################################

  ##################################################
  #  update_corresponding_index_for_parent_change  #
  ##################################################

  it 'can update tracked parent indices for parent insert/delete' do

    cascading_composite_array = ::CompositingArray.new
    cascading_composite_array.push( :A, :B )
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )
    
    sub_cascading_composite_array.instance_eval do
      @local_index_for_parent_index[ 0 ].should == 0
      @local_index_for_parent_index[ 1 ].should == 1
      @local_index_for_parent_index[ 2 ].should == nil
      # insert 1 in parent before parent-1
      update_corresponding_index_for_parent_change( 1, 1 )
      @local_index_for_parent_index[ 0 ].should == 0
      # no longer a parent-1 index (has to be set separately)
      @local_index_for_parent_index[ 1 ].should == nil
      # parent-1 is now parent-2
      @local_index_for_parent_index[ 2 ].should == 2
      @parent_and_interpolated_object_count.should == 3
    end
  
  end

  #################################################
  #  update_corresponding_index_for_local_change  #
  #################################################

  it 'can update tracked parent indices for local insert/delete' do

    cascading_composite_array = ::CompositingArray.new
    cascading_composite_array.push( :A, :B )
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )
    
    sub_cascading_composite_array.instance_eval do
      @local_index_for_parent_index[ 0 ].should == 0
      @local_index_for_parent_index[ 1 ].should == 1
      @local_index_for_parent_index[ 2 ].should == nil
      # insert 1 before parent-1
      update_corresponding_index_for_local_change( 1, 1 )
      @local_index_for_parent_index[ 0 ].should == 0
      # new index for parent-1 is 2
      @local_index_for_parent_index[ 1 ].should == 2
      @local_index_for_parent_index[ 2 ].should == nil
      @parent_and_interpolated_object_count.should == 3
    end
    
  end

  ###########################################
  #  update_as_sub_array_for_parent_insert  #
  ###########################################

  it 'can handle updating itself as a sub-array when told an insert has occurred in parent' do

    cascading_composite_array = ::CompositingArray.new
    cascading_composite_array.push( :A, :B )
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )
    
    sub_cascading_composite_array.instance_eval do
      @local_index_for_parent_index[ 0 ].should == 0
      @local_index_for_parent_index[ 1 ].should == 1
      @local_index_for_parent_index[ 2 ].should == nil
      # insert 1 before parent-1
      update_as_sub_array_for_parent_insert( 1, :C )
      @local_index_for_parent_index[ 0 ].should == 0
      # new parent index parent-1 inserted for :C
      @local_index_for_parent_index[ 1 ].should == 1
      # new index for parent-1 is parent-2
      @local_index_for_parent_index[ 2 ].should == 2
      @parent_and_interpolated_object_count.should == 3
    end
    
  end

  ########################################
  #  update_as_sub_array_for_parent_set  #
  ########################################

  it 'can handle updating itself as a sub-array when told a set has occurred in parent' do
    
    cascading_composite_array = ::CompositingArray.new
    cascading_composite_array.push( :A, :B )
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )
    
    sub_cascading_composite_array.instance_eval do
      @local_index_for_parent_index[ 0 ].should == 0
      @local_index_for_parent_index[ 1 ].should == 1
      @local_index_for_parent_index[ 2 ].should == nil
      # set for parent-1
      update_as_sub_array_for_parent_set( 1, :C )
      @local_index_for_parent_index[ 0 ].should == 0
      @local_index_for_parent_index[ 1 ].should == 1
      @local_index_for_parent_index[ 2 ].should == nil
      @parent_and_interpolated_object_count.should == 2
    end
    
  end

  ###########################################
  #  update_as_sub_array_for_parent_delete  #
  ###########################################

  it 'can handle updating itself as a sub-array when told a delete has occurred in parent' do
    
    cascading_composite_array = ::CompositingArray.new
    cascading_composite_array.push( :A, :B )
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )
    
    sub_cascading_composite_array.instance_eval do
      @local_index_for_parent_index[ 0 ].should == 0
      @local_index_for_parent_index[ 1 ].should == 1
      @local_index_for_parent_index[ 2 ].should == nil
      # delete parent-1
      update_as_sub_array_for_parent_delete( 1 )
      @local_index_for_parent_index[ 0 ].should == 0
      @local_index_for_parent_index[ 1 ].should == 1
      @local_index_for_parent_index[ 2 ].should == nil
      @parent_and_interpolated_object_count.should == 1
    end
    
  end
  
  ##################################################################################################
  #    public ######################################################################################
  ##################################################################################################
  
  #########
  #  []=  #
  #########

  it 'can add elements' do
  
    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array[ 0 ] = :A
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array[ 1 ] = :B
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :A, :B ]

    sub_cascading_composite_array[ 0 ] = :C
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :C, :B ]

    sub_cascading_composite_array[ 0 ] = :B
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :B, :B ]

    sub_cascading_composite_array[ 2 ] = :C
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :B, :B, :C ]

    cascading_composite_array[ 0 ] = :D
    cascading_composite_array.should == [ :D, :B ]
    sub_cascading_composite_array.should == [ :B, :B, :C ]

  end
  
  ############
  #  insert  #
  ############

  it 'can insert elements' do
  
    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.insert( 3, :D )
    cascading_composite_array.should == [ nil, nil, nil, :D ]
    sub_cascading_composite_array.should == [ nil, nil, nil, :D ]

    cascading_composite_array.insert( 1, :B )
    cascading_composite_array.should == [ nil, :B, nil, nil, :D ]
    sub_cascading_composite_array.should == [ nil, :B, nil, nil, :D ]

    cascading_composite_array.insert( 2, :C )
    cascading_composite_array.should == [ nil, :B, :C, nil, nil, :D ]
    sub_cascading_composite_array.should == [ nil, :B, :C, nil, nil, :D ]

    sub_cascading_composite_array.insert( 0, :E )
    cascading_composite_array.should == [ nil, :B, :C, nil, nil, :D ]
    sub_cascading_composite_array.should == [ :E, nil, :B, :C, nil, nil, :D ]

    sub_cascading_composite_array.insert( 4, :F )
    cascading_composite_array.should == [ nil, :B, :C, nil, nil, :D ]
    sub_cascading_composite_array.should == [ :E, nil, :B, :C, :F, nil, nil, :D ]

  end
  
  ##########
  #  push  #
  #  <<    #
  ##########
  
  it 'can add elements' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array << :A
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array << :B
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :A, :B ]

    sub_cascading_composite_array << :C
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

    sub_cascading_composite_array << :B
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :A, :B, :C, :B ]

  end
  
  ############
  #  concat  #
  #  +       #
  ############

  it 'can add elements' do

    # NOTE: this breaks + by causing it to modify the array like +=
    # The alternative was worse.

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.concat( [ :A ] )
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array += [ :B ]
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :A, :B ]

    sub_cascading_composite_array.concat( [ :C ] )
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

    sub_cascading_composite_array += [ :B ]
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :A, :B, :C, :B ]

  end

  ####################
  #  delete_objects  #
  ####################

  it 'can delete multiple elements' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array += [ :A, :B ]
    cascading_composite_array.should == [ :A, :B ]
    sub_cascading_composite_array.should == [ :A, :B ]

    cascading_composite_array.delete_objects( :A, :B )
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ ]

    sub_cascading_composite_array += [ :B, :C, :D ]
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ :B, :C, :D ]
    
    sub_cascading_composite_array.delete_objects( :C, :B )
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ :D ]

  end

  #######
  #  -  #
  #######
  
  it 'can exclude elements' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A )
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array -= [ :A ]
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ ]

    cascading_composite_array.push( :B )
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B ]

    sub_cascading_composite_array.push( :C )
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B, :C ]

    sub_cascading_composite_array -= [ :B ]
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :C ]

  end

  ############
  #  delete  #
  ############
  
  it 'can delete elements' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A )
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array.delete( :A )
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ ]

    cascading_composite_array.push( :B )
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B ]

    sub_cascading_composite_array.push( :C )
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B, :C ]

    sub_cascading_composite_array.delete( :B )
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :C ]

  end

  ###############
  #  delete_at  #
  ###############

  it 'can delete by indexes' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A )
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]
    
    cascading_composite_array.delete_at( 0 )
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ ]

    cascading_composite_array.push( :B )
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B ]

    sub_cascading_composite_array.push( :C )
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B, :C ]

    sub_cascading_composite_array.delete_at( 0 )
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :C ]

  end

  #######################
  #  delete_at_indexes  #
  #######################

  it 'can delete by indexes' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

    cascading_composite_array.delete_at_indexes( 0, 1 )
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C ]

    sub_cascading_composite_array.push( :C, :B )
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C, :C, :B ]

    sub_cascading_composite_array.delete_at_indexes( 0, 1, 2 )
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ ]

  end

  ###############
  #  delete_if  #
  ###############

  it 'can delete by block' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]
    cascading_composite_array.delete_if do |object|
      object != :C
    end
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C ]

    sub_cascading_composite_array.push( :C, :B )
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C, :C, :B ]
    sub_cascading_composite_array.delete_if do |object|
      object != nil
    end
    sub_cascading_composite_array.should == [ ]
    cascading_composite_array.should == [ :C ]

    cascading_composite_array.delete_if.is_a?( Enumerator ).should == true

  end

  #############
  #  keep_if  #
  #############

  it 'can keep by block' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]
    cascading_composite_array.keep_if do |object|
      object == :C
    end
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C ]

    sub_cascading_composite_array.push( :C, :B )
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C, :C, :B ]
    sub_cascading_composite_array.keep_if do |object|
      object == nil
    end
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ ]

  end

  ##############
  #  compact!  #
  ##############

  it 'can compact' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, nil, :B, nil, :C, nil )
    cascading_composite_array.should == [ :A, nil, :B, nil, :C, nil ]
    sub_cascading_composite_array.should == [ :A, nil, :B, nil, :C, nil ]
    cascading_composite_array.compact!
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

    sub_cascading_composite_array.push( nil, nil, :D )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C, nil, nil, :D ]
    sub_cascading_composite_array.compact!
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C, :D ]

  end

  ##############
  #  flatten!  #
  ##############

  it 'can flatten' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, [ :F_A, :F_B ], :B, [ :F_C ], :C, [ :F_D ], [ :F_E ] )
    cascading_composite_array.should == [ :A, [ :F_A, :F_B ], :B, [ :F_C ], :C, [ :F_D ], [ :F_E ] ]
    sub_cascading_composite_array.should == [ :A, [ :F_A, :F_B ], :B, [ :F_C ], :C, [ :F_D ], [ :F_E ] ]
    cascading_composite_array.flatten!
    cascading_composite_array.should == [ :A, :F_A, :F_B, :B, :F_C, :C, :F_D, :F_E ]
    sub_cascading_composite_array.should == [ :A, :F_A, :F_B, :B, :F_C, :C, :F_D, :F_E ]

    sub_cascading_composite_array.push( [ :F_F, :F_G ], :D, [ :F_H ] )
    cascading_composite_array.should == [ :A, :F_A, :F_B, :B, :F_C, :C, :F_D, :F_E ]
    sub_cascading_composite_array.should == [ :A, :F_A, :F_B, :B, :F_C, :C, :F_D, :F_E, [ :F_F, :F_G ], :D, [ :F_H ] ]
    sub_cascading_composite_array.flatten!
    cascading_composite_array.should == [ :A, :F_A, :F_B, :B, :F_C, :C, :F_D, :F_E ]
    sub_cascading_composite_array.should == [ :A, :F_A, :F_B, :B, :F_C, :C, :F_D, :F_E, :F_F, :F_G, :D, :F_H ]

  end

  #############
  #  reject!  #
  #############

  it 'can reject' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]
    cascading_composite_array.reject! do |object|
      object != :C
    end
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C ]

    sub_cascading_composite_array.push( :C, :B )
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C, :C, :B ]
    sub_cascading_composite_array.reject! do |object|
      object != nil
    end
    sub_cascading_composite_array.should == [ ]
    cascading_composite_array.should == [ :C ]

    cascading_composite_array.reject!.is_a?( Enumerator ).should == true

  end

  #############
  #  replace  #
  #############

  it 'can replace self' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]
    cascading_composite_array.replace( [ :D, :E, :F ] )
    cascading_composite_array.should == [ :D, :E, :F ]
    sub_cascading_composite_array.should == [ :D, :E, :F ]

    cascading_composite_array.should == [ :D, :E, :F ]
    sub_cascading_composite_array.should == [ :D, :E, :F ]
    sub_cascading_composite_array.replace( [ :G, :H, :I ] )
    cascading_composite_array.should == [ :D, :E, :F ]
    sub_cascading_composite_array.should == [ :G, :H, :I ]

  end

  ##############
  #  reverse!  #
  ##############

  it 'can reverse self' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]
    cascading_composite_array.reverse!
    cascading_composite_array.should == [ :C, :B, :A ]
    sub_cascading_composite_array.should == [ :C, :B, :A ]

    cascading_composite_array.should == [ :C, :B, :A ]
    sub_cascading_composite_array.should == [ :C, :B, :A ]
    sub_cascading_composite_array.reverse!
    cascading_composite_array.should == [ :C, :B, :A ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

  end

  #############
  #  rotate!  #
  #############

  it 'can rotate self' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

    cascading_composite_array.rotate!
    cascading_composite_array.should == [ :B, :C, :A ]
    sub_cascading_composite_array.should == [ :B, :C, :A ]

    cascading_composite_array.rotate!( -1 )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

    sub_cascading_composite_array.rotate!( 2 )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :C, :A, :B ]

  end

  #############
  #  select!  #
  #############

  it 'can keep by select' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]
    cascading_composite_array.select! do |object|
      object == :C
    end
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C ]

    sub_cascading_composite_array.push( :C, :B )
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ :C, :C, :B ]
    sub_cascading_composite_array.select! do |object|
      object == nil
    end
    cascading_composite_array.should == [ :C ]
    sub_cascading_composite_array.should == [ ]

    cascading_composite_array.select!.is_a?( Enumerator ).should == true

  end

  ##############
  #  shuffle!  #
  ##############

  it 'can shuffle self' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == cascading_composite_array

    prior_version = cascading_composite_array.dup
    attempts = [ ]
    50.times do
      cascading_composite_array.shuffle!
      attempts.push( cascading_composite_array == prior_version )
      prior_version = cascading_composite_array.dup
    end
    attempts_correct = attempts.select { |member| member == false }.count
    ( attempts_correct >= 10 ).should == true
    sub_cascading_composite_array.should == cascading_composite_array
    first_shuffle_version = cascading_composite_array

    cascading_composite_array.should == first_shuffle_version
    attempts = [ ]
    50.times do
      sub_cascading_composite_array.shuffle!
      attempts.push( sub_cascading_composite_array == cascading_composite_array )
      prior_version = cascading_composite_array.dup
    end
    attempts_correct = attempts.select { |member| member == false }.count
    ( attempts_correct >= 10 ).should == true    

  end

  ##############
  #  collect!  #
  #  map!      #
  ##############

  it 'can replace by collect/map' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]
    cascading_composite_array.collect! do |object|
      :C
    end
    cascading_composite_array.should == [ :C, :C, :C ]
    sub_cascading_composite_array.should == [ :C, :C, :C ]

    sub_cascading_composite_array.collect! do |object|
      :A
    end
    cascading_composite_array.should == [ :C, :C, :C ]
    sub_cascading_composite_array.should == [ :A, :A, :A ]

    cascading_composite_array.collect!.is_a?( Enumerator ).should == true

  end

  ###########
  #  sort!  #
  ###########

  it 'can replace by collect/map' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]
    cascading_composite_array.sort! do |a, b|
      if a < b
        1
      elsif a > b
        -1
      elsif a == b
        0
      end
    end
    cascading_composite_array.should == [ :C, :B, :A ]
    sub_cascading_composite_array.should == [ :C, :B, :A ]

    sub_cascading_composite_array.sort! do |a, b|
      if a < b
        -1
      elsif a > b
        1
      elsif a == b
        0
      end
    end
    cascading_composite_array.should == [ :C, :B, :A ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

    cascading_composite_array.sort!
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

  end

  ##############
  #  sort_by!  #
  ##############

  it 'can replace by collect/map' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]
    cascading_composite_array.sort_by! do |object|
      case object
      when :A
        :B
      when :B
        :A
      when :C
        :C
      end
    end
    cascading_composite_array.should == [ :B, :A, :C ]
    sub_cascading_composite_array.should == [ :B, :A, :C ]

    sub_cascading_composite_array.sort_by! do |object|
      case object
      when :A
        :C
      when :B
        :B
      when :C
        :A
      end
    end
    cascading_composite_array.should == [ :B, :A, :C ]
    sub_cascading_composite_array.should == [ :C, :B, :A ]

    cascading_composite_array.sort_by!.is_a?( Enumerator ).should == true

  end

  ###########
  #  uniq!  #
  ###########

  it 'can remove non-unique elements' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array.push( :A, :B, :C, :C, :C, :B, :A )
    cascading_composite_array.should == [ :A, :B, :C, :C, :C, :B, :A ]
    sub_cascading_composite_array.should == [ :A, :B, :C, :C, :C, :B, :A ]
    cascading_composite_array.uniq!
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

    sub_cascading_composite_array.push( :C, :B )
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C, :C, :B ]
    sub_cascading_composite_array.uniq!
    cascading_composite_array.should == [ :A, :B, :C ]
    sub_cascading_composite_array.should == [ :A, :B, :C ]

  end

  #############
  #  unshift  #
  #############

  it 'can unshift onto the first element' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array += :A
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array.unshift( :B )
    cascading_composite_array.should == [ :B, :A ]
    sub_cascading_composite_array.should == [ :B, :A ]

    sub_cascading_composite_array.unshift( :C )
    cascading_composite_array.should == [ :B, :A ]
    sub_cascading_composite_array.should == [ :C, :B, :A ]

  end

  #########
  #  pop  #
  #########
  
  it 'can pop the final element' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array += :A
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array.pop.should == :A
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ ]

    cascading_composite_array += :B
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B ]

    sub_cascading_composite_array += :C
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B, :C ]
    sub_cascading_composite_array.pop.should == :C
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B ]

  end

  ###########
  #  shift  #
  ###########
  
  it 'can shift the first element' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array += :A
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array.shift.should == :A
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ ]

    cascading_composite_array += :B
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B ]

    sub_cascading_composite_array += :C
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B, :C ]
    sub_cascading_composite_array.shift.should == :B
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :C ]

  end

  ############
  #  slice!  #
  ############
  
  it 'can slice elements' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array += :A
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array.slice!( 0, 1 ).should == [ :A ]
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ ]

    cascading_composite_array += :B
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B ]

    sub_cascading_composite_array += :C
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B, :C ]

    sub_cascading_composite_array.slice!( 0, 1 ).should == [ :B ]
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :C ]

  end
  
  ###########
  #  clear  #
  ###########

  it 'can clear, causing present elements to be excluded' do

    cascading_composite_array = ::CompositingArray.new
    sub_cascading_composite_array = ::CompositingArray.new( cascading_composite_array )

    cascading_composite_array += :A
    cascading_composite_array.should == [ :A ]
    sub_cascading_composite_array.should == [ :A ]

    cascading_composite_array.clear
    cascading_composite_array.should == [ ]
    sub_cascading_composite_array.should == [ ]

    cascading_composite_array += :B
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B ]

    sub_cascading_composite_array += :C
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ :B, :C ]

    sub_cascading_composite_array.clear
    cascading_composite_array.should == [ :B ]
    sub_cascading_composite_array.should == [ ]

  end
  
end
