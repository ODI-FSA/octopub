require 'support/odlifier_licence_mock'

RSpec.describe "Dataset creation", type: :request, vcr: { :match_requests_on => [:host, :method] } do
  include_context 'odlifier licence mock'

  before(:each) do

    Sidekiq::Testing.fake!

    @user = create(:user)
    sign_in @user

    @name = "My cool dataset"
    @description = "This is a description"
    @publisher_name = "Cool inc"
    @publisher_url = "http://example.com"
    @license = "OGL-UK-3.0"
    @frequency = "Monthly"
    @files ||= []

    allow_any_instance_of(User).to receive(:organizations) { [] }
    allow_any_instance_of(User).to receive(:github_user) {
      OpenStruct.new(
        avatar_url: "http://www.example.org/avatar2.png"
      )
    }

    file_name = 'Test Data'
    description = Faker::Company.bs
    filename = 'test-data.csv'
    path = File.join(Rails.root, 'spec', 'fixtures', filename)

    @files << {
      :title => file_name,
      :description => description,
      :file => url_with_stubbed_get_for(path)
    }
  end

  it "creates a dataset and redirects to the dataset page" do
    get '/datasets/new'
    expect(response).to render_template(:new)

    request = post '/datasets', params: { dataset: {
      name: @name,
      description: @description,
      publisher_name: @publisher_name,
      publisher_url: @publisher_url,
      license: @license,
      frequency: @frequency
    }, files: @files }

    expect(request).to redirect_to(created_datasets_path)
    follow_redirect!

    expect(response).to render_template("datasets/created")
    expect(response.body).to include("Your dataset has been queued for creation")
  end

  it "fails to create a dataset and redirects to the creation page if no name" do
    get '/datasets/new'
    expect(response).to render_template(:new)

    request = post '/datasets', params: { dataset: {
      description: @description,
      publisher_name: @publisher_name,
      publisher_url: @publisher_url,
      license: @license,
      frequency: @frequency
    }, files: @files }

    expect(request).to redirect_to(created_datasets_path)
    follow_redirect!

    expect(response).to render_template("datasets/created")
    expect(response.body).to include("Your dataset has been queued for creation")
  end

  it "does not render a different template" do
    get '/datasets/new'
    expect(response).to_not render_template(:show)
  end
end
