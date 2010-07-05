require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ResetsController do
  describe 'routing' do
    it { get('/resets').should map('resets#index') }
    it { get('/resets/new').should map('resets#new') }
    it { get('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe').should map('resets#show', :id => 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    it { get('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe/edit').should map('resets#edit', :id => 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    it { put('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe').should map('resets#update', :id => 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    it { delete('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe').should map('resets#destroy', :id => 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    it { post('/resets').should map('resets#create') }

    describe 'helpers' do
      before do
        @reset = Reset.stub :secret => 'fc10cd08b8d68be01f12c117b712f141a87718fe'
      end

      describe 'resets_path' do
        it { resets_path.should == '/resets' }
      end

      describe 'new_reset_path' do
        it { new_reset_path.should == '/resets/new' }
      end

      describe 'reset_path' do
        it { reset_path(@reset).should == '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe' }
      end

      describe 'edit_reset_path' do
        it { edit_reset_path(@reset).should == '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe/edit' }
      end

      describe 'edit_reset_path' do
        it { edit_reset_path(@reset).should == '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe/edit' }
      end
    end
  end
end
