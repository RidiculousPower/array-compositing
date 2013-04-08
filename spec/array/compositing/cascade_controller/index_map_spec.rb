# -*- encoding : utf-8 -*-

require_relative '../../../../lib/array-compositing.rb'

describe ::Array::Compositing::CascadeController::IndexMap do

  let( :index_map ) { ::Array::Compositing::CascadeController::IndexMap.new( [ 1, 2, 4, 7 ] ) }

  ########################################
  #  renumber_mapped_indexes_for_delete  #
  ########################################

  context '#renumber_mapped_indexes_for_delete' do
    before :each do
      index_map.renumber_mapped_indexes_for_delete( 2 )
    end
    it 'will decrement all members higher than index by count' do
      index_map.should == [ 1, 2, 3, 6 ]
    end
  end

  ########################################
  #  renumber_mapped_indexes_for_insert  #
  ########################################

  context '#renumber_mapped_indexes_for_insert' do
    before :each do
      index_map.renumber_mapped_indexes_for_insert( 2, 3 )
    end
    it 'will decrement all members higher than index by count' do
      index_map.should == [ 1, 5, 7, 10 ]
    end
  end

  #######################
  #  renumber_for_move  #
  #######################
  
  context '#renumber_for_move' do
    before :each do
      index_map.renumber_for_move( 0, 2 )
    end
    it 'will move a specified index to a new index' do
      index_map.should == [ 0, 2, 4, 7 ]
    end
  end
  
  ##########
  #  swap  #
  ##########

  context '#swap' do
    before :each do
      index_map.swap( 1, 3 )
    end
    it 'will swap a specified index with another index' do
      index_map.should == [ 1, 7, 4, 2 ]
    end
  end
  
end
