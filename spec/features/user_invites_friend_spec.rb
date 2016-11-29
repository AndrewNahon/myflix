require 'spec_helper'

feature 'User invites friend' do 
  scenario 'User successfully invites a friend and invitation is accepted' do 
    andy = Fabricate(:user)
    sign_in(andy)

    visit new_invitation_path
    invite_a_friend

    friend_accepts_invitation

    friend_signs_in

    friend_should_follow(andy)

    inviter_should_follow_friend(andy)

    clear_email
  end

  def invite_a_friend 
    fill_in "Friend's name", with: 'bobby'
    fill_in "Friend's email", with: 'bobby@example.com'
    fill_in "Leave a message", with: 'Join this cool site!'
    click_button "Send Invitation"
    sign_out
  end

  def friend_accepts_invitation 
    open_email "bobby@example.com"
    current_email.click_link "Accept this invitation"

    fill_in "Password", with: 'password'
    fill_in "Full name", with: 'Bobby Peru'
    click_button "Sign up"
  end

  def friend_signs_in 
    fill_in "Email", with: 'bobby@example.com'
    fill_in "Password", with: 'password'
    click_button "Sign in"
  end

  def friend_should_follow(andy)
    click_link "People"
    expect(page).to have_content andy.full_name
    sign_out
  end

  def inviter_should_follow_friend(andy) 
    sign_in(andy)
    click_link "People"
    expect(page).to have_content "Bobby Peru"
  end
end