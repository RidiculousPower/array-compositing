
require_relative '../../../lib/array-compositing.rb'

describe ::Array::Compositing::ParentIndexMap do

  #####################
  #  register_parent  #
  #####################

  it 'can register parents' do
    module ::Array::Compositing::ParentIndexMap::RegisterParentMock
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        parent_instance = ::Array.new
        register_parent( parent_instance )
        @parent_local_maps[ parent_instance.__id__ ].is_a?( ::Array ).should == true
        parent_instance2 = ::Array.new
        register_parent( parent_instance2 )
        @parent_local_maps[ parent_instance2.__id__ ].is_a?( ::Array ).should == true
        parent_instance3 = ::Array.new
        register_parent( parent_instance3 )
        @parent_local_maps[ parent_instance3.__id__ ].is_a?( ::Array ).should == true
      end
    end
  end

  ######################
  #  index_for_offset  #
  ######################

  it 'can translate an offset (positive or negative) into an index' do
    module ::Array::Compositing::ParentIndexMap::IndexForOffsetMock
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        index_for_offset( 0 ).should == 0
        index_for_offset( 1 ).should == 1
        index_for_offset( -1 ).should == 0
        index_for_offset( -2 ).should == 0
        local_insert( 0, 6 )
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
  end

  #############################
  #  inside_parent_elements?  #
  #############################
  
  it 'can report whether a local index is inside the range of parent elements' do
    module ::Array::Compositing::ParentIndexMap::InsideParentElementsMock
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        # mock the count
        @first_index_after_last_parent_element = 4
        inside_parent_elements?( 3 ).should == true
        inside_parent_elements?( 0 ).should == true
        inside_parent_elements?( 4 ).should == false
        inside_parent_elements?( 6 ).should == false
      end
    end
  end
  
  ##################
  #  parent_index  #
  #  local_index   #
  ##################
  
  it 'can return a parent index for a local index or local index for a parent index given two sets of maps that it tracks internally' do
    module ::Array::Compositing::ParentIndexMap::ParentIndexMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        # mock the parent-local arrays
        @parent_local_maps[ parent_instance_mock.__id__ ] = [ 0, 1, 2, 3, 4 ]
        @local_parent_map = [ 0, 1, 2, 3, 4 ]
        parent_index( 0 ).should == 0
        local_index( parent_instance_mock, 4 ).should == 4
      end
    end
  end

  ################################################
  #  replaced_parent_element_with_parent_index?  #
  ################################################

  it 'can report if it has replaced a parent index referenced by parent index' do
    module ::Array::Compositing::ParentIndexMap::ReplacedParentElementWithParentIndexMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        replaced_parent_element_with_parent_index?( parent_instance_mock, 0 ).should == false
        replaced_parent_element_with_parent_index?( parent_instance_mock, 1 ).should == false
        local_set( 1 )
        local_delete_at( 0 )
        replaced_parent_element_with_parent_index?( parent_instance_mock, 0 ).should == true
        replaced_parent_element_with_parent_index?( parent_instance_mock, 1 ).should == true
      end
    end
  end
  
  ###############################################
  #  replaced_parent_element_with_local_index?  #
  ###############################################
  
  it 'can report if it has replaced a parent index referenced by local index' do
    module ::Array::Compositing::ParentIndexMap::ReplacedParentElementWithLocalIndexMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        replaced_parent_element_with_local_index?( 0 ).should == false
        replaced_parent_element_with_local_index?( 1 ).should == false
        local_set( 1 )
        replaced_parent_element_with_local_index?( 0 ).should == false
        replaced_parent_element_with_local_index?( 1 ).should == true
      end
    end
  end
  

  ###################
  #  parent_insert  #
  ###################
  
  it 'can update its internal parent-local maps for a parent insert with no children' do
    module ::Array::Compositing::ParentIndexMap::ParentInsertMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        local_index( parent_instance_mock, 0 ).should == 0
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == true
        looked_up!( 0 )
        looked_up!( 1 )
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end

  it 'can update its internal parent-local maps for a parent insert with children' do
    module ::Array::Compositing::ParentIndexMap::ParentInsertMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        local_insert( 0, 2 )
        parent_index( 0 ).should == nil
        local_index( parent_instance_mock, 0 ).should == nil
        parent_insert( parent_instance_mock, 0, 2 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index_struct = parent_index( 1 )
        parent_index_struct.parent_index.should == 1
        parent_index_struct.parent_instance.should == parent_instance_mock
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 1
        local_index( parent_instance_mock, 2 ).should == nil
        local_index( parent_instance_mock, 3 ).should == nil
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == true
        looked_up!( 0 )
        looked_up!( 1 )
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end
  
  ##################
  #  local_insert  #
  ##################

  it 'can update its internal parent-local maps for a local insert when there are no parent elements' do
    module ::Array::Compositing::ParentIndexMap::LocalInsertMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        local_insert( 0, 2 )
        parent_index( 0 ).should == nil
        local_index( parent_instance_mock, 0 ).should == nil
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end

  it 'can update its internal parent-local maps for a local insert inside the range of parent elements' do
    module ::Array::Compositing::ParentIndexMap::LocalInsertMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_insert( 0, 2 )
        parent_index( 0 ).should == nil
        parent_index( 1 ).should == nil
        parent_index_struct = parent_index( 2 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index_struct = parent_index( 3 )
        parent_index_struct.parent_index.should == 1
        parent_index_struct.parent_instance.should == parent_instance_mock
        local_index( parent_instance_mock, 0 ).should == 2
        local_index( parent_instance_mock, 1 ).should == 3
        local_index( parent_instance_mock, 2 ).should == nil
        local_index( parent_instance_mock, 3 ).should == nil
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
        requires_lookup?( 2 ).should == true
        requires_lookup?( 3 ).should == true
        looked_up!( 2 )
        looked_up!( 3 )
        requires_lookup?( 2 ).should == false
        requires_lookup?( 3 ).should == false
      end
    end
  end

  it 'can update its internal parent-local maps for a local insert not inside parent element range' do
    module ::Array::Compositing::ParentIndexMap::LocalInsertMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_insert( 2, 2 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index_struct = parent_index( 1 )
        parent_index_struct.parent_index.should == 1
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index( 2 ).should == nil
        parent_index( 3 ).should == nil
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 1
        local_index( parent_instance_mock, 2 ).should == nil
        local_index( parent_instance_mock, 3 ).should == nil
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == true
        requires_lookup?( 2 ).should == false
        requires_lookup?( 3 ).should == false
        looked_up!( 0 )
        looked_up!( 1 )
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end

  ################
  #  parent_set  #
  ################

  it 'can update its internal parent-local maps for a parent set not inside existing parent elements' do
    module ::Array::Compositing::ParentIndexMap::ParentSetMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_insert( 2, 2 )
        parent_set( parent_instance_mock, 2 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index_struct = parent_index( 1 )
        parent_index_struct.parent_index.should == 1
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index_struct = parent_index( 2 )
        parent_index_struct.parent_index.should == 2
        parent_index_struct.parent_instance.should == parent_instance_mock
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 1
        local_index( parent_instance_mock, 2 ).should == 2
        local_index( parent_instance_mock, 3 ).should == nil
        local_index( parent_instance_mock, 4 ).should == nil
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == true
        requires_lookup?( 2 ).should == true
        requires_lookup?( 3 ).should == false
        looked_up!( 0 )
        looked_up!( 1 )
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end

  it 'can update its internal parent-local maps for a parent set inside existing parent elements' do
    module ::Array::Compositing::ParentIndexMap::ParentSetMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_insert( 2, 2 )
        parent_set( parent_instance_mock, 1 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index_struct = parent_index( 1 )
        parent_index_struct.parent_index.should == 1
        parent_index_struct.parent_instance.should == parent_instance_mock
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 1
        local_index( parent_instance_mock, 2 ).should == nil
        local_index( parent_instance_mock, 3 ).should == nil
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == true
        requires_lookup?( 2 ).should == false
        requires_lookup?( 3 ).should == false
        looked_up!( 0 )
        looked_up!( 1 )
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end

  it 'can update its internal parent-local maps for a parent set inside existing parent elements when parent element has been replaced' do
    module ::Array::Compositing::ParentIndexMap::ParentSetMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_insert( 2, 2 )
        local_set( 1 )
        parent_set( parent_instance_mock, 1 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index( 1 ).should == nil
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 1
        local_index( parent_instance_mock, 2 ).should == nil
        local_index( parent_instance_mock, 3 ).should == nil
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == false
        requires_lookup?( 2 ).should == false
        requires_lookup?( 3 ).should == false
        looked_up!( 0 )
        looked_up!( 1 )
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end

  ###############
  #  local_set  #
  ###############
  
  it 'can update its internal parent-local maps for a local set with no parent elements' do
    module ::Array::Compositing::ParentIndexMap::LocalSetMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        local_set( 0 )
        parent_index( 0 ).should == nil
        local_index( parent_instance_mock, 0 ).should == nil
        requires_lookup?( 0 ).should == false
      end
    end
  end

  it 'can update its internal parent-local maps for a local set over a parent element' do
    module ::Array::Compositing::ParentIndexMap::LocalSetMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_set( 0 )
        parent_index( 0 ).should == nil
        parent_index_struct = parent_index( 1 )
        parent_index_struct.parent_index.should == 1
        parent_index_struct.parent_instance.should == parent_instance_mock
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 1
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == true
        looked_up!( 1 )
        requires_lookup?( 1 ).should == false
      end
    end
  end

  it 'can update its internal parent-local maps for a local set outside parent elements' do
    module ::Array::Compositing::ParentIndexMap::LocalSetMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_set( 2 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index_struct = parent_index( 1 )
        parent_index_struct.parent_index.should == 1
        parent_index_struct.parent_instance.should == parent_instance_mock
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 1
        local_index( parent_instance_mock, 2 ).should == nil
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == true
        requires_lookup?( 2 ).should == false
        looked_up!( 0 )
        looked_up!( 1 )
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end

  ######################
  #  parent_delete_at  #
  ######################

  it 'can update its internal parent-local maps for a parent delete with no child elements' do
    module ::Array::Compositing::ParentIndexMap::ParentNoChildDeleteAtMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        parent_delete_at( parent_instance_mock, 1 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index( 1 ).should == nil
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == nil
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == nil
      end
    end
  end

  it 'can update its internal parent-local maps for a parent delete with replaced child elements' do
    module ::Array::Compositing::ParentIndexMap::ParentReplacedChildDeleteAtMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_set( 1 )
        parent_delete_at( parent_instance_mock, 1 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index( 1 ).should == nil
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == nil
        @local_parent_map.count.should == 2
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == false
        looked_up!( 0 )
        requires_lookup?( 0 ).should == false
      end
    end
  end

  #####################
  #  local_delete_at  #
  #####################

  it 'can update its internal parent-local maps for a local delete of parent elements' do
    module ::Array::Compositing::ParentIndexMap::LocalDeleteAtMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_delete_at( 1 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index( 1 ).should == nil
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 0
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == nil
        looked_up!( 0 )
        requires_lookup?( 0 ).should == false
      end
    end
  end

  it 'can update its internal parent-local maps for a local delete inside parents of a non-parent element' do
    module ::Array::Compositing::ParentIndexMap::LocalDeleteAtMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_insert( 1, 1 )
        local_delete_at( 1 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index_struct = parent_index( 1 )
        parent_index_struct.parent_index.should == 1
        parent_index_struct.parent_instance.should == parent_instance_mock
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 1
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == true
        looked_up!( 0 )
        looked_up!( 1 )
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end

  it 'can update its internal parent-local maps for a local delete outside parents' do
    module ::Array::Compositing::ParentIndexMap::LocalDeleteAtMock
      parent_instance_mock = Object.new
      ::Array::Compositing::ParentIndexMap.new.instance_eval do
        register_parent( parent_instance_mock )
        parent_insert( parent_instance_mock, 0, 2 )
        local_insert( 2, 2 )
        local_delete_at( 3 )
        parent_index_struct = parent_index( 0 )
        parent_index_struct.parent_index.should == 0
        parent_index_struct.parent_instance.should == parent_instance_mock
        parent_index_struct = parent_index( 1 )
        parent_index_struct.parent_index.should == 1
        parent_index_struct.parent_instance.should == parent_instance_mock
        local_index( parent_instance_mock, 0 ).should == 0
        local_index( parent_instance_mock, 1 ).should == 1
        requires_lookup?( 0 ).should == true
        requires_lookup?( 1 ).should == true
        requires_lookup?( 2 ).should == false
        requires_lookup?( 3 ).should == nil
        looked_up!( 0 )
        looked_up!( 1 )
        requires_lookup?( 0 ).should == false
        requires_lookup?( 1 ).should == false
      end
    end
  end

  #######################
  #  unregister_parent  #
  #######################

  it 'can unregister parents' do
    module ::Array::Compositing::ParentIndexMap::UnregisterParentMock
      ::Array::Compositing::ParentIndexMap.new.instance_eval do

        # parent 1 insert - 3 elements
        parent_instance = ::Array.new
        register_parent( parent_instance )
        parent_insert( parent_instance, 0, 3 )

        # parent 2 insert - 2 elements
        parent_instance2 = ::Array.new
        register_parent( parent_instance2 )
        parent_insert( parent_instance2, 0, 2 )

        # parent 3 insert - 4 elements
        parent_instance3 = ::Array.new
        register_parent( parent_instance3 )
        parent_insert( parent_instance3, 0, 4 )

        # parent 4 insert - 1 element
        parent_instance4 = ::Array.new
        register_parent( parent_instance4 )
        parent_insert( parent_instance4, 0, 1 )
        
        @local_parent_map[ 0 ].parent_instance.should == parent_instance
        @local_parent_map[ 0 ].parent_index.should == 0
        @local_parent_map[ 1 ].parent_instance.should == parent_instance
        @local_parent_map[ 1 ].parent_index.should == 1
        @local_parent_map[ 2 ].parent_instance.should == parent_instance
        @local_parent_map[ 2 ].parent_index.should == 2

        @local_parent_map[ 3 ].parent_instance.should == parent_instance2
        @local_parent_map[ 3 ].parent_index.should == 0
        @local_parent_map[ 4 ].parent_instance.should == parent_instance2
        @local_parent_map[ 4 ].parent_index.should == 1
        
        @local_parent_map[ 5 ].parent_instance.should == parent_instance3
        @local_parent_map[ 5 ].parent_index.should == 0
        @local_parent_map[ 6 ].parent_instance.should == parent_instance3
        @local_parent_map[ 6 ].parent_index.should == 1
        @local_parent_map[ 7 ].parent_instance.should == parent_instance3
        @local_parent_map[ 7 ].parent_index.should == 2
        @local_parent_map[ 8 ].parent_instance.should == parent_instance3
        @local_parent_map[ 8 ].parent_index.should == 3

        @local_parent_map[ 9 ].parent_instance.should == parent_instance4
        @local_parent_map[ 9 ].parent_index.should == 0
        
        unregister_parent( parent_instance2 )

        @local_parent_map[ 0 ].parent_instance.should == parent_instance
        @local_parent_map[ 0 ].parent_index.should == 0
        @local_parent_map[ 1 ].parent_instance.should == parent_instance
        @local_parent_map[ 1 ].parent_index.should == 1
        @local_parent_map[ 2 ].parent_instance.should == parent_instance
        @local_parent_map[ 2 ].parent_index.should == 2

        @local_parent_map[ 3 ].parent_instance.should == parent_instance3
        @local_parent_map[ 3 ].parent_index.should == 0
        @local_parent_map[ 4 ].parent_instance.should == parent_instance3
        @local_parent_map[ 4 ].parent_index.should == 1
        @local_parent_map[ 5 ].parent_instance.should == parent_instance3
        @local_parent_map[ 5 ].parent_index.should == 2
        @local_parent_map[ 6 ].parent_instance.should == parent_instance3
        @local_parent_map[ 6 ].parent_index.should == 3

        @local_parent_map[ 7 ].parent_instance.should == parent_instance4
        @local_parent_map[ 7 ].parent_index.should == 0
        
      end
    end
  end
  
end
