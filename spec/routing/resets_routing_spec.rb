require 'spec_helper'

describe ResetsController do
  describe 'routing' do
    specify { expect(get: '/resets').to route_to('resets#index') }
    specify { expect(get: '/resets/new').to route_to('resets#new') }
    specify { expect(get: '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe').to route_to('resets#show', id: 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    specify { expect(get: '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe/edit').to route_to('resets#edit', id: 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    specify { expect(put: '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe').to route_to('resets#update', id: 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    specify { expect(delete: '/resets/fc10cd08b8d68be01f12c117b712f141a87718fe').to route_to('resets#destroy', id: 'fc10cd08b8d68be01f12c117b712f141a87718fe') }
    specify { expect(post: '/resets').to route_to('resets#create') }

    describe 'helpers' do
      let(:reset) { Reset.stub secret: 'fc10cd08b8d68be01f12c117b712f141a87718fe' }

      describe 'resets_path' do
        specify { expect(resets_path).to eq('/resets') }
      end

      describe 'new_reset_path' do
        specify { expect(new_reset_path).to eq('/resets/new') }
      end

      describe 'reset_path' do
        specify { expect(reset_path(reset)).to eq('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe') }
      end

      describe 'edit_reset_path' do
        specify { expect(edit_reset_path(reset)).to eq('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe/edit') }
      end

      describe 'edit_reset_path' do
        specify { expect(edit_reset_path(reset)).to eq('/resets/fc10cd08b8d68be01f12c117b712f141a87718fe/edit') }
      end
    end
  end
end
