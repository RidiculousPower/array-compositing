# -*- encoding : utf-8 -*-

require_relative '../../../lib/array-compositing.rb'

describe ::Array::Compositing::CascadeController do
  
  let( :array_instance ) { [ ] }
  let( :index_map ) do
    index_map = ::Array::Compositing::CascadeController.new( array_instance )
    index_map.register_parent( parent_array_one, parent_one_insert_index )
    index_map.register_parent( parent_array_two, parent_two_insert_index )
    index_map.register_parent( parent_array_three, parent_three_insert_index )
    index_map
  end

  let( :parent_array_one ) { [ ] }
  let( :parent_index_map_one ) { ::Array::Compositing::CascadeController.new( parent_array ) }

  let( :parent_array_two ) { [ ] }
  let( :parent_index_map_two ) { ::Array::Compositing::CascadeController.new( parent_array_two ) }

  let( :parent_array_three ) { [ ] }
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
    end
  end
  
  ######################
  #  parent_local_map  #
  ######################
  
  shared_examples_for :index_maps do
    def parent_map( parent_array )
      return index_map.__send__( index_map_method, parent_array )
    end
    let( :parent_one_map ) { parent_map( parent_array_one ) }
    let( :parent_two_map ) { parent_map( parent_array_two ) }
    let( :parent_three_map ) { parent_map( parent_array_three ) }
    it 'parent one has its own IndexMap' do
      parent_one_map.should be_a ::Array::Compositing::CascadeController::IndexMap
      parent_one_map.should be parent_map( parent_array_one )
      parent_one_map.should_not be parent_two_map
      parent_one_map.should_not be parent_three_map
    end
    it 'parent two has its own IndexMap' do
      parent_two_map.should be_a ::Array::Compositing::CascadeController::IndexMap
      parent_two_map.should be parent_map( parent_array_two )
      parent_two_map.should_not be parent_one_map
      parent_two_map.should_not be parent_three_map
    end
    it 'parent three has its own IndexMap' do
      parent_three_map.should be_a ::Array::Compositing::CascadeController::IndexMap
      parent_three_map.should be parent_map( parent_array_three )
      parent_three_map.should_not be parent_one_map
      parent_three_map.should_not be parent_two_map
    end
  end

  context '#parent_local_map' do
    it_behaves_like( :index_maps ) { let( :index_map_method ) { :parent_local_map } }
  end

  ######################
  #  local_parent_map  #
  ######################

  context '#local_parent_map' do
    it_behaves_like( :index_maps ) { let( :index_map_method ) { :local_parent_map } }
  end
  
  ######################
  #  index_for_offset  #
  ######################

  context '#index_for_offset' do
    def index_for_offset( index )
      return index_map.index_for_offset( index )
    end
    context 'when empty' do
      it 'will return positive index' do
      end
      it 'will return positive index for negative offset' do
      end
      it 'will return nil for offset greater than size' do
      end
    end
    context 'when contents' do
      it 'will return positive index' do
      end
      it 'will return positive index for negative offset' do
      end
      it 'will return nil for offset greater than size' do
      end
    end
    it 'will translate an offset (positive or negative) into an index' do
      index_for_offset( 0 ).should == 0
      index_for_offset( 1 ).should == 1
      index_for_offset( -1 ).should == 0
      index_for_offset( -2 ).should == 0

      index_map.array_instance.insert( 0, 1, 2, 3, 4, 5 )
      index_map.local_insert( 0, 5 )

      index_for_offset( 0 ).should == 0
      index_for_offset( 1 ).should == 1
      index_for_offset( 3 ).should == 3
      index_for_offset( 5 ).should == 5
      index_for_offset( -1 ).should == 5
      index_for_offset( -3 ).should == 3
      index_for_offset( -5 ).should == 1
      index_for_offset( -7 ).should == 0
    end
  end
  
  #######################################
  #  renumber_local_indexes_for_delete  #
  #######################################
  
  context '#renumber_local_indexes_for_delete' do
  end
  
  #######################################
  #  renumber_local_indexes_for_insert  #
  #######################################
  
  context '#renumber_local_indexes_for_insert' do
  end
  
  #####################
  #  register_parent  #
  #####################
  
  context '#register_parent' do
    let( :parent_local_map_one ) { index_map.parent_local_map( parent_index_map ) }
    let( :parent_local_map_two ) { index_map.parent_local_map( parent_index_map_two ) }
    let( :parent_local_map_three ) { index_map.parent_local_map( parent_index_map_three ) }
    it 'will track where parent elements insert in array instance' do
      index_map.register_parent( parent_index_map )
      index_map.register_parent( parent_index_map_two )
      index_map.register_parent( parent_index_map_three )

      parent_local_map_one.is_a?( ::Array ).should == true
      parent_local_map_two.is_a?( ::Array ).should == true
      parent_local_map_three.is_a?( ::Array ).should == true
      
      parent_local_map_one.should_not be parent_local_map_two
      parent_local_map_one.should_not be parent_local_map_three
      parent_local_map_two.should_not be parent_local_map_one
      parent_local_map_two.should_not be parent_local_map_three
      parent_local_map_three.should_not be parent_local_map_one
      parent_local_map_three.should_not be parent_local_map_two
    end
  end

  #######################
  #  unregister_parent  #
  #######################

  context '#unregister_parent' do
    let( :local_parent_map ) { index_map.instance_variable_get( :@local_index_to_parent ) }
    let( :parent_array ) { [ 1, 2, 3 ] }
    let( :parent_array_two ) { [ 1, 2 ] }
    let( :parent_array_three ) { [ 1, 2, 3, 4 ] }
    let( :parent_one_insert_index ) { 0 }
    let( :parent_two_insert_index ) { 0 }
    let( :parent_three_insert_index ) { 0 }
    it 'will unregister parents' do

      local_parent_map[ 0 ].parent_map.should == parent_index_map
      local_parent_map[ 0 ].parent_index.should == 0
      local_parent_map[ 1 ].parent_map.should == parent_index_map
      local_parent_map[ 1 ].parent_index.should == 1
      local_parent_map[ 2 ].parent_map.should == parent_index_map
      local_parent_map[ 2 ].parent_index.should == 2

      local_parent_map[ 3 ].parent_map.should == parent_index_map_two
      local_parent_map[ 3 ].parent_index.should == 0
      local_parent_map[ 4 ].parent_map.should == parent_index_map_two
      local_parent_map[ 4 ].parent_index.should == 1

      local_parent_map[ 5 ].parent_map.should == parent_index_map_three
      local_parent_map[ 5 ].parent_index.should == 0
      local_parent_map[ 6 ].parent_map.should == parent_index_map_three
      local_parent_map[ 6 ].parent_index.should == 1
      local_parent_map[ 7 ].parent_map.should == parent_index_map_three
      local_parent_map[ 7 ].parent_index.should == 2
      local_parent_map[ 8 ].parent_map.should == parent_index_map_three
      local_parent_map[ 8 ].parent_index.should == 3

      index_map.unregister_parent( parent_index_map_two )

      local_parent_map[ 0 ].parent_map.should == parent_index_map
      local_parent_map[ 0 ].parent_index.should == 0
      local_parent_map[ 1 ].parent_map.should == parent_index_map
      local_parent_map[ 1 ].parent_index.should == 1
      local_parent_map[ 2 ].parent_map.should == parent_index_map
      local_parent_map[ 2 ].parent_index.should == 2

      local_parent_map[ 3 ].parent_map.should == parent_index_map_three
      local_parent_map[ 3 ].parent_index.should == 0
      local_parent_map[ 4 ].parent_map.should == parent_index_map_three
      local_parent_map[ 4 ].parent_index.should == 1
      local_parent_map[ 5 ].parent_map.should == parent_index_map_three
      local_parent_map[ 5 ].parent_index.should == 2
      local_parent_map[ 6 ].parent_map.should == parent_index_map_three
      local_parent_map[ 6 ].parent_index.should == 3

    end
  end
  
  ##################
  #  parent_array  #
  ##################
  
  context '#parent_array' do
  end
  
  ##################
  #  parent_index  #
  ##################

  context '#parent_index' do
    let( :parent_array ) { [ 1 ] }
    let( :parent_struct ) { index_map.parent_index( 0 ) }
    it 'will return a parent index struct for a local index' do
      parent_struct.parent_map.should be parent_index_map
      parent_struct.parent_index.should == 0
    end
  end

  #################
  #  local_index  #
  #################
  
  context '#local_index' do
    let( :parent_array ) { [ 1, 2, 3, 4, 5 ] }
    it 'will return a local index for a parent index' do
      index_map.local_index( parent_index_map, 4 ).should == 4
    end
  end
  
  ###################################
  #  parent_controls_parent_index?  #
  ###################################

  context '#parent_controls_parent_index?' do
    let( :parent_array ) { [ 1, 2 ] }
    it 'will report if it has replaced a parent index referenced by parent index' do
      index_map.parent_controls_parent_index?( parent_index_map, 0 ).should == true
      index_map.parent_controls_parent_index?( parent_index_map, 1 ).should == true
      index_map.local_set( 1 )
      index_map.local_delete_at( 0 )
      index_map.parent_controls_parent_index?( parent_index_map, 0 ).should == false
      index_map.parent_controls_parent_index?( parent_index_map, 1 ).should == false
    end
  end
  
  ##################################
  #  parent_controls_local_index?  #
  ##################################
  
  context '#parent_controls_local_index?' do
    let( :parent_array ) { [ 1, 2 ] }
    it 'will report if it has replaced a parent index referenced by local index' do
      index_map.parent_controls_local_index?( 0 ).should == true
      index_map.parent_controls_local_index?( 1 ).should == true

      index_map.local_set( 1 )

      index_map.parent_controls_local_index?( 0 ).should == true
      index_map.parent_controls_local_index?( 1 ).should == false
    end
  end
    
  ######################
  #  requires_lookup?  #
  ######################
  
  context '#requires_lookup?' do
  end
  
  ##############################
  #  indexes_requiring_lookup  #
  ##############################
  
  context '#indexes_requiring_lookup' do
  end
  
  ################
  #  looked_up!  #
  ################
  
  context '#looked_up!' do
  end
  
  ########################################
  #  parent_insert_without_child_insert  #
  ########################################
  
  context '#parent_insert_without_child_insert' do
  end
  
  ###################
  #  parent_insert  #
  ###################
  
  context '#parent_insert' do
    context 'parent members no child members' do
      let( :parent_array ) { [ 1, 2 ] }
      it 'will update its internal parent-local maps for a parent insert with no children' do
        parent_struct0 = index_map.parent_index( 0 )
        parent_struct0.parent_index.should == 0
        parent_struct0.parent_map.should == parent_index_map
        index_map.local_index( parent_index_map, 0 ).should == 0
        index_map.requires_lookup?( 0 ).should == true
        index_map.requires_lookup?( 1 ).should == true
        index_map.looked_up!( 0 )
        index_map.looked_up!( 1 )
        index_map.requires_lookup?( 0 ).should == false
        index_map.requires_lookup?( 1 ).should == false
      end
    end
    
    context 'child members no parent members' do
      let( :array_instance ) { [ 1, 2 ] }
      it 'will update its internal parent-local maps for a parent insert with children' do
        index_map.parent_index( 0 ).should == nil
        index_map.local_index( parent_index_map, 0 ).should == nil
        index_map.parent_insert( parent_index_map, 0, 2 )

        parent_struct0 = index_map.parent_index( 0 )
        parent_struct0.parent_index.should == 0
        parent_struct0.parent_map.should == parent_index_map
        
        parent_struct1 = index_map.parent_index( 1 )
        parent_struct1.parent_index.should == 1
        parent_struct1.parent_map.should == parent_index_map

        index_map.local_index( parent_index_map, 0 ).should == 0
        index_map.local_index( parent_index_map, 1 ).should == 1
        index_map.local_index( parent_index_map, 2 ).should == nil
        index_map.local_index( parent_index_map, 3 ).should == nil
        index_map.requires_lookup?( 0 ).should == true
        index_map.requires_lookup?( 1 ).should == true
        index_map.looked_up!( 0 )
        index_map.looked_up!( 1 )
        index_map.requires_lookup?( 0 ).should == false
        index_map.requires_lookup?( 1 ).should == false
      end
    end
  end
    
  ##################
  #  local_insert  #
  ##################

  context '#local_insert' do
    it 'will insert and modify parent mappings accordingly' do
      index_map.local_insert( 0, 2 )
      index_map.parent_index( 0 ).should == nil
      index_map.local_index( parent_index_map, 0 ).should == nil
      index_map.requires_lookup?( 0 ).should == false
      index_map.requires_lookup?( 1 ).should == false
    end
  end

  ##################################
  #  parent_set_without_child_set  #
  ##################################
  
  context '#parent_set_without_child_set' do
  end
  
  ################
  #  parent_set  #
  ################

  context '#parent_set' do
    let( :array_instance ) { [ 1, 2 ] }
    let( :parent_array ) { [ 1, 2 ] }
    let( :parent_one_insert_index ) { 0 }
    context 'when parent set outside existing parent elements' do
      it 'will set in child, updating map accordingly' do

        index_map.parent_set( parent_index_map, 2 )

        parent_index_struct0 = index_map.parent_index( 0 )
        parent_index_struct0.parent_index.should == 0
        parent_index_struct0.parent_map.should == parent_index_map

        parent_index_struct1 = index_map.parent_index( 1 )
        parent_index_struct1.parent_index.should == 1
        parent_index_struct1.parent_map.should == parent_index_map

        parent_index_struct2 = index_map.parent_index( 2 )
        parent_index_struct2.parent_index.should == 2
        parent_index_struct2.parent_map.should == parent_index_map

        index_map.local_index( parent_index_map, 0 ).should == 0
        index_map.local_index( parent_index_map, 1 ).should == 1
        index_map.local_index( parent_index_map, 2 ).should == 2
        index_map.local_index( parent_index_map, 3 ).should == nil
        index_map.local_index( parent_index_map, 4 ).should == nil
        index_map.requires_lookup?( 0 ).should == true
        index_map.requires_lookup?( 1 ).should == true
        index_map.requires_lookup?( 2 ).should == true
        index_map.requires_lookup?( 3 ).should == false
        index_map.looked_up!( 0 )
        index_map.looked_up!( 1 )
        index_map.requires_lookup?( 0 ).should == false
        index_map.requires_lookup?( 1 ).should == false

      end
    end
    
    context 'when parent set inside existing parent elements' do
      it 'will set in child, updating map accordingly' do
        index_map.parent_set( parent_index_map, 1 )
        
        parent_index_struct0 = index_map.parent_index( 0 )
        parent_index_struct0.parent_index.should == 0
        parent_index_struct0.parent_map.should == parent_index_map
        
        parent_index_struct1 = index_map.parent_index( 1 )
        parent_index_struct1.parent_index.should == 1
        parent_index_struct1.parent_map.should == parent_index_map
        
        index_map.local_index( parent_index_map, 0 ).should == 0
        index_map.local_index( parent_index_map, 1 ).should == 1
        index_map.local_index( parent_index_map, 2 ).should == nil
        index_map.local_index( parent_index_map, 3 ).should == nil
        index_map.requires_lookup?( 0 ).should == true
        index_map.requires_lookup?( 1 ).should == true
        index_map.requires_lookup?( 2 ).should == false
        index_map.requires_lookup?( 3 ).should == false
        index_map.looked_up!( 0 )
        index_map.looked_up!( 1 )
        index_map.requires_lookup?( 0 ).should == false
        index_map.requires_lookup?( 1 ).should == false
      end
    end
    
    context 'when parent set inside existing parent elements but element has been replaced' do
      it 'will not set in child' do
        index_map.local_set( 1 )
        index_map.parent_set( parent_index_map, 1 )
        
        parent_index_struct0 = index_map.parent_index( 0 )
        parent_index_struct0.parent_index.should == 0
        parent_index_struct0.parent_map.should == parent_index_map
        
        index_map.parent_index( 1 ).should == nil
        
        index_map.local_index( parent_index_map, 0 ).should == 0
        index_map.local_index( parent_index_map, 1 ).should == 1
        index_map.local_index( parent_index_map, 2 ).should == nil
        index_map.local_index( parent_index_map, 3 ).should == nil
        index_map.requires_lookup?( 0 ).should == true
        index_map.requires_lookup?( 1 ).should == false
        index_map.requires_lookup?( 2 ).should == false
        index_map.requires_lookup?( 3 ).should == false
        index_map.looked_up!( 0 )
        index_map.looked_up!( 1 )
        index_map.requires_lookup?( 0 ).should == false
        index_map.requires_lookup?( 1 ).should == false
      end
    end

  end

  ###############
  #  local_set  #
  ###############
  
  context '#local_set' do
    context 'when no parent elements' do
      it 'will track local data to map where parent data goes' do
        index_map.local_set( 0 )
        index_map.parent_index( 0 ).should == nil
        index_map.local_index( parent_index_map, 0 ).should == nil
        index_map.requires_lookup?( 0 ).should == false
      end
    end

    context 'when outside parent elements' do
      let( :parent_array ) { [ 1, 2 ] }
      it 'will update its internal parent-local maps for a local set outside parent elements' do
        index_map.local_set( 2 )
        
        parent_index_struct0 = index_map.parent_index( 0 )
        parent_index_struct0.parent_index.should == 0
        parent_index_struct0.parent_map.should == parent_index_map
        
        parent_index_struct1 = index_map.parent_index( 1 )
        parent_index_struct1.parent_index.should == 1
        parent_index_struct1.parent_map.should == parent_index_map
        
        index_map.local_index( parent_index_map, 0 ).should == 0
        index_map.local_index( parent_index_map, 1 ).should == 1
        index_map.local_index( parent_index_map, 2 ).should == nil
        index_map.requires_lookup?( 0 ).should == true
        index_map.requires_lookup?( 1 ).should == true
        index_map.requires_lookup?( 2 ).should == false
        index_map.looked_up!( 0 )
        index_map.looked_up!( 1 )
        index_map.requires_lookup?( 0 ).should == false
        index_map.requires_lookup?( 1 ).should == false
      end
    end
    
    context 'when inside parent elements but over existing local element' do
      let( :parent_array ) { [ 1, 2 ] }
      it 'will update its internal parent-local maps for a local set outside parent elements' do
        index_map.local_set( 1 )
        
        parent_index_struct0 = index_map.parent_index( 0 )
        parent_index_struct0.parent_index.should == 0
        parent_index_struct0.parent_map.should == parent_index_map
        
        index_map.parent_index( 1 ).should be nil
        
        index_map.local_index( parent_index_map, 0 ).should == 0
        index_map.local_index( parent_index_map, 1 ).should == 1
        index_map.requires_lookup?( 0 ).should == true
        index_map.requires_lookup?( 1 ).should == false
      end
    end

    context 'when over parent element' do
      let( :parent_array ) { [ 1, 2 ] }
      it 'will track local data for local set over a parent element' do
        index_map.local_set( 0 )
        index_map.parent_index( 0 ).should == nil
        
        parent_index_struct0 = index_map.parent_index( 1 )
        parent_index_struct0.parent_index.should == 1
        parent_index_struct0.parent_map.should == parent_index_map
        
        index_map.local_index( parent_index_map, 0 ).should == 0
        index_map.local_index( parent_index_map, 1 ).should == 1
        index_map.requires_lookup?( 0 ).should == false
        index_map.requires_lookup?( 1 ).should == true
        index_map.looked_up!( 1 )
        index_map.requires_lookup?( 1 ).should == false
      end
    end
    
  end
  
  ######################
  #  parent_delete_at  #
  ######################

  context '#parent_delete_at' do
    let( :parent_array ) { [ 1, 2 ] }
    it 'will update its internal parent-local maps for a parent delete with no child elements' do
      index_map.parent_delete_at( parent_index_map, 1 )

      parent_index_struct = index_map.parent_index( 0 )
      parent_index_struct.parent_index.should == 0
      parent_index_struct.parent_map.should == parent_index_map

      index_map.parent_index( 1 ).should == nil
      index_map.local_index( parent_index_map, 0 ).should == 0
      index_map.local_index( parent_index_map, 1 ).should == nil
      index_map.requires_lookup?( 0 ).should == true
      index_map.requires_lookup?( 1 ).should == false
    end

    it 'will update its internal parent-local maps for a parent delete with replaced child elements' do
      index_map.local_set( 1 )
      index_map.parent_delete_at( parent_index_map, 1 )
      parent_index_struct = index_map.parent_index( 0 )
      parent_index_struct.parent_index.should == 0
      parent_index_struct.parent_map.should == parent_index_map
      index_map.parent_index( 1 ).should == nil
      index_map.local_index( parent_index_map, 0 ).should == 0
      index_map.local_index( parent_index_map, 1 ).should == nil
      index_map.instance_variable_get( :@local_index_to_parent ).size.should == 2
      index_map.requires_lookup?( 0 ).should == true
      index_map.requires_lookup?( 1 ).should == false
      index_map.looked_up!( 0 )
      index_map.requires_lookup?( 0 ).should == false
    end
  end

  #####################
  #  local_delete_at  #
  #####################

  context '#local_delete_at' do
    let( :parent_array ) { [ 1, 2 ] }
    it 'will update its internal parent-local maps for a local delete of parent elements' do
      index_map.local_delete_at( 1 )
      parent_index_struct = index_map.parent_index( 0 )
      parent_index_struct.parent_index.should == 0
      parent_index_struct.parent_map.should == parent_index_map
      index_map.parent_index( 1 ).should == nil
      index_map.local_index( parent_index_map, 0 ).should == 0
      index_map.local_index( parent_index_map, 1 ).should == 0
      index_map.requires_lookup?( 0 ).should == true
      index_map.requires_lookup?( 1 ).should == false
      index_map.looked_up!( 0 )
      index_map.requires_lookup?( 0 ).should == false
    end

    it 'will update its internal parent-local maps for a local delete inside parents of a non-parent element' do
      index_map.local_insert( 1, 1 )
      index_map.local_delete_at( 1 )

      parent_index_struct0 = index_map.parent_index( 0 )
      parent_index_struct0.parent_index.should == 0
      parent_index_struct0.parent_map.should == parent_index_map

      parent_index_struct1 = index_map.parent_index( 1 )
      parent_index_struct1.parent_index.should == 1
      parent_index_struct1.parent_map.should == parent_index_map

      index_map.local_index( parent_index_map, 0 ).should == 0
      index_map.local_index( parent_index_map, 1 ).should == 1
      index_map.requires_lookup?( 0 ).should == true
      index_map.requires_lookup?( 1 ).should == true
      index_map.looked_up!( 0 )
      index_map.looked_up!( 1 )
      index_map.requires_lookup?( 0 ).should == false
      index_map.requires_lookup?( 1 ).should == false
    end

    it 'will update its internal parent-local maps for a local delete outside parents' do
      index_map.local_insert( 2, 2 )
      index_map.local_delete_at( 3 )
      
      parent_index_struct0 = index_map.parent_index( 0 )
      parent_index_struct0.parent_index.should == 0
      parent_index_struct0.parent_map.should == parent_index_map

      parent_index_struct1 = index_map.parent_index( 1 )
      parent_index_struct1.parent_index.should == 1
      parent_index_struct1.parent_map.should == parent_index_map

      index_map.local_index( parent_index_map, 0 ).should == 0
      index_map.local_index( parent_index_map, 1 ).should == 1
      index_map.requires_lookup?( 0 ).should == true
      index_map.requires_lookup?( 1 ).should == true
      index_map.requires_lookup?( 2 ).should == false
      index_map.requires_lookup?( 3 ).should == false
      index_map.looked_up!( 0 )
      index_map.looked_up!( 1 )
      index_map.requires_lookup?( 0 ).should == false
      index_map.requires_lookup?( 1 ).should == false
    end
  end

end
