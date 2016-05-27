require 'spec_helper'

describe 'datasets/_dataset.html.erb' do

  before(:each) do
    @user = create(:user, name: "user")
    @dataset = create(:dataset, name: "My Dataset", repo: "my-repo", user: @user)
    allow(@dataset).to receive(:owner_avatar) {
      "http://example.org/avatar.png"
    }
  end

  it 'displays a single dataset' do
    render :partial => 'datasets/dataset.html.erb', :locals => {:dataset => @dataset}
    page = Nokogiri::HTML(rendered)
    expect(page.css('tr')[0].css('td')[0].inner_text).to match(/#{@user.name}/)
    expect(page.css('tr')[0].css('td')[1].inner_text).to match(/My Dataset/)
    expect(page.css('tr')[0].css('td')[2].inner_text).to match(/http:\/\/user.github.io\/my-repo/)
  end

  it 'does not display the edit link when path is not the dashboard' do
    render :partial => 'datasets/dataset.html.erb', :locals => {:dataset => @dataset}
    page = Nokogiri::HTML(rendered)

    expect(page.css('tr')[0].css('td').count).to eq(3)
    expect(rendered).to_not match /Edit/
  end

  it 'displays the edit link when in the dashboard' do
    @dashboard = true
    render :partial => 'datasets/dataset.html.erb', :locals => {:dataset => @dataset}
    page = Nokogiri::HTML(rendered)
    expect(page.css('tr')[0].css('td').count).to eq(5)
    expect(page.css('tr')[0].css('td')[3].inner_text).to match(/Edit/)
    expect(page.css('tr')[0].css('td')[4].inner_text).to match(/Delete/)
  end

end
