require 'rails_helper'

describe DatasetsController, type: :controller do

  before(:each) do
    @user = create(:user)
  end

  describe 'dashboard' do
    it "gets the right number of datasets" do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]

      5.times { |i| create(:dataset, name: "Dataset #{i}") }

      create(:dataset, user: @user)
      sign_in @user

      get 'dashboard'

      expect(assigns(:datasets).count).to eq(1)
    end

    it 'gets all the users repos', :vcr do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]

      @user = create(:user, token: ENV['GITHUB_TOKEN'])

      @dataset1 = create(:dataset, full_name: 'octopub/api-sandbox', user: @user)
      @dataset2 = create(:dataset, full_name: 'octopub-data/juan-test', user: create(:user))

      expect(@user).to receive(:user_repos) { [@dataset1.id, @dataset2.id] }

      sign_in @user
      @user.send(:get_user_repos)
      get 'dashboard'

      expect(assigns(:datasets).count).to eq(1)
    end

    it 'redirects to the API' do
      expect(get 'dashboard', format: :json).to redirect_to('/api/user/datasets')
    end
  end
end
