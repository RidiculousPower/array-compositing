# -*- encoding : utf-8 -*-

require_relative '../../../../../lib/array-compositing.rb'

describe ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap do

  let( :index_map ) { ::Array::Compositing::CascadeController::IndexMap::ParentLocalMap.new( [ 1, nil, 2, 4, nil, 7, nil ] ) }

  #################################
  #  ensure_no_nil_local_indexes  #
  #################################

  context '#ensure_no_nil_local_indexes' do
    before :each do
      index_map.ensure_no_nil_local_indexes( 7 )
    end
    it 'will map index value to right of nil values to replace nil values; this permits position tracking for parent inserts next to elements that have been deleted in local' do
      index_map.should == [ 1, 2, 2, 4, 7, 7, 7 ]
    end
  end

end
