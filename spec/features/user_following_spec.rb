require 'spec_helper'

feature 'User following' do 
  scenario "user follows and unfollows someone" do
    andy = Fabricate(:user) 
    comedies = Fabricate(:category, name: 'comedies' )
    video = Fabricate(:video, category: comedies)
    Fabricate(:review, user: andy, video: video)
    sign_in
    click_on_video_on_home_page(video)

    click_link andy.full_name
    click_link "Follow"
    expect(page).to have_content andy.full_name

    unfollow(andy)

    expect(page).not_to have_content andy.full_name

  end

  def unfollow(user)
    find("a[data-method='delete']").click
  end

end