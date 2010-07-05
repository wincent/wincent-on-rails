require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ResetsController do
  describe 'routing' do
    specify { get('/resets').should map('resets#index') }
    specify { get('/resets/new').should map('resets#new') }
    specify { get('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe').should map('resets#show', :id => 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    specify { get('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe/edit').should map('resets#edit', :id => 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    specify { put('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe').should map('resets#update', :id => 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    specify { delete('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe').should map('resets#destroy', :id => 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    specify { post('/resets').should map('resets#create') }

    describe 'helpers' do
      before do
        @reset = Reset.stub :secret => 'fc10cd08b8d68be01f12c117b712f141a87718fe'
      end

      describe 'resets_path' do
        specify { resets_path.should == '/resets' }
      end

      describe 'new_reset_path' do
        specify { new_reset_path.should == '/resets/new' }
      end

      describe 'reset_path' do
        specify { reset_path(@reset).should == '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe' }
      end

      describe 'edit_reset_path' do
        specify { edit_reset_path(@reset).should == '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe/edit' }
      end

      describe 'edit_reset_path' do
        specify { edit_reset_path(@reset).should == '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe/edit' }
      end
    end
  end
end
