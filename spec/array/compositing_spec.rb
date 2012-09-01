
require_relative '../../lib/array-compositing.rb'

describe ::Array::Compositing do

  ################
  #  initialize  #
  ################

  it 'can add initialize with an ancestor, inheriting its values and linking to it as a child' do
  
    cascading_composite_array = ::Array::Compositing.new

    cascading_composite_array.instance_variable_get( :@parent_composite_object ).should == nil
    cascading_composite_array.should == [ ]
    cascading_composite_array.push( :A, :B, :C, :D )
    
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )
    sub_cascading_composite_array.should == [ :A, :B, :C, :D ]
    
  end

  ##################################################################################################
  #    private #####################################################################################
  ##################################################################################################

  #########
  #  []=  #
  #########

  it 'can add elements' do
  
    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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
  
    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

    cascading_composite_array = ::Array::Compositing.new
    sub_cascading_composite_array = ::Array::Compositing.new( cascading_composite_array )

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

  ##################
  #  pre_set_hook  #
  ##################

  it 'has a hook that is called before setting a value; return value is used in place of object' do
    
    class ::Array::Compositing::SubMockPreSet < ::Array::Compositing
      
      def pre_set_hook( index, object, is_insert = false )
        return :some_other_value
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockPreSet.new

    cascading_composite_array.push( :some_value )
    
    cascading_composite_array.should == [ :some_other_value ]
    
  end

  ###################
  #  post_set_hook  #
  ###################

  it 'has a hook that is called after setting a value' do

    class ::Array::Compositing::SubMockPostSet < ::Array::Compositing
      
      def post_set_hook( index, object, is_insert = false )
        return :some_other_value
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockPostSet.new

    cascading_composite_array.push( :some_value ).should == [ :some_other_value ]
    
    cascading_composite_array.should == [ :some_value ]
    
  end

  ##################
  #  pre_get_hook  #
  ##################

  it 'has a hook that is called before getting a value; if return value is false, get does not occur' do
    
    class ::Array::Compositing::SubMockPreGet < ::Array::Compositing
      
      def pre_get_hook( index )
        return false
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockPreGet.new
    
    cascading_composite_array.push( :some_value )
    cascading_composite_array[ 0 ].should == nil
    
    cascading_composite_array.should == [ :some_value ]
    
  end

  ###################
  #  post_get_hook  #
  ###################

  it 'has a hook that is called after getting a value' do

    class ::Array::Compositing::SubMockPostGet < ::Array::Compositing
      
      def post_get_hook( index, object )
        return :some_other_value
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockPostGet.new
    
    cascading_composite_array.push( :some_value )
    cascading_composite_array[ 0 ].should == :some_other_value
    
    cascading_composite_array.should == [ :some_value ]
    
  end

  #####################
  #  pre_delete_hook  #
  #####################

  it 'has a hook that is called before deleting an index; if return value is false, delete does not occur' do
    
    class ::Array::Compositing::SubMockPreDelete < ::Array::Compositing
      
      def pre_delete_hook( index )
        return false
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockPreDelete.new
    
    cascading_composite_array.push( :some_value )
    cascading_composite_array.delete_at( 0 )
    
    cascading_composite_array.should == [ :some_value ]
    
  end

  ######################
  #  post_delete_hook  #
  ######################

  it 'has a hook that is called after deleting an index' do
    
    class ::Array::Compositing::SubMockPostDelete < ::Array::Compositing
      
      def post_delete_hook( index, object )
        return :some_other_value
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockPostDelete.new
    
    cascading_composite_array.push( :some_value )
    cascading_composite_array.delete_at( 0 ).should == :some_other_value
    
    cascading_composite_array.should == [ ]
    
  end

  ########################
  #  child_pre_set_hook  #
  ########################

  it 'has a hook that is called before setting a value that has been passed by a parent; return value is used in place of object' do
    
    class ::Array::Compositing::SubMockChildPreSet < ::Array::Compositing
      
      def child_pre_set_hook( index, object, is_insert = false )
        return :some_other_value
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockChildPreSet.new
    sub_cascading_composite_array = ::Array::Compositing::SubMockChildPreSet.new( cascading_composite_array )
    cascading_composite_array.push( :some_value )

    sub_cascading_composite_array.should == [ :some_other_value ]
    
  end

  #########################
  #  child_post_set_hook  #
  #########################

  it 'has a hook that is called after setting a value passed by a parent' do

    class ::Array::Compositing::SubMockChildPostSet < ::Array::Compositing
      
      def child_post_set_hook( index, object, is_insert = false )
        push( :some_other_value )
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockChildPostSet.new
    sub_cascading_composite_array = ::Array::Compositing::SubMockChildPostSet.new( cascading_composite_array )
    cascading_composite_array.push( :some_value )

    cascading_composite_array.should == [ :some_value ]
    sub_cascading_composite_array.should == [ :some_value, :some_other_value ]
    
  end

  ###########################
  #  child_pre_delete_hook  #
  ###########################

  it 'has a hook that is called before deleting an index that has been passed by a parent; if return value is false, delete does not occur' do

    class ::Array::Compositing::SubMockChildPreDelete < ::Array::Compositing
      
      def child_pre_delete_hook( index )
        false
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockChildPreDelete.new
    sub_cascading_composite_array = ::Array::Compositing::SubMockChildPreDelete.new( cascading_composite_array )
    cascading_composite_array.push( :some_value )
    cascading_composite_array.delete( :some_value )

    cascading_composite_array.should == [ ]

    sub_cascading_composite_array.should == [ :some_value ]
    
  end

  ############################
  #  child_post_delete_hook  #
  ############################

  it 'has a hook that is called after deleting an index passed by a parent' do

    class ::Array::Compositing::SubMockChildPostDelete < ::Array::Compositing
      
      def child_post_delete_hook( index, object )
        delete( :some_other_value )
      end
      
    end
    
    cascading_composite_array = ::Array::Compositing::SubMockChildPostDelete.new
    sub_cascading_composite_array = ::Array::Compositing::SubMockChildPostDelete.new( cascading_composite_array )
    cascading_composite_array.push( :some_value )
    sub_cascading_composite_array.push( :some_other_value )
    cascading_composite_array.delete( :some_value )

    cascading_composite_array.should == [  ]
    sub_cascading_composite_array.should == [ ]
    
  end
  
end
