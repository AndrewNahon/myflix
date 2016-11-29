require 'spec_helper'

describe SessionsController do
  
  describe "GET new" do 
    it "renders the new template for unauthenticated users" do
      get :new
      expect(response).to render_template :new
    end

    it "redirects to the videos page for authenticated users" do
      session[:user_id] = Fabricate(:user).id
      get :new
      expect(response).to redirect_to videos_path
    end
  end

  describe "POST create" do
    let(:alice) { Fabricate(:user) }

    context "with valid credentials" do
      before do 
        post :create, email: alice.email, password: alice.password
      end
      it "puts signed in user in the session" do 
        expect(session["user_id"]).to eq(alice.id)
      end
      it "redirects to videos_path" do 
        expect(response).to redirect_to videos_path
      end
      it "sets the notice" do
        expect(flash[:notice]).not_to be_blank
      end
    end

    context "with invalid credientials" do
      before do 
        post :create, email: alice.email, password: alice.password + '123'
      end
      it "does not put the signed in user in the session" do
        expect(session["user_id"]).to be_nil
      end
      it "redirects to sign in in page for invalid password" do 
        expect(response).to redirect_to sign_in_path
      end
      it "sets the error message" do 
        expect(flash[:error]).not_to be_blank
      end
    end
  end

  describe "GET destroy" do 
    let(:alice) { Fabricate(:user) }
    before do 
      session[:user_id] = alice.id 
      get :destroy
    end
    it "removes user from the session" do 
      expect(session["user_id"]).to be_nil
    end
    it "redirects to the root_path" do 
      expect(response).to redirect_to root_path
    end
    it "sets the notice" do 
      expect(flash[:notice]).not_to be_blank
    end
  end
end