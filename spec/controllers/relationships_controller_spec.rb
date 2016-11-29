require 'spec_helper'

describe RelationshipsController do 
  describe "GET index" do
    it "set @relationships to the current user's  following relationships" do 
      andy = Fabricate(:user)
      set_current_user(andy)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: andy, leader: bob )
      get :index 
      expect(assigns(:relationships)).to eq([relationship])
    end

    it_behaves_like "requires sign in" do 
      let(:action) { get :index }
    end
  end

  describe "DELETE destroy" do 
    it "deletes the relationships from the current user is the follower" do 
      andy = Fabricate(:user)
      set_current_user(andy)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: andy, leader: bob )
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(0) 
    end

    it "redirects to the people page" do 
      andy = Fabricate(:user)
      set_current_user(andy)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: andy, leader: bob )
      delete :destroy, id: relationship.id
      expect(response).to redirect_to people_path
    end

    it "does not delete the relationship if the current user is not the follower" do
      andy = Fabricate(:user)
      set_current_user(andy)
      bob = Fabricate(:user)
      relationship = Fabricate(:relationship, follower: bob, leader: andy )
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(1)
    end

    it_behaves_like "requires sign in" do 
      let(:action) { delete :destroy, id: 1 }
    end
  end

  describe "POST create" do 
    it_behaves_like "requires sign in" do 
      let(:action) { post :create, leader_id: 4 }
    end

    it "creates the relationship with the follower as current user" do 
      andy = Fabricate(:user)
      set_current_user(andy)
      bob = Fabricate(:user)
      post :create, leader_id: bob.id 
      expect(andy.following_relationships.first.leader).to eq(bob)
    end

    it "should prevent the user from following the same person multiple times" do
      andy = Fabricate(:user)
      set_current_user(andy)
      bob = Fabricate(:user)
      Fabricate(:relationship, leader: bob, follower: andy)
      post :create, leader_id: bob.id
      expect(Relationship.count).to eq(1)

    end

    it "does one to follow themselves" do 
      andy = Fabricate(:user)
      set_current_user(andy)
      post :create, leader_id: andy.id
      expect(Relationship.count).to eq(0)
    end

    it "redirects to the people page" do 
      andy = Fabricate(:user)
      set_current_user(andy)
      bob = Fabricate(:user)
      post :create, leader_id: bob.id
      expect(response).to redirect_to people_path
    end
  end
end