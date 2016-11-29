require 'spec_helper'

describe PasswordResetsController do 
  describe "GET show" do 
    it "renders show page if the token is valid" do 
      andy = Fabricate(:user)
      andy.update_column(:token, '12345')
      get :show, id: '12345'
      expect(response).to render_template 'show' 
    end

    it "sets @token" do 
      andy = Fabricate(:user)
      andy.update_column(:token, '12345')
      get :show, id: '12345'
      expect(assigns(:token)).to eq('12345')
    end

    it "redirects to the expired token page if the token is invalid" do 
      get :show, id: '12345'
      expect(response).to redirect_to expired_token_path
    end
  end

  describe "POST create" do

    context "with valid token" do 
      it "creates new password for user" do 
        andy = Fabricate(:user, password: 'password')
        andy.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(andy.reload.authenticate('new_password')).to be_truthy
      end
      it "resets the token for the user" do 
        andy = Fabricate(:user, password: 'password')
        andy.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(andy.reload.token).not_to eq('12345')
      end
      it "redirects to the sign in page" do 
        andy = Fabricate(:user, password: 'password')
        andy.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(response).to redirect_to sign_in_path
      end
      it "sets the flash success method" do 
        andy = Fabricate(:user, password: 'password')
        andy.update_column(:token, '12345')
        post :create, token: '12345', password: 'new_password'
        expect(flash[:success]).to eq('Your password was reset.')
      end
    end

    context "with invalid token" do 
      it "redirect to expired token page if the token is invalid" do 
        post :create, token: '12345', password: 'new_password'
      end
    end
  end
end
