require 'spec_helper'

feature 'User reset' do 
  scenario 'user successfull resets the password' do 
    andy = Fabricate(:user, password: 'old_password')
    visit sign_in_path
    click_link "Forgot password?"
    
    fill_in "Email Address", with: andy.email
    click_button 'Send email'

    open_email(andy.email)
    current_email.click_link('Reset My Password')

    fill_in "New Password", with: 'new_password'
    click_button "Reset Password"
    

    fill_in "Email", with: andy.email
    fill_in "Password", with: 'new_password'
    click_button 'Sign in'
    expect(page).to have_content("Welcome, #{andy.full_name}")

    clear_email
  end
end