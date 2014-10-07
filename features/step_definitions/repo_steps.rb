When(/^I go to the add new dataset page$/) do
  visit new_dataset_path
end

When(/^I add my dataset details$/) do
  @name = "My cool dataset"
  fill_in "dataset_name", with: @name
end

When(/^I click submit$/) do
  click_button "Submit"
end

Then(/^a new Github repo should be created$/) do
  @repo = "test/My-cool-dataset"
  @url = "https://github.com/#{@repo}"
  expect_any_instance_of(Octokit::Client).to receive(:create_repository).with(@name) {
     { html_url: @url, full_name: @repo }
  }
end

Then(/^my repo should be listed in the datasets index$/) do
  expect(page.html).to include("<a href=\"#{@url}\">#{@name}</a>")
end

When(/^the repo details should be stored in the database$/) do
  dataset = Dataset.last
  expect(dataset.name).to eql(@name)
  expect(dataset.url).to eql(@url)
  expect(dataset.repo).to eql(@repo)
end

When(/^I should see "(.*?)"$/) do |message|
  expect(page).to have_content message
end