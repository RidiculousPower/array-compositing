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

end
