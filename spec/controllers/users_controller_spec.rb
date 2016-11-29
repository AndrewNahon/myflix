require 'spec_helper'

describe UsersController do 
  describe "GET new" do 
    it "sets @user" do 
      get :new 
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe "POST create" do 
    context "with valid input" do

      it "creates the user" do
        post :create, user: Fabricate.attributes_for(:user) 
        expect(User.count).to eq(1)
      end

      it "redirects to the sign in page" do
        post :create, user: Fabricate.attributes_for(:user) 
        expect(response).to redirect_to sign_in_path
      end

      it "makes the user follow the inviter" do 
        andy = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: andy, recipient_email: 'bobby@example.com',  )
        post :create, user: { full_name: 'bobby peru', email: "bobby@example.com", password: "password"}, invitation_token: invitation.token
        bobby = User.where(email: 'bobby@example.com').first
        expect(bobby.follows?(andy)).to be_truthy
      end

      it "makes the inviter follow the user" do 
        andy = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: andy, recipient_email: 'bobby@example.com',  )
        post :create, user: { full_name: 'bobby peru', email: "bobby@example.com", password: "password"}, invitation_token: invitation.token
        bobby = User.where(email: 'bobby@example.com').first
        expect(andy.reload.follows?(bobby)).to be_truthy
      end
      
      it "expires the invitation upon acceptance" do 
         andy = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: andy, recipient_email: 'bobby@example.com',  )
        post :create, user: { full_name: 'bobby peru', email: "bobby@example.com", password: "password"}, invitation_token: invitation.token
        expect(Invitation.first.token).to be_nil
      end
    end

    context "email sending" do
      after { ActionMailer::Base.deliveries.clear } 
      it "sends out email to the user with valid inputs" do
        post :create, user: { email: "andy@example.com", full_name: "andy nahon", password: "password" }
        expect(ActionMailer::Base.deliveries.last.to).to eq(['andy@example.com'])
      end
      
      it "sends out an email containing the user's name with valid inputs" do 
        post :create, user: { email: "andy@example.com", full_name: "andy nahon", password: "password" }
        expect(ActionMailer::Base.deliveries.last.body).to include("andy nahon")
      end
      it "does not send out an email with invalid inputs" do 
        post :create, user: { email: "andy@example.com", full_name: "andy nahon" }
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context "with invalid input" do
      before do 
        post :create, user: { full_name: "Andrew Denholm Nahon" } 
      end

      it "does not create the user" do 
        expect(User.count).to eq(0)
      end
      it "renders the new template" do 
        expect(response).to render_template :new
      end
      it "sets the user variable" do 
        expect(assigns(:user)).to be_instance_of(User)
      end
    end
  end

  describe "GET show" do 
    it_behaves_like "requires sign in" do 
      let(:action) { get :show, id: 3 }
    end
    
    it "sets @user" do
      andy = Fabricate(:user)
      set_current_user
      get :show, id: andy.id
      expect(assigns(:user)).to eq(andy)
    end
  end

  describe "GET new_with_invitation_token" do
    it "renders the new template" do 
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(response).to render_template :new
    end

    it "sets @invitation_token" do 
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:invitation_token)).to eq(invitation.token)
    end

    it "sets @user with recipient's email" do 
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:user).email).to eq(invitation.recipient_email)
    end
    
    it "redirects to expired token page if token is invalid" do 
      get :new_with_invitation_token, token: '123454'
      expect(response).to redirect_to expired_token_path
    end
  end
end
