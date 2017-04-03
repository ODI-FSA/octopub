require "rails_helper"

feature "Logged in admin can edit user", type: :feature do
  include_context 'user and organisations'

  before(:each) do
    @admin = create(:admin)
    @publisher = create(:user, :with_twitter_name)
    OmniAuth.config.mock_auth[:github]
    sign_in @admin
    visit edit_restricted_user_path(@publisher)
  end

  scenario "logged in admins can get to the edit page" do
    visit user_path(@publisher)
    expect(page).to have_content "User Details"
    expect(page).to have_content @publisher.name
    click_on 'Edit user and allocate schemas'
    expect(page).to have_content "Edit user and allocate schemas"
    expect(page).to have_content @publisher.name
  end

  scenario "logged in admins can edit user details" do
    expect(find_field('user[twitter_handle]').value).to eq @publisher.twitter_handle
    new_twitter_handle = Faker::Twitter.user[:screen_name]
    fill_in 'user[twitter_handle]', with: new_twitter_handle
    click_on 'Update'
    @publisher.reload
    expect(@publisher.twitter_handle).to eq new_twitter_handle
  end

  scenario "logged in admins can change the user's role" do
    expect(page).to have_select('user[role]', selected: 'Publisher')
    select 'Superuser', from: 'user[role]'
    click_on 'Update'
    @publisher.reload
    expect(@publisher.role).to eq 'superuser'
  end

  scenario "logged in admins can change the user to a restricted user" do
    expect(@publisher.restricted).to be false
    expect(page.has_no_checked_field?('_user[restricted]'))
    page.check('_user[restricted]')
    click_on 'Update'
    @publisher.reload
    expect(@publisher.restricted).to be true
  end

   context "logged in admins can allocate schemas" do

    let(:dataset_file_schema_1) { create(:dataset_file_schema) }
    let(:dataset_file_schema_2) { create(:dataset_file_schema) }

    it "individually" do
      dataset_file_schema_1 = create(:dataset_file_schema, name: Faker::Name.unique.name)
      dataset_file_schema_2 = create(:dataset_file_schema, name: Faker::Name.unique.name)
      expect(DatasetFileSchema.count).to be 2
      @publisher.allocated_dataset_file_schemas << dataset_file_schema_1
      @publisher.reload
      expect(@publisher.allocated_dataset_file_schemas.count).to be 1

      visit edit_restricted_user_path(@publisher)
      expect(page.has_checked_field?(dataset_file_schema_1.name))
      expect(page.has_no_checked_field?(dataset_file_schema_2.name))

      page.check dataset_file_schema_2.name
      click_on 'Update'
      @publisher.reload

      expect(@publisher.allocated_dataset_file_schemas.count).to be 2
      expect(@publisher.allocated_dataset_file_schemas).to include(dataset_file_schema_1, dataset_file_schema_2)
    end

    scenario "with a category" do
      schemas = [ dataset_file_schema_1, dataset_file_schema_2]
      schema_category = SchemaCategory.create(name: 'cat1', dataset_file_schemas: schemas)
      visit edit_restricted_user_path(@publisher)

      expect(page.has_no_checked_field?("user_allocated_dataset_file_schema_ids_#{dataset_file_schema_1.id}"))
      expect(page.has_no_checked_field?("user_allocated_dataset_file_schema_ids_#{dataset_file_schema_2.id}"))

      page.check("cat1")
      expect(page.has_checked_field?)
      click_on 'Update'
      @publisher.reload

      expect(@publisher.allocated_dataset_file_schemas.count).to be 2
      expect(@publisher.allocated_dataset_file_schemas).to include(dataset_file_schema_1, dataset_file_schema_2)
    end
  end
end
