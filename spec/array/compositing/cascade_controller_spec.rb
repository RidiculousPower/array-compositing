# -*- encoding : utf-8 -*-

require_relative '../../../lib/array-compositing.rb'

describe ::Array::Compositing::CascadeController do
  
  let( :array_instance ) { [ :A_0, :A_1, :A_2, :A_3 ] }
  let( :index_map ) do
    index_map = ::Array::Compositing::CascadeController.new( array_instance )
    if parent_array_one
      index_map.register_parent( parent_array_one, parent_one_insert_index )
      array_instance.concat( parent_array_one )
    end
    if parent_array_two
      index_map.register_parent( parent_array_two, parent_two_insert_index )
      array_instance.concat( parent_array_two )
    end
    if parent_array_three
      index_map.register_parent( parent_array_three, parent_three_insert_index )
      array_instance.concat( parent_array_three )
    end
    index_map
  end

  let( :parent_array_one ) { [ :P1_0, :P1_1, :P1_2, :P1_3 ] }
  let( :parent_index_map_one ) { ::Array::Compositing::CascadeController.new( parent_array_one ) }

  let( :parent_array_two ) { [ :P2_0, :P2_1, :P2_2, :P2_3 ] }
  let( :parent_index_map_two ) { ::Array::Compositing::CascadeController.new( parent_array_two ) }

  let( :parent_array_three ) { [ :P3_0, :P3_1, :P3_2, :P3_3 ] }
  let( :parent_index_map_three ) { ::Array::Compositing::CascadeController.new( parent_array_three ) }
  
  let( :parent_one_insert_index ) { nil }
  let( :parent_two_insert_index ) { nil }
  let( :parent_three_insert_index ) { nil }
  
  ####################
  #  array_instance  #
  ####################
  
  context '#array_instance' do
    it 'returns the instance it controls' do
      index_map.array_instance.should be array_instance
      parent_index_map_one.array_instance.should be parent_array_one
      parent_index_map_two.array_instance.should be parent_array_two
      parent_index_map_three.array_instance.should be parent_array_three
    end
  end
  
  ###############################
  #  local_index_to_parent_map  #
  ###############################
  
  context '#local_index_to_parent_map' do
    it 'will track which parent array instance controls each local index' do
      index_map.local_index_to_parent_map[ 0 ].should be nil
      index_map.local_index_to_parent_map[ 1 ].should be nil
      index_map.local_index_to_parent_map[ 2 ].should be nil
      index_map.local_index_to_parent_map[ 3 ].should be nil

      index_map.local_index_to_parent_map[ 4 ].should be parent_array_one
      index_map.local_index_to_parent_map[ 5 ].should be parent_array_one
      index_map.local_index_to_parent_map[ 6 ].should be parent_array_one
      index_map.local_index_to_parent_map[ 7 ].should be parent_array_one

      index_map.local_index_to_parent_map[ 8 ].should be parent_array_two
      index_map.local_index_to_parent_map[ 9 ].should be parent_array_two
      index_map.local_index_to_parent_map[ 10 ].should be parent_array_two
      index_map.local_index_to_parent_map[ 11 ].should be parent_array_two

      index_map.local_index_to_parent_map[ 12 ].should be parent_array_three
      index_map.local_index_to_parent_map[ 13 ].should be parent_array_three
      index_map.local_index_to_parent_map[ 14 ].should be parent_array_three
      index_map.local_index_to_parent_map[ 15 ].should be parent_array_three
    end
  end
  
  ######################
  #  parent_local_map  #
  ######################
  
  context '#parent_local_map' do
    let( :parent_local_one_map ) { index_map.parent_local_map( parent_array_one ) }
    let( :parent_local_two_map ) { index_map.parent_local_map( parent_array_two ) }
    let( :parent_local_three_map ) { index_map.parent_local_map( parent_array_three ) }
    it 'parent one has its own IndexMap' do
      parent_local_one_map.should be_a ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap
      parent_local_one_map.should be index_map.parent_local_map( parent_array_one )
      parent_local_one_map.should_not be parent_local_two_map
      parent_local_one_map.should_not be parent_local_three_map
    end
    it 'parent two has its own IndexMap' do
      parent_local_two_map.should be_a ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap
      parent_local_two_map.should be index_map.parent_local_map( parent_array_two )
      parent_local_two_map.should_not be parent_local_one_map
      parent_local_two_map.should_not be parent_local_three_map
    end
    it 'parent three has its own IndexMap' do
      parent_local_three_map.should be_a ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap
      parent_local_three_map.should be index_map.parent_local_map( parent_array_three )
      parent_local_three_map.should_not be parent_local_one_map
      parent_local_three_map.should_not be parent_local_two_map
    end
  end

  ######################
  #  local_parent_map  #
  ######################

  context '#local_parent_map' do
    let( :local_parent_one_map ) { index_map.local_parent_map( parent_array_one ) }
    let( :local_parent_two_map ) { index_map.local_parent_map( parent_array_two ) }
    let( :local_parent_three_map ) { index_map.local_parent_map( parent_array_three ) }
    it 'parent one has its own IndexMap' do
      local_parent_one_map.should be_a ::Array::Compositing::CascadeController::IndexMap::LocalParentMap
      local_parent_one_map.should be index_map.local_parent_map( parent_array_one )
      local_parent_one_map.should_not be local_parent_two_map
      local_parent_one_map.should_not be local_parent_three_map
    end
    it 'parent two has its own IndexMap' do
      local_parent_two_map.should be_a ::Array::Compositing::CascadeController::IndexMap::LocalParentMap
      local_parent_two_map.should be index_map.local_parent_map( parent_array_two )
      local_parent_two_map.should_not be local_parent_one_map
      local_parent_two_map.should_not be local_parent_three_map
    end
    it 'parent three has its own IndexMap' do
      local_parent_three_map.should be_a ::Array::Compositing::CascadeController::IndexMap::LocalParentMap
      local_parent_three_map.should be index_map.local_parent_map( parent_array_three )
      local_parent_three_map.should_not be local_parent_one_map
      local_parent_three_map.should_not be local_parent_two_map
    end
  end
    
  #######################
  #  unregister_parent  #
  #######################

  context '#unregister_parent' do
    before :each do
      index_map.unregister_parent( parent_array_two ).each do |this_index|
        array_instance.delete_at( this_index )
      end
    end
    it 'will unregister elements from parent' do

      index_map.local_index_to_parent_map[ 0 ].should be nil
      index_map.local_index_to_parent_map[ 1 ].should be nil
      index_map.local_index_to_parent_map[ 2 ].should be nil
      index_map.local_index_to_parent_map[ 3 ].should be nil

      index_map.local_index_to_parent_map[ 4 ].should be parent_array_one
      index_map.local_index_to_parent_map[ 5 ].should be parent_array_one
      index_map.local_index_to_parent_map[ 6 ].should be parent_array_one
      index_map.local_index_to_parent_map[ 7 ].should be parent_array_one

      index_map.local_index_to_parent_map[ 8 ].should be parent_array_three
      index_map.local_index_to_parent_map[ 9 ].should be parent_array_three
      index_map.local_index_to_parent_map[ 10 ].should be parent_array_three
      index_map.local_index_to_parent_map[ 11 ].should be parent_array_three
      
      index_map.parent_local_map( parent_array_two ).should be nil
      index_map.local_parent_map( parent_array_two ).should be nil
      
    end
  end
  
  ##################
  #  parent_array  #
  ##################
  
  context '#parent_array' do
    it 'will return parent array for local index' do
      index_map.parent_array( 0 ).should be nil
      index_map.parent_array( 1 ).should be nil
      index_map.parent_array( 2 ).should be nil
      index_map.parent_array( 3 ).should be nil

      index_map.parent_array( 4 ).should be parent_array_one
      index_map.parent_array( 5 ).should be parent_array_one
      index_map.parent_array( 6 ).should be parent_array_one
      index_map.parent_array( 7 ).should be parent_array_one

      index_map.parent_array( 8 ).should be parent_array_two
      index_map.parent_array( 9 ).should be parent_array_two
      index_map.parent_array( 10 ).should be parent_array_two
      index_map.parent_array( 11 ).should be parent_array_two

      index_map.parent_array( 12 ).should be parent_array_three
      index_map.parent_array( 13 ).should be parent_array_three
      index_map.parent_array( 14 ).should be parent_array_three
      index_map.parent_array( 15 ).should be parent_array_three
    end
  end
  
  ##################
  #  parent_index  #
  ##################

  context '#parent_index' do
    it 'will return a parent index for a local index' do
      index_map.parent_index( 0 ).should be nil
      index_map.parent_index( 1 ).should be nil
      index_map.parent_index( 2 ).should be nil
      index_map.parent_index( 3 ).should be nil

      index_map.parent_index( 4 ).should be 0
      index_map.parent_index( 5 ).should be 1
      index_map.parent_index( 6 ).should be 2
      index_map.parent_index( 7 ).should be 3

      index_map.parent_index( 8 ).should be 0
      index_map.parent_index( 9 ).should be 1
      index_map.parent_index( 10 ).should be 2
      index_map.parent_index( 11 ).should be 3

      index_map.parent_index( 12 ).should be 0
      index_map.parent_index( 13 ).should be 1
      index_map.parent_index( 14 ).should be 2
      index_map.parent_index( 15 ).should be 3
    end
  end

  #################
  #  local_index  #
  #################
  
  context '#local_index' do
    it 'will return a local index for a parent index' do
      index_map.local_index( parent_array_one, 0 ).should be 4
      index_map.local_index( parent_array_one, 1 ).should be 5
      index_map.local_index( parent_array_one, 2 ).should be 6
      index_map.local_index( parent_array_one, 3 ).should be 7

      index_map.local_index( parent_array_two, 0 ).should be 8
      index_map.local_index( parent_array_two, 1 ).should be 9
      index_map.local_index( parent_array_two, 2 ).should be 10
      index_map.local_index( parent_array_two, 3 ).should be 11

      index_map.local_index( parent_array_three, 0 ).should be 12
      index_map.local_index( parent_array_three, 1 ).should be 13
      index_map.local_index( parent_array_three, 2 ).should be 14
      index_map.local_index( parent_array_three, 3 ).should be 15

    end
  end
  
  ###################################
  #  parent_controls_parent_index?  #
  ###################################

  context '#parent_controls_parent_index?' do
    it 'will report if it has replaced a parent index referenced by parent index' do
      
      index_map.parent_controls_parent_index?( parent_array_one, 0 ).should == true
      index_map.parent_controls_parent_index?( parent_array_one, 1 ).should == true
      index_map.parent_controls_parent_index?( parent_array_one, 2 ).should == true
      index_map.parent_controls_parent_index?( parent_array_one, 3 ).should == true

      index_map.parent_controls_parent_index?( parent_array_two, 0 ).should == true
      index_map.parent_controls_parent_index?( parent_array_two, 1 ).should == true
      index_map.parent_controls_parent_index?( parent_array_two, 2 ).should == true
      index_map.parent_controls_parent_index?( parent_array_two, 3 ).should == true

      index_map.parent_controls_parent_index?( parent_array_three, 0 ).should == true
      index_map.parent_controls_parent_index?( parent_array_three, 1 ).should == true
      index_map.parent_controls_parent_index?( parent_array_three, 2 ).should == true
      index_map.parent_controls_parent_index?( parent_array_three, 3 ).should == true
    end
  end
  
  ##################################
  #  parent_controls_local_index?  #
  ##################################
  
  context '#parent_controls_local_index?' do
    context 'without providing parent array' do
      it 'will report if a parent controls local index' do
        index_map.parent_controls_local_index?( 0 ).should == false
        index_map.parent_controls_local_index?( 1 ).should == false
        index_map.parent_controls_local_index?( 2 ).should == false
        index_map.parent_controls_local_index?( 3 ).should == false

        index_map.parent_controls_local_index?( 4 ).should == true
        index_map.parent_controls_local_index?( 5 ).should == true
        index_map.parent_controls_local_index?( 6 ).should == true
        index_map.parent_controls_local_index?( 7 ).should == true

        index_map.parent_controls_local_index?( 8 ).should == true
        index_map.parent_controls_local_index?( 9 ).should == true
        index_map.parent_controls_local_index?( 10 ).should == true
        index_map.parent_controls_local_index?( 11 ).should == true

        index_map.parent_controls_local_index?( 12 ).should == true
        index_map.parent_controls_local_index?( 13 ).should == true
        index_map.parent_controls_local_index?( 14 ).should == true
        index_map.parent_controls_local_index?( 15 ).should == true
      end
    end
    context 'with parent array' do
      it 'will report if specified parent controls local index' do
        index_map.parent_controls_local_index?( 4, parent_array_two ).should == false
        index_map.parent_controls_local_index?( 5, parent_array_two ).should == false
        index_map.parent_controls_local_index?( 6, parent_array_two ).should == false
        index_map.parent_controls_local_index?( 7, parent_array_two ).should == false
        index_map.parent_controls_local_index?( 4, parent_array_one ).should == true
        index_map.parent_controls_local_index?( 5, parent_array_one ).should == true
        index_map.parent_controls_local_index?( 6, parent_array_one ).should == true
        index_map.parent_controls_local_index?( 7, parent_array_one ).should == true

        index_map.parent_controls_local_index?( 8, parent_array_one ).should == false
        index_map.parent_controls_local_index?( 9, parent_array_one ).should == false
        index_map.parent_controls_local_index?( 10, parent_array_one ).should == false
        index_map.parent_controls_local_index?( 11, parent_array_one ).should == false
        index_map.parent_controls_local_index?( 8, parent_array_two ).should == true
        index_map.parent_controls_local_index?( 9, parent_array_two ).should == true
        index_map.parent_controls_local_index?( 10, parent_array_two ).should == true
        index_map.parent_controls_local_index?( 11, parent_array_two ).should == true

        index_map.parent_controls_local_index?( 12, parent_array_two ).should == false
        index_map.parent_controls_local_index?( 13, parent_array_two ).should == false
        index_map.parent_controls_local_index?( 14, parent_array_two ).should == false
        index_map.parent_controls_local_index?( 15, parent_array_two ).should == false
        index_map.parent_controls_local_index?( 12, parent_array_three ).should == true
        index_map.parent_controls_local_index?( 13, parent_array_three ).should == true
        index_map.parent_controls_local_index?( 14, parent_array_three ).should == true
        index_map.parent_controls_local_index?( 15, parent_array_three ).should == true
      end
    end
  end
    
  ######################
  #  requires_lookup?  #
  ######################
  
  context '#requires_lookup?' do
    it 'will report whether index requires lookup in parent' do
      index_map.requires_lookup?( 0 ).should be false
      index_map.requires_lookup?( 1 ).should be false
      index_map.requires_lookup?( 2 ).should be false
      index_map.requires_lookup?( 3 ).should be false
      index_map.requires_lookup?( 4 ).should be true
      index_map.requires_lookup?( 5 ).should be true
      index_map.requires_lookup?( 6 ).should be true
      index_map.requires_lookup?( 7 ).should be true
      index_map.requires_lookup?( 8 ).should be true
      index_map.requires_lookup?( 9 ).should be true
      index_map.requires_lookup?( 10 ).should be true
      index_map.requires_lookup?( 11 ).should be true
      index_map.requires_lookup?( 12 ).should be true
      index_map.requires_lookup?( 13 ).should be true
      index_map.requires_lookup?( 14 ).should be true
      index_map.requires_lookup?( 15 ).should be true
    end
  end
  
  ##############################
  #  indexes_requiring_lookup  #
  ##############################
  
  context '#indexes_requiring_lookup' do
    it 'will return an array of indexes not yet looked up' do
      index_map.indexes_requiring_lookup.should == [ 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ]
    end
  end
  
  ################
  #  looked_up!  #
  ################
  
  context '#looked_up!' do
    before :each do
      index_map.looked_up!( 4 )
    end
    it 'will mark an index as looked up' do
      index_map.requires_lookup?( 4 ).should be false
    end
  end
  
  #######################################
  #  renumber_local_indexes_for_delete  #
  #######################################
  
  context '#renumber_local_indexes_for_delete' do
    before :each do
      index_map.renumber_local_indexes_for_delete( 7 )
    end
    it 'will renumber local indexes in parent => local maps for delete' do
      index_map.local_index( parent_array_one, 0 ).should be 4
      index_map.local_index( parent_array_one, 1 ).should be 5
      index_map.local_index( parent_array_one, 2 ).should be 6
      # we haven't yet actually deleted the index for which we are renumbering, so 7 is expected
      index_map.local_index( parent_array_one, 3 ).should be 7

      index_map.local_index( parent_array_two, 0 ).should be 7
      index_map.local_index( parent_array_two, 1 ).should be 8
      index_map.local_index( parent_array_two, 2 ).should be 9
      index_map.local_index( parent_array_two, 3 ).should be 10

      index_map.local_index( parent_array_three, 0 ).should be 11
      index_map.local_index( parent_array_three, 1 ).should be 12
      index_map.local_index( parent_array_three, 2 ).should be 13
      index_map.local_index( parent_array_three, 3 ).should be 14
    end
  end
  
  #######################################
  #  renumber_local_indexes_for_insert  #
  #######################################
  
  context '#renumber_local_indexes_for_insert' do
    before :each do
      index_map.renumber_local_indexes_for_insert( 7 )
    end
    it 'will renumber local indexes in parent => local maps for insert' do
      index_map.local_index( parent_array_one, 0 ).should be 4
      index_map.local_index( parent_array_one, 1 ).should be 5
      index_map.local_index( parent_array_one, 2 ).should be 6
      index_map.local_index( parent_array_one, 3 ).should be 8

      index_map.local_index( parent_array_two, 0 ).should be 9
      index_map.local_index( parent_array_two, 1 ).should be 10
      index_map.local_index( parent_array_two, 2 ).should be 11
      index_map.local_index( parent_array_two, 3 ).should be 12

      index_map.local_index( parent_array_three, 0 ).should be 13
      index_map.local_index( parent_array_three, 1 ).should be 14
      index_map.local_index( parent_array_three, 2 ).should be 15
      index_map.local_index( parent_array_three, 3 ).should be 16
    end
  end
  
  ########################################
  #  parent_insert_without_child_insert  #
  ########################################
  
  context '#parent_insert_without_child_insert' do
    before :each do
      index_map.parent_insert_without_child_insert( parent_array_one, 3, 2 )
    end
    it 'will update its internal parent-local maps' do
      index_map.local_index( parent_array_one, 0 ).should be 4
      index_map.local_index( parent_array_one, 1 ).should be 5
      index_map.local_index( parent_array_one, 2 ).should be 6
      index_map.local_index( parent_array_one, 3 ).should be 6
      index_map.local_index( parent_array_one, 4 ).should be 6
      index_map.local_index( parent_array_one, 5 ).should be 7
    end
  end
  
  ###################
  #  parent_insert  #
  ###################
  
  context '#parent_insert' do
    before :each do
      index_map
     parent_array_one.insert( 3, :P1_i3, :P1_i4 )
      array_instance.insert( 7, :P1_i3, :P1_i4 )
      index_map.parent_insert( parent_array_one, 3, 2 )
    end
    it 'will update its internal parent-local maps' do
      index_map.local_index( parent_array_one, 0 ).should be 4
      index_map.local_index( parent_array_one, 1 ).should be 5
      index_map.local_index( parent_array_one, 2 ).should be 6
      index_map.local_index( parent_array_one, 3 ).should be 7
      index_map.local_index( parent_array_one, 4 ).should be 8
      index_map.local_index( parent_array_one, 5 ).should be 9

      index_map.local_index( parent_array_two, 0 ).should be 10
      index_map.local_index( parent_array_two, 1 ).should be 11
      index_map.local_index( parent_array_two, 2 ).should be 12
      index_map.local_index( parent_array_two, 3 ).should be 13

      index_map.local_index( parent_array_three, 0 ).should be 14
      index_map.local_index( parent_array_three, 1 ).should be 15
      index_map.local_index( parent_array_three, 2 ).should be 16
      index_map.local_index( parent_array_three, 3 ).should be 17
      
      index_map.parent_array( 7 ).should be parent_array_one
      index_map.parent_array( 8 ).should be parent_array_one

      index_map.parent_index( 7, parent_array_one ).should be 3
      index_map.parent_index( 8, parent_array_one ).should be 4
    end
  end
    
  ##################
  #  local_insert  #
  ##################

  context '#local_insert' do
    before :each do
      index_map
      array_instance.insert( 7, :A_7, :A_8 )
      index_map.local_insert( 7, 2 )
    end
    it 'will update its internal parent-local maps' do
      index_map.local_index( parent_array_one, 0 ).should be 4
      index_map.local_index( parent_array_one, 1 ).should be 5
      index_map.local_index( parent_array_one, 2 ).should be 6
      index_map.local_index( parent_array_one, 3 ).should be 9

      index_map.local_index( parent_array_two, 0 ).should be 10
      index_map.local_index( parent_array_two, 1 ).should be 11
      index_map.local_index( parent_array_two, 2 ).should be 12
      index_map.local_index( parent_array_two, 3 ).should be 13

      index_map.local_index( parent_array_three, 0 ).should be 14
      index_map.local_index( parent_array_three, 1 ).should be 15
      index_map.local_index( parent_array_three, 2 ).should be 16
      index_map.local_index( parent_array_three, 3 ).should be 17
      
      index_map.parent_array( 7 ).should be nil
      index_map.parent_array( 8 ).should be nil

      index_map.parent_index( 7, parent_array_one ).should be nil
      index_map.parent_index( 8, parent_array_one ).should be nil
    end
  end

  ##################################
  #  parent_set_without_child_set  #
  ##################################
  
  context '#parent_set_without_child_set' do
    context 'when index >= parent size' do
      before :each do
        index_map
        parent_array_one[ 4 ] = :P1_i4
        index_map.parent_set_without_child_set( parent_array_one, 4 )
      end
      it 'will update its internal parent-local maps' do
        index_map.local_index( parent_array_one, 4 ).should be 7
      end
    end
    context 'when index < parent size' do
      before :each do
        index_map
        parent_array_one[ 2 ] = :P1_i2
        index_map.parent_set_without_child_set( parent_array_one, 2 )
      end
      it 'will update its internal parent-local maps' do
        index_map.local_index( parent_array_one, 2 ).should be 5
      end
    end
  end
  
  ################
  #  parent_set  #
  ################

  context '#parent_set' do
    context 'when parent set outside existing parent elements' do
      before :each do
        index_map
        parent_array_one[ 4 ] = :P1_s4
        array_instance.insert( 8, :P1_s4 )
        index_map.parent_set( parent_array_one, 4 )
      end
      it 'will set in child, updating map accordingly' do
        index_map.parent_array( 8 ).should be parent_array_one
        index_map.parent_index( 8 ).should be 4
        index_map.local_index( parent_array_one, 4 ).should be 8
      end
    end
    
    context 'when parent set inside existing parent elements' do
      before :each do
        index_map
        parent_array_one[ 2 ] = :P1_s2
        index_map.parent_set( parent_array_one, 2 )
      end
      it 'will set in child, updating map accordingly' do
        index_map.parent_array( 6 ).should be parent_array_one
        index_map.parent_index( 6 ).should be 2
        index_map.local_index( parent_array_one, 2 ).should be 6
      end
    end
    
    context 'when parent set inside existing parent elements but element has been replaced' do
      before :each do
        index_map.local_set( 6 )
        parent_array_one[ 2 ] = :P1_s2
        index_map.parent_set( parent_array_one, 2 )
      end
      it 'will not set in child' do
        index_map.parent_array( 6 ).should be nil
        index_map.parent_index( 6 ).should be nil
        index_map.local_index( parent_array_one, 2 ).should be 6
      end
    end

  end

  ###############
  #  local_set  #
  ###############
  
  context '#local_set' do

    context 'when outside parent elements' do
      before :each do
        index_map
        array_instance[ 16 ] = :A_16
        index_map.local_set( 16 )
      end
      it 'will update its internal parent-local maps for a local set outside parent elements' do
        index_map.parent_array( 16 ).should be nil
        index_map.parent_index( 16 ).should be nil
      end
    end
    
    context 'when inside parent elements but over existing local element' do
      before :each do
        index_map
        array_instance[ 2 ] = :A_s7
        index_map.local_set( 2 )
      end
      it 'will update its internal parent-local maps for a local set outside parent elements' do
        index_map.parent_array( 2 ).should be nil
        index_map.parent_index( 2 ).should be nil
      end
    end

    context 'when over parent element' do
      before :each do
        index_map
        array_instance[ 7 ] = :A_s7
        index_map.local_set( 7 )
      end
      it 'will track local data for local set over a parent element' do
        index_map.parent_array( 7 ).should be nil
        index_map.parent_index( 7 ).should be nil
        index_map.local_index( parent_array_one, 3 ).should be 7
      end
    end
    
  end
  
  ######################
  #  parent_delete_at  #
  ######################

  context '#parent_delete_at' do
    
    context 'when parent controls local element' do
      before :each do
        index_map.parent_delete_at( parent_array_one, 0 )
      end
      it 'will delete local element' do
        index_map.parent_index( 4 ).should be 0
        index_map.parent_index( 5 ).should be 1
        index_map.parent_index( 6 ).should be 2
        index_map.parent_index( 7, parent_array_one ).should be nil
      end
    end

    context 'when local has replaced element' do
      before :each do
        index_map.local_set( 4 )
        index_map.parent_delete_at( parent_array_one, 0 )
      end
      it 'will update maps but not delete local element' do
        index_map.parent_index( 4 ).should be nil
        index_map.parent_array( 4 ).should be nil
        index_map.parent_index( 5 ).should be 0
        index_map.parent_index( 6 ).should be 1
        index_map.parent_index( 7 ).should be 2
      end
    end

    context 'when local has deleted element' do
      before :each do
        index_map.local_delete_at( 4 )
        index_map.parent_delete_at( parent_array_one, 0 )
      end
      it 'will update maps but not change local' do
        index_map.parent_index( 4 ).should be 0
        index_map.parent_index( 5 ).should be 1
        index_map.parent_index( 6 ).should be 2
        index_map.parent_index( 7, parent_array_one ).should be nil
      end
    end
    
  end

  #####################
  #  local_delete_at  #
  #####################

  context '#local_delete_at' do
    context 'when no parent element' do
      before :each do
        index_map.local_delete_at( 0 )
      end
      it 'will delete local' do
        index_map.parent_index( 3 ).should be 0
        index_map.parent_index( 4 ).should be 1
        index_map.parent_index( 5 ).should be 2
        index_map.parent_index( 6 ).should be 3
      end
    end
    context 'when controlled by parent element' do
      before :each do
        index_map.local_delete_at( 4 )
      end
      it 'will delete local and adjust maps' do
        index_map.parent_index( 4 ).should be 1
        index_map.parent_index( 5 ).should be 2
        index_map.parent_index( 6 ).should be 3
      end
    end
  end

  ####################
  #  parent_reorder  #
  ####################
  
  context '#parent_reorder' do
    let( :new_parent_one_order ) { [ 3, 2, 0, 1 ] }
    let( :new_local_order ) { index_map.parent_reorder( parent_array_one, new_parent_one_order ) }
    it 'will reorder maps based on new order' do
      new_local_order.should == [ nil, nil, nil, nil, 7, 6, 4, 5 ]

      index_map.parent_array( 0 ).should be nil
      index_map.parent_array( 1 ).should be nil
      index_map.parent_array( 2 ).should be nil
      index_map.parent_array( 3 ).should be nil
      index_map.parent_index( 0 ).should be nil
      index_map.parent_index( 1 ).should be nil
      index_map.parent_index( 2 ).should be nil
      index_map.parent_index( 3 ).should be nil

      index_map.parent_array( 4 ).should be parent_array_one
      index_map.parent_array( 5 ).should be parent_array_one
      index_map.parent_array( 6 ).should be parent_array_one
      index_map.parent_array( 7 ).should be parent_array_one
      index_map.parent_index( 4 ).should be 3
      index_map.parent_index( 5 ).should be 2
      index_map.parent_index( 6 ).should be 0
      index_map.parent_index( 7 ).should be 1

      index_map.parent_array( 8 ).should be parent_array_two
      index_map.parent_array( 9 ).should be parent_array_two
      index_map.parent_array( 10 ).should be parent_array_two
      index_map.parent_array( 11 ).should be parent_array_two
      index_map.parent_index( 8 ).should be 0
      index_map.parent_index( 9 ).should be 1
      index_map.parent_index( 10 ).should be 2
      index_map.parent_index( 11 ).should be 3

      index_map.parent_array( 12 ).should be parent_array_three
      index_map.parent_array( 13 ).should be parent_array_three
      index_map.parent_array( 14 ).should be parent_array_three
      index_map.parent_array( 15 ).should be parent_array_three
      index_map.parent_index( 12 ).should be 0
      index_map.parent_index( 13 ).should be 1
      index_map.parent_index( 14 ).should be 2
      index_map.parent_index( 15 ).should be 3

    end
  end

  ###################
  #  local_reorder  #
  ###################

  context '#local_reorder' do
    let( :new_local_order ) { [ 12, 3,  5,  11, 
                                2,  9,  10, 7, 
                                1,  8,  0,  4, 
                                6,  15, 14, 13 ] }
    before :each do
      index_map.local_reorder( new_local_order )
    end
    it 'will reorder maps based on new order' do
      index_map.parent_array( 0 ).should be parent_array_three
      index_map.parent_array( 1 ).should be nil
      index_map.parent_array( 2 ).should be parent_array_one
      index_map.parent_array( 3 ).should be parent_array_two
      
      index_map.parent_array( 4 ).should be nil
      index_map.parent_array( 5 ).should be parent_array_two
      index_map.parent_array( 6 ).should be parent_array_two
      index_map.parent_array( 7 ).should be parent_array_one

      index_map.parent_array( 8 ).should be nil
      index_map.parent_array( 9 ).should be parent_array_two
      index_map.parent_array( 10 ).should be nil
      index_map.parent_array( 11 ).should be parent_array_one

      index_map.parent_array( 12 ).should be parent_array_one
      index_map.parent_array( 13 ).should be parent_array_three
      index_map.parent_array( 14 ).should be parent_array_three
      index_map.parent_array( 15 ).should be parent_array_three
    end
  end

  #################
  #  parent_move  #
  #################

  context '#parent_move' do
    it '' do
    end
  end

  ################
  #  local_move  #
  ################

  context '#local_move' do
    it '' do
    end
  end

  #################
  #  parent_swap  #
  #################

  context '#parent_swap' do
    it '' do
    end
  end

  ################
  #  local_swap  #
  ################

  context '#local_swap' do
    it '' do
    end
  end

end
