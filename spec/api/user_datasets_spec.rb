require 'rails_helper'
require 'support/odlifier_licence_mock'

describe 'GET /user/datasets', vcr: { :match_requests_on => [:host, :method] } do
  include_context 'odlifier licence mock'

  before(:each) do
    @user = create(:user)
  end

  it 'gets all datasets for a user' do
    5.times { |i| create(:dataset, name: "Dataset #{i}") }

    dataset = create(:dataset, user: @user)

    get '/api/user/datasets', headers: {'Authorization' => "Token token=#{@user.api_key}"}

    json = JSON.parse(response.body)

    expect(json.count).to eq(1)
    expect(json.first['name']).to eq(dataset.name)
  end

end
