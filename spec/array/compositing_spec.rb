# -*- encoding : utf-8 -*-

require_relative '../../lib/array-compositing.rb'

describe ::Array::Compositing do

  let( :parent_array ) { ::Array::Compositing.new( nil, parent_configuration_instance, parent_elements ) }
  let( :child_array ) { ::Array::Compositing.new( parent_array, child_configuration_instance, child_elements ) }
  let( :second_parent_array ) do
    ::Array::Compositing.new( nil, second_parent_configuration_instance, second_parent_elements )
  end
  
  let( :parent_configuration_instance ) { nil }
  let( :parent_elements ) { [ ] }

  let( :child_configuration_instance ) { nil }
  let( :child_elements ) { [ ] }

  let( :second_parent_configuration_instance ) { nil }
  let( :second_parent_elements ) { [ ] }
  
  before :each do
    child_array
  end
  
  #####################
  #  register_parent  #
  #####################
  
  context '#register_parent' do
    it 'can add initialize with an ancestor, inheriting its values and linking to it as a child' do

      parent_array.should == [ ]
      parent_array.has_parents?.should == false
      parent_array.parents.should == [ ]
      parent_array.push( :A, :B, :C, :D )

      child_array.has_parents?.should == true
      child_array.parents.should == [ parent_array ]
      child_array.is_parent?( parent_array ).should == true
      child_array.should == [ :A, :B, :C, :D ]

      second_parent_array.push( :E, :F, :G )

      child_array.register_parent( second_parent_array )
      child_array.parents.should == [ parent_array, second_parent_array ]
      child_array.is_parent?( second_parent_array ).should == true
      child_array.should == [ :A, :B, :C, :D, :E, :F, :G ]

    end
  end

  #########
  #  []=  #
  #########

  context '#[]=' do
    it 'can add elements' do

      parent_array[ 0 ] = :A
      parent_array.should == [ :A ]
      child_array.should == [ :A ]

      parent_array[ 1 ] = :B
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B ]

      child_array[ 0 ] = :C
      parent_array.should == [ :A, :B ]
      child_array.should == [ :C, :B ]

      child_array[ 0 ] = :B
      parent_array.should == [ :A, :B ]
      child_array.should == [ :B, :B ]

      child_array[ 2 ] = :C
      parent_array.should == [ :A, :B ]
      child_array.should == [ :B, :B, :C ]

      parent_array[ 0 ] = :D
      parent_array.should == [ :D, :B ]
      child_array.should == [ :B, :B, :C ]

    end
  end
  
  ############
  #  insert  #
  ############

  context '#insert' do
    it 'can insert elements' do

      parent_array.insert( 3, :D )
      parent_array.should == [ nil, nil, nil, :D ]
      child_array.should == [ nil, nil, nil, :D ]

      parent_array.insert( 1, :B )
      parent_array.should == [ nil, :B, nil, nil, :D ]
      child_array.should == [ nil, :B, nil, nil, :D ]

      parent_array.insert( 2, :C )
      parent_array.should == [ nil, :B, :C, nil, nil, :D ]
      child_array.should == [ nil, :B, :C, nil, nil, :D ]

      child_array.insert( 0, :E )
      parent_array.should == [ nil, :B, :C, nil, nil, :D ]
      child_array.should == [ :E, nil, :B, :C, nil, nil, :D ]

      child_array.insert( 4, :F )
      parent_array.should == [ nil, :B, :C, nil, nil, :D ]
      child_array.should == [ :E, nil, :B, :C, :F, nil, nil, :D ]

    end
  end

  ##########
  #  push  #
  ##########
  
  context '#push' do
    it 'can add elements' do

      parent_array.push( :A )
      parent_array.should == [ :A ]
      child_array.should == [ :A ]

      parent_array.push( :B )
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B ]

      child_array.push( :C )
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B, :C ]

      child_array.push( :B )
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B, :C, :B ]

    end
  end
  
  ########
  #  <<  #
  ########
  
  context '#<<' do
    it 'can add elements' do

      parent_array << :A
      parent_array.should == [ :A ]
      child_array.should == [ :A ]

      parent_array << :B
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B ]

      child_array << :C
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B, :C ]

      child_array << :B
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B, :C, :B ]

    end
  end

  #######
  #  +  #
  #######
  
  # FIX
  # + does not currently work for compositing because it doesn't modify self
  # perhaps we can fix this by having duplicate inherit parents/children
  
  ############
  #  concat  #
  ############

  context '#concat' do
    it 'can add elements' do

      parent_array.concat( [ :A ] )
      parent_array.should == [ :A ]
      child_array.should == [ :A ]

      parent_array.concat( [ :B ] )
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B ]

      child_array.concat( [ :C ] )
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B, :C ]

      child_array.push( :B )
      parent_array.should == [ :A, :B ]
      child_array.should == [ :A, :B, :C, :B ]

    end
  end

  ####################
  #  delete_objects  #
  ####################

  context '#delete_objects' do
    let( :parent_elements ) { [ :A, :B ] }
    it 'can delete multiple elements' do

      parent_array.delete_objects( :A, :B )
      parent_array.should == [ ]
      child_array.should == [ ]

      child_array.concat( [ :B, :C, :D ] )
      parent_array.should == [ ]
      child_array.should == [ :B, :C, :D ]

      child_array.delete_objects( :C, :B )
      parent_array.should == [ ]
      child_array.should == [ :D ]

    end
  end

  #######
  #  -  #
  #######
  
  # FIX
  # - does not currently work for compositing because it doesn't modify self
  # perhaps we can fix this by having duplicate inherit parents/children

  ############
  #  delete  #
  ############
  
  context '#delete' do
    let( :parent_elements ) { [ :A ] }
    it 'can delete elements' do

      parent_array.delete( :A )
      parent_array.should == [ ]
      child_array.should == [ ]

      parent_array.push( :B )
      parent_array.should == [ :B ]
      child_array.should == [ :B ]

      child_array.push( :C )
      parent_array.should == [ :B ]
      child_array.should == [ :B, :C ]

      child_array.delete( :B )
      parent_array.should == [ :B ]
      child_array.should == [ :C ]

    end
  end

  ###############
  #  delete_at  #
  ###############

  context '#delete_at' do
    let( :parent_elements ) { [ :A ] }
    it 'can delete by indexes' do

      parent_array.delete_at( 0 )
      parent_array.should == [ ]
      child_array.should == [ ]

      parent_array.push( :B )
      parent_array.should == [ :B ]
      child_array.should == [ :B ]

      child_array.push( :C )
      parent_array.should == [ :B ]
      child_array.should == [ :B, :C ]

      child_array.delete_at( 0 )
      parent_array.should == [ :B ]
      child_array.should == [ :C ]

    end
  end

  #######################
  #  delete_at_indexes  #
  #######################

  context '#delete_at_indexes' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can delete by indexes' do

      parent_array.delete_at_indexes( 0, 1 )
      parent_array.should == [ :C ]
      child_array.should == [ :C ]

      child_array.push( :C, :B )
      parent_array.should == [ :C ]
      child_array.should == [ :C, :C, :B ]

      child_array.delete_at_indexes( 0, 1, 2 )
      parent_array.should == [ :C ]
      child_array.should == [ ]

    end
  end

  ###############
  #  delete_if  #
  ###############

  context '#delete_if' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can delete by block' do

      parent_array.delete_if do |object|
        object != :C
      end
      parent_array.should == [ :C ]
      child_array.should == [ :C ]

      child_array.push( :C, :B )
      parent_array.should == [ :C ]
      child_array.should == [ :C, :C, :B ]
      child_array.delete_if do |object|
        object != nil
      end
      child_array.should == [ ]
      parent_array.should == [ :C ]

      parent_array.delete_if.is_a?( Enumerator ).should == true

    end
  end

  #############
  #  keep_if  #
  #############

  context '#keep_if' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can keep by block' do

      parent_array.keep_if do |object|
        object == :C
      end
      parent_array.should == [ :C ]
      child_array.should == [ :C ]

      child_array.push( :C, :B )
      parent_array.should == [ :C ]
      child_array.should == [ :C, :C, :B ]
      child_array.keep_if do |object|
        object == nil
      end
      parent_array.should == [ :C ]
      child_array.should == [ ]

    end
  end

  ##############
  #  compact!  #
  ##############

  context '#compact!' do
    let( :parent_elements ) { [ :A, nil, :B, nil, :C, nil ] }
    it 'can compact' do

      parent_array.compact!
      parent_array.should == [ :A, :B, :C ]
      child_array.should == [ :A, :B, :C ]

      child_array.push( nil, nil, :D )
      parent_array.should == [ :A, :B, :C ]
      child_array.should == [ :A, :B, :C, nil, nil, :D ]
      child_array.compact!
      parent_array.should == [ :A, :B, :C ]
      child_array.should == [ :A, :B, :C, :D ]

    end
  end

  ##############
  #  flatten!  #
  ##############

  context '#flatten!' do
    let( :parent_elements ) { [ :A, [ :F_A, :F_B ], :B, [ :F_C ], :C, [ :F_D ], [ :F_E ] ] }
    it 'child will flatten when parent does' do
      parent_array.flatten!
      parent_array.should == [ :A, :F_A, :F_B, :B, :F_C, :C, :F_D, :F_E ]
      child_array.should == [ :A, :F_A, :F_B, :B, :F_C, :C, :F_D, :F_E ]
    end
    it 'parent will not flatten when child does' do
      child_array.flatten!
      parent_array.should == [ :A, [ :F_A, :F_B ], :B, [ :F_C ], :C, [ :F_D ], [ :F_E ] ]
      child_array.should == [ :A, :F_A, :F_B, :B, :F_C, :C, :F_D, :F_E ]
    end
  end

  #############
  #  reject!  #
  #############

  context '#reject!' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can reject' do

      parent_array.reject! do |object|
        object != :C
      end
      parent_array.should == [ :C ]
      child_array.should == [ :C ]

      child_array.push( :C, :B )
      parent_array.should == [ :C ]
      child_array.should == [ :C, :C, :B ]
      child_array.reject! do |object|
        object != nil
      end
      child_array.should == [ ]
      parent_array.should == [ :C ]

      parent_array.reject!.is_a?( Enumerator ).should == true

    end
  end

  #############
  #  replace  #
  #############

  context '#replace' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can replace self' do

      parent_array.replace( [ :D, :E, :F ] )
      parent_array.should == [ :D, :E, :F ]
      child_array.should == [ :D, :E, :F ]

      parent_array.should == [ :D, :E, :F ]
      child_array.should == [ :D, :E, :F ]
      child_array.replace( [ :G, :H, :I ] )
      parent_array.should == [ :D, :E, :F ]
      child_array.should == [ :G, :H, :I ]

    end
  end

  ##############
  #  reverse!  #
  ##############

  context '#reverse!' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can reverse self' do

      parent_array.reverse!
      parent_array.should == [ :C, :B, :A ]
      child_array.should == [ :C, :B, :A ]

      parent_array.should == [ :C, :B, :A ]
      child_array.should == [ :C, :B, :A ]
      child_array.reverse!
      parent_array.should == [ :C, :B, :A ]
      child_array.should == [ :A, :B, :C ]

    end
  end

  #############
  #  rotate!  #
  #############

  context '#rotate!' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can rotate self' do

      parent_array.rotate!
      parent_array.should == [ :B, :C, :A ]
      child_array.should == [ :B, :C, :A ]

      parent_array.rotate!( -1 )
      parent_array.should == [ :A, :B, :C ]
      child_array.should == [ :A, :B, :C ]

      child_array.rotate!( 2 )
      parent_array.should == [ :A, :B, :C ]
      child_array.should == [ :C, :A, :B ]

    end
  end

  #############
  #  select!  #
  #############

  context '#select!' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can keep by select' do

      parent_array.select! do |object|
        object == :C
      end
      parent_array.should == [ :C ]
      child_array.should == [ :C ]

      child_array.push( :C, :B )
      parent_array.should == [ :C ]
      child_array.should == [ :C, :C, :B ]
      child_array.select! do |object|
        object == nil
      end
      parent_array.should == [ :C ]
      child_array.should == [ ]

      parent_array.select!.is_a?( Enumerator ).should == true

    end
  end

  ##############
  #  shuffle!  #
  ##############

  context '#shuffle!' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can shuffle self' do
      shuffled = false
      100.times do
        parent_array.shuffle!
        break if shuffled = ( parent_array != [ :A, :B, :C ] )
      end
      shuffled.should == true
      child_array.should == parent_array
    end

    it 'can shuffle self with a random number generator' do
      shuffled = false
      100.times do
        parent_array.shuffle!( random: Random.new( 1 ) )
        break if shuffled = ( parent_array != [ :A, :B, :C ] )
      end
      shuffled.should == true
      child_array.should == parent_array
    end
  end

  ##############
  #  collect!  #
  ##############

  context '#collect!' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can replace by collect/map' do

      parent_array.collect! do |object|
        :C
      end
      parent_array.should == [ :C, :C, :C ]
      child_array.should == [ :C, :C, :C ]

      child_array.collect! do |object|
        :A
      end
      parent_array.should == [ :C, :C, :C ]
      child_array.should == [ :A, :A, :A ]

      parent_array.collect!.is_a?( Enumerator ).should == true

    end
  end

  ##########
  #  map!  #
  ##########

  context '#map!' do
    it 'is an alias for #collect!' do
    end
  end
  
  ###########
  #  sort!  #
  ###########

  context '#sort!' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can replace by collect/map' do

      parent_array.sort! do |a, b|
        if a < b
          1
        elsif a > b
          -1
        elsif a == b
          0
        end
      end
      parent_array.should == [ :C, :B, :A ]
      child_array.should == [ :C, :B, :A ]

      child_array.sort! do |a, b|
        if a < b
          -1
        elsif a > b
          1
        elsif a == b
          0
        end
      end
      parent_array.should == [ :C, :B, :A ]
      child_array.should == [ :A, :B, :C ]

      parent_array.sort!
      parent_array.should == [ :A, :B, :C ]
      child_array.should == [ :A, :B, :C ]

    end
  end

  ##############
  #  sort_by!  #
  ##############

  context '#sort_by!' do
    let( :parent_elements ) { [ :A, :B, :C ] }
    it 'can replace by collect/map' do

      parent_array.sort_by! do |object|
        case object
        when :A
          :B
        when :B
          :A
        when :C
          :C
        end
      end
      parent_array.should == [ :B, :A, :C ]
      child_array.should == [ :B, :A, :C ]

      child_array.sort_by! do |object|
        case object
        when :A
          :C
        when :B
          :B
        when :C
          :A
        end
      end
      parent_array.should == [ :B, :A, :C ]
      child_array.should == [ :C, :B, :A ]

      parent_array.sort_by!.is_a?( Enumerator ).should == true

    end
  end

  ###########
  #  uniq!  #
  ###########

  context '#uniq!' do
    let( :parent_elements ) { [ :A, :B, :C, :C, :C, :B, :A ] }
    it 'can remove non-unique elements' do

      parent_array.uniq!
      parent_array.should == [ :A, :B, :C ]
      child_array.should == [ :A, :B, :C ]

      child_array.push( :C, :B )
      parent_array.should == [ :A, :B, :C ]
      child_array.should == [ :A, :B, :C, :C, :B ]
      child_array.uniq!
      parent_array.should == [ :A, :B, :C ]
      child_array.should == [ :A, :B, :C ]

    end
  end

  #############
  #  unshift  #
  #############

  context '#unshift' do
    let( :parent_elements ) { [ :A ] }
    it 'can unshift onto the first element' do

      parent_array.should == [ :A ]
      child_array.should == [ :A ]

      parent_array.unshift( :B )
      parent_array.should == [ :B, :A ]
      child_array.should == [ :B, :A ]

      child_array.unshift( :C )
      parent_array.should == [ :B, :A ]
      child_array.should == [ :C, :B, :A ]

    end
  end

  #########
  #  pop  #
  #########
  
  context '#pop' do
    let( :parent_elements ) { [ :A ] }
    it 'can pop the final element' do

      parent_array.pop.should == :A
      parent_array.should == [ ]
      child_array.should == [ ]

      parent_array.push( :B )
      parent_array.should == [ :B ]
      child_array.should == [ :B ]

      child_array.push( :C )
      parent_array.should == [ :B ]
      child_array.should == [ :B, :C ]
      child_array.pop.should == :C
      parent_array.should == [ :B ]
      child_array.should == [ :B ]

    end
  end

  ###########
  #  shift  #
  ###########
  
  context '#shift' do
    let( :parent_elements ) { [ :A ] }
    it 'can shift the first element' do

      parent_array.shift.should == :A
      parent_array.should == [ ]
      child_array.should == [ ]

      parent_array.push( :B )
      parent_array.should == [ :B ]
      child_array.should == [ :B ]

      child_array.push( :C )
      parent_array.should == [ :B ]
      child_array.should == [ :B, :C ]
      child_array.shift.should == :B
      parent_array.should == [ :B ]
      child_array.should == [ :C ]

    end
  end

  ############
  #  slice!  #
  ############
  
  context '#slice!' do
    let( :parent_elements ) { [ :A ] }
    it 'can slice elements' do

      parent_array.slice!( 0, 1 ).should == [ :A ]
      parent_array.should == [ ]
      child_array.should == [ ]

      parent_array.push( :B )
      parent_array.should == [ :B ]
      child_array.should == [ :B ]

      child_array.push( :C )
      parent_array.should == [ :B ]
      child_array.should == [ :B, :C ]

      child_array.slice!( 0, 1 ).should == [ :B ]
      parent_array.should == [ :B ]
      child_array.should == [ :C ]

    end
  end
  
  ###########
  #  clear  #
  ###########

  context '#clear' do
    let( :parent_elements ) { [ :A ] }
    it 'can clear, causing present elements to be excluded' do

      parent_array.clear
      parent_array.should == [ ]
      child_array.should == [ ]

      parent_array.push( :B )
      parent_array.should == [ :B ]
      child_array.should == [ :B ]

      child_array.push( :C )
      parent_array.should == [ :B ]
      child_array.should == [ :B, :C ]

      child_array.clear
      parent_array.should == [ :B ]
      child_array.should == [ ]

    end
  end

  ##################
  #  pre_set_hook  #
  ##################

  context '#pre_set_hook' do
    it 'has a hook that is called before setting a value; return value is used in place of object' do

      class ::Array::Compositing::SubMockPreSet < ::Array::Compositing

        def pre_set_hook( index, object, is_insert = false, length = nil )
          return :some_other_value
        end

      end

      parent_array = ::Array::Compositing::SubMockPreSet.new

      parent_array.push( :some_value )

      parent_array.should == [ :some_other_value ]

    end
  end

  ###################
  #  post_set_hook  #
  ###################

  context '#post_set_hook' do
    it 'has a hook that is called after setting a value' do

      class ::Array::Compositing::SubMockPostSet < ::Array::Compositing

        def post_set_hook( index, object, is_insert = false, length = nil )
          return :some_other_value
        end

      end

      parent_array = ::Array::Compositing::SubMockPostSet.new

      parent_array.push( :some_value )

      parent_array.should == [ :some_value ]

    end
  end

  ##################
  #  pre_get_hook  #
  ##################

  context '#pre_get_hook' do
    it 'has a hook that is called before getting a value; if return value is false, get does not occur' do

      class ::Array::Compositing::SubMockPreGet < ::Array::Compositing

        def pre_get_hook( index, length )
          return false
        end

      end

      parent_array = ::Array::Compositing::SubMockPreGet.new

      parent_array.push( :some_value )
      parent_array[ 0 ].should == nil

      parent_array.should == [ :some_value ]

    end
  end

  ###################
  #  post_get_hook  #
  ###################

  context '#post_get_hook' do
    it 'has a hook that is called after getting a value' do

      class ::Array::Compositing::SubMockPostGet < ::Array::Compositing

        def post_get_hook( index, object, length )
          return :some_other_value
        end

      end

      parent_array = ::Array::Compositing::SubMockPostGet.new

      parent_array.push( :some_value )
      parent_array[ 0 ].should == :some_other_value

      parent_array.should == [ :some_value ]

    end
  end

  #####################
  #  pre_delete_hook  #
  #####################

  context '#pre_delete_hook' do
    it 'has a hook that is called before deleting an index; if return value is false, delete does not occur' do

      class ::Array::Compositing::SubMockPreDelete < ::Array::Compositing

        def pre_delete_hook( index )
          return false
        end

      end

      parent_array = ::Array::Compositing::SubMockPreDelete.new

      parent_array.push( :some_value )
      parent_array.delete_at( 0 )

      parent_array.should == [ :some_value ]

    end
  end

  ######################
  #  post_delete_hook  #
  ######################

  context '#post_delete_hook' do
    it 'has a hook that is called after deleting an index' do

      class ::Array::Compositing::SubMockPostDelete < ::Array::Compositing

        def post_delete_hook( index, object )
          return :some_other_value
        end

      end

      parent_array = ::Array::Compositing::SubMockPostDelete.new

      parent_array.push( :some_value )
      parent_array.delete_at( 0 ).should == :some_other_value

      parent_array.should == [ ]

    end
  end

  ########################
  #  child_pre_set_hook  #
  ########################

  context '#child_pre_set_hook' do
    it 'has a hook that is called before setting a value that has been passed by a parent; return value is used in place of object' do

      class ::Array::Compositing::SubMockChildPreSet < ::Array::Compositing

        def child_pre_set_hook( index, object, is_insert = false, parent_array = nil )
          return :some_other_value
        end

      end

      parent_array = ::Array::Compositing::SubMockChildPreSet.new
      child_array = ::Array::Compositing::SubMockChildPreSet.new( parent_array )
      parent_array.push( :some_value )

      child_array.should == [ :some_other_value ]

    end
  end

  #########################
  #  child_post_set_hook  #
  #########################

  context '#child_post_set_hook' do
    it 'has a hook that is called after setting a value passed by a parent' do

      class ::Array::Compositing::SubMockChildPostSet < ::Array::Compositing

        def child_post_set_hook( index, object, is_insert = false, parent_array = nil )
          push( :some_other_value )
        end

      end

      parent_array = ::Array::Compositing::SubMockChildPostSet.new
      child_array = ::Array::Compositing::SubMockChildPostSet.new( parent_array )
      parent_array.push( :some_value )

      parent_array.should == [ :some_value ]
      child_array.should == [ :some_value, :some_other_value ]

    end
  end

  ###########################
  #  child_pre_delete_hook  #
  ###########################

  context '#child_pre_delete_hook' do
    it 'has a hook that is called before deleting an index that has been passed by a parent; if return value is false, delete does not occur' do

      class ::Array::Compositing::SubMockChildPreDelete < ::Array::Compositing

        def child_pre_delete_hook( index, parent_array = nil )
          false
        end

      end

      parent_array = ::Array::Compositing::SubMockChildPreDelete.new
      child_array = ::Array::Compositing::SubMockChildPreDelete.new( parent_array )
      parent_array.push( :some_value )
      parent_array.delete( :some_value )

      parent_array.should == [ ]

      child_array.should == [ :some_value ]

    end
  end

  ############################
  #  child_post_delete_hook  #
  ############################

  context '#child_post_delete_hook' do
    it 'has a hook that is called after deleting an index passed by a parent' do

      class ::Array::Compositing::SubMockChildPostDelete < ::Array::Compositing
        def child_post_delete_hook( index, object, parent_array = nil )
          delete( :some_other_value )
        end
      end

      parent_array = ::Array::Compositing::SubMockChildPostDelete.new
      child_array = ::Array::Compositing::SubMockChildPostDelete.new( parent_array )
      parent_array.push( :some_value )
      child_array.push( :some_other_value )
      parent_array.delete( :some_value )

      parent_array.should == [  ]
      child_array.should == [ ]

    end
  end

  #######################
  #  unregister_parent  #
  #######################
  
  context '#unregister_parent' do
    let( :parent_elements ) { [ :A, :B, :C, :D ] }
    let( :second_parent_elements ) { [ :E, :F, :G ] }
    it 'can unregister parent instances that have been registered' do
      child_array.register_parent( second_parent_array )
      third_parent_array = ::Array::Compositing.new( nil, nil, [ :H, :I, :J ] )
      child_array.register_parent( third_parent_array )

      child_array.should == [ :A, :B, :C, :D, :E, :F, :G, :H, :I, :J ]
      child_array.unregister_parent( second_parent_array )
      child_array.should == [ :A, :B, :C, :D, :H, :I, :J ]
    end
  end

  #############
  #  reorder  #
  #############

  context '#reorder' do
    let( :parent_elements ) { [ :A, :B, :C, :D ] }
    let( :new_order ) { [ 3, 0, 1, 2 ] }
    let( :reordered_array ) { parent_array.reorder( new_order ) }
    let( :reordered_child_array ) { child_array.reorder( new_order ) }
    it 'can re-order elements in parent, causing child to re-order' do
      reordered_array.should == [ :B, :C, :D, :A ]
      child_array.should == reordered_array
    end
    it 'can re-order elements in child without affecting parent elements' do
      parent_array.should == [ :A, :B, :C, :D ]
      reordered_child_array.should == [ :B, :C, :D, :A ]
    end
  end
  
  ##########
  #  move  #
  ##########

  context '#move' do
    let( :parent_elements ) { [ :A, :B, :C, :D ] }
    context 'for parent' do
      context 'when both indexes are in range' do
        before :each do
          child_array
          parent_array.move( 1, 3 )
        end
        it 'can move indexes' do
          parent_array.should == [ :A, :C, :D, :B ]
          child_array.should == parent_array
        end
      end
      context 'when one index is above length' do
        context 'index one' do
          before :each do
            child_array
            parent_array.move( 5, 1 )
          end
          it 'can move indexes, inserting nil as appropriate' do
            parent_array.should == [ :A, nil, :B, :C, :D ]
            child_array.should == parent_array
          end
        end
        context 'index two' do
          before :each do
            child_array
            parent_array.move( 1, 5 )
          end
          it 'can move indexes, inserting nil as appropriate' do
            parent_array.should == [ :A, :C, :D, nil, nil, :B ]
            child_array.should == parent_array
          end
        end
      end
      context 'when one index is below 0' do
        context 'index one' do
          before :each do
            child_array
            parent_array.move( -5, 1 )
          end
          it 'can move indexes, inserting nil as appropriate' do
            parent_array.should == [ :A, nil, :B, :C, :D ]
            child_array.should == parent_array
          end
        end
        context 'index two' do
          before :each do
            child_array
            parent_array.move( 1, -5 )
          end
          it 'can move indexes, inserting nil as appropriate' do
            parent_array.should == [ :B, nil, nil, :A, :C, :D ]
            child_array.should == parent_array
          end
        end
      end
      context 'when both indexes are below 0' do
        before :each do
          child_array
          parent_array.move( -7, -5 )
        end
        it 'can move indexes, inserting nil as appropriate' do
          parent_array.should == [ nil, nil, nil, :A, :B, :C, :D ]
          child_array.should == parent_array
        end
      end
      context 'when both indexes are above length' do
        before :each do
          child_array
          parent_array.move( 7, 5 )
        end
        it 'can move indexes, inserting nil as appropriate' do
          parent_array.should == [ :A, :B, :C, :D, nil, nil, nil ]
          child_array.should == parent_array
        end
      end
    end
    context 'for child' do
      context 'when both indexes are in range' do
        before :each do
          child_array.move( 1, 3 )
        end
        it 'can move indexes in child without affecting parent' do
          parent_array.should == [ :A, :B, :C, :D ]
          child_array.should == [ :A, :C, :D, :B ]
        end
      end
      context 'when one index is above length' do
        before :each do
          child_array.move( 1, 5 )
        end
        it 'can move indexes, inserting nil as appropriate in child without affecting parent' do
          parent_array.should == [ :A, :B, :C, :D ]
          child_array.should == [ :A, :C, :D, nil, nil, :B ]
        end
      end
      context 'when one index is below 0' do
        before :each do
          child_array.move( 1, 5 )
        end
        it 'can move indexes, inserting nil as appropriate in child without affecting parent' do
          parent_array.should == [ :A, :B, :C, :D ]
          child_array.should == [ :A, :C, :D, nil, nil, :B ]
        end
      end
      context 'when both indexes are below 0' do
        before :each do
          child_array.move( -7, -5 )
        end
        it 'can move indexes, inserting nil as appropriate' do
          parent_array.should == [ :A, :B, :C, :D ]
          child_array.should == [ nil, nil, nil, :A, :B, :C, :D ]
        end
      end
      context 'when both indexes are above length' do
        before :each do
          child_array.move( 7, 5 )
        end
        it 'can move indexes, inserting nil as appropriate' do
          parent_array.should == [ :A, :B, :C, :D ]
          child_array.should == [ :A, :B, :C, :D, nil, nil, nil ]
        end
      end
    end
  end

  ##########
  #  swap  #
  ##########

  context '#swap' do
    let( :parent_elements ) { [ :A, :B, :C, :D ] }
    context 'for parent' do
      context 'when both indexes are in range' do
        before :each do
          child_array
          parent_array.swap( 1, 3 )
        end
        it 'can swap indexes' do
          parent_array.should == [ :A, :D, :C, :B ]
          child_array.should == parent_array
        end
      end
      context 'when one index is above length' do
        context 'index one' do
          before :each do
            child_array
            parent_array.swap( 5, 1 )
          end
          it 'can swap indexes, inserting nil as appropriate' do
            parent_array.should == [ :A, nil, :B, :C, :D ]
            child_array.should == parent_array
          end
        end
        context 'index two' do
          before :each do
            child_array
            parent_array.swap( 1, 5 )
          end
          it 'can swap indexes, inserting nil as appropriate' do
            parent_array.should == [ :A, nil, :C, :D, nil, :B ]
            child_array.should == parent_array
          end
        end
      end
      context 'when one index is below 0' do
        context 'index one' do
          before :each do
            child_array
            parent_array.swap( -5, 1 )
          end
          it 'can swap indexes, inserting nil as appropriate' do
            parent_array.should == [ :A, nil, :B, :C, :D ]
            child_array.should == parent_array
          end
        end
        context 'index two' do
          before :each do
            child_array
            parent_array.swap( 1, -5 )
          end
          it 'can swap indexes, inserting nil as appropriate' do
            parent_array.should == [ :B, :A, nil, :C, :D ]
            child_array.should == parent_array
          end
        end
      end
      context 'when both indexes are below 0' do
        before :each do
          child_array
          parent_array.swap( -7, -5 )
        end
        it 'can move indexes, inserting nil as appropriate' do
          parent_array.should == [ nil, nil, nil, :A, :B, :C, :D ]
          child_array.should == parent_array
        end
      end
      context 'when both indexes are above length' do
        before :each do
          child_array
          parent_array.swap( 7, 5 )
        end
        it 'can move indexes, inserting nil as appropriate' do
          parent_array.should == [ :A, :B, :C, :D, nil, nil, nil ]
          child_array.should == parent_array
        end
      end
    end
    context 'for child' do
      context 'when both indexes are in range' do
        before :each do
          child_array.swap( 1, 3 )
        end
        it 'can swap indexes in child without affecting parent' do
          parent_array.should == [ :A, :B, :C, :D ]
          child_array.should == [ :A, :D, :C, :B ]
        end
      end
      context 'when one index is above length' do
        context 'index one' do
          before :each do
            child_array.swap( 5, 1 )
          end
          it 'can swap indexes, inserting nil as appropriate in child without affecting parent' do
            parent_array.should == [ :A, :B, :C, :D ]
            child_array.should == [ :A, nil, :B, :C, :D ]
          end
        end
        context 'index two' do
          before :each do
            child_array.swap( 1, 5 )
          end
          it 'can swap indexes, inserting nil as appropriate in child without affecting parent' do
            parent_array.should == [ :A, :B, :C, :D ]
            child_array.should == [ :A, nil, :C, :D, nil, :B ]
          end
        end
      end
      context 'when one index is below 0' do
        context 'index one' do
          before :each do
            child_array.swap( -5, 1 )
          end
          it 'can swap indexes, inserting nil as appropriate in child without affecting parent' do
            parent_array.should == [ :A, :B, :C, :D ]
            child_array.should == [ :A, nil, :B, :C, :D ]
          end
        end
        context 'index two' do
          before :each do
            child_array.swap( 1, -5 )
          end
          it 'can swap indexes, inserting nil as appropriate in child without affecting parent' do
            parent_array.should == [ :A, :B, :C, :D ]
            child_array.should == [ :B, :A, nil, :C, :D ]
          end
        end
      end
      context 'when both indexes are below 0' do
        before :each do
          child_array.swap( -7, -5 )
        end
        it 'can move indexes, inserting nil as appropriate' do
          parent_array.should == [ :A, :B, :C, :D ]
          child_array.should == [ nil, nil, nil, :A, :B, :C, :D ]
        end
      end
      context 'when both indexes are above length' do
        before :each do
          child_array.swap( 7, 5 )
        end
        it 'can move indexes, inserting nil as appropriate' do
          parent_array.should == [ :A, :B, :C, :D ]
          child_array.should == [ :A, :B, :C, :D, nil, nil, nil ]
        end
      end
    end
  end
    
end
