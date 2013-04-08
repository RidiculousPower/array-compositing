# -*- encoding : utf-8 -*-

require_relative '../../../../../lib/array-compositing.rb'

describe ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap do

  let( :parent_local_map ) { ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap.new( [ 1, nil, 2, 4, nil, nil, 7, nil ] ) }

  ###########################
  #  index_for_local_index  #
  ###########################
  
  context '#index_for_local_index' do
    it 'will find the nth local index in self (1st, 2nd, etc.)' do
      parent_local_map.index_for_local_index( 1 ).should == 0
      parent_local_map.index_for_local_index( 2 ).should == 2
      parent_local_map.index_for_local_index( 3 ).should == 3
      parent_local_map.index_for_local_index( 4 ).should == 6
    end
  end

  #################
  #  local_index  #
  #################
  
  context '#local_index' do
    it 'will find the nth local index in self (1st, 2nd, etc.)' do
      parent_local_map.local_index( 1 ).should == 1
      parent_local_map.local_index( 2 ).should == 2
      parent_local_map.local_index( 3 ).should == 4
      parent_local_map.local_index( 4 ).should == 7
    end
  end

  ######################
  #  next_local_index  #
  ######################

  context '#next_local_index' do
    it 'will look for the next local index mapped from parent; returns nil if requested index has no locals following it' do
      parent_local_map.next_local_index( 0 ).should be 1
      parent_local_map.next_local_index( 1 ).should be 2
      parent_local_map.next_local_index( 2 ).should be 2
      parent_local_map.next_local_index( 3 ).should be 4
      parent_local_map.next_local_index( 4 ).should be 7
      parent_local_map.next_local_index( 5 ).should be 7
      parent_local_map.next_local_index( 6 ).should be 7
      parent_local_map.next_local_index( 7 ).should be nil
    end
  end

  #############################
  #  next_local_insert_index  #
  #############################

  context '#next_local_index' do
    it 'will look for the next local index mapped from parent; if requested index has no locals following it, looks for next local preceding it' do
      parent_local_map.next_local_insert_index( 0 ).should be 1
      parent_local_map.next_local_insert_index( 1 ).should be 2
      parent_local_map.next_local_insert_index( 2 ).should be 2
      parent_local_map.next_local_insert_index( 3 ).should be 4
      parent_local_map.next_local_insert_index( 4 ).should be 7
      parent_local_map.next_local_insert_index( 5 ).should be 7
      parent_local_map.next_local_insert_index( 6 ).should be 7
      parent_local_map.next_local_insert_index( 7 ).should be 8
    end
  end

end
