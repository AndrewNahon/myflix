require 'spec_helper'

describe User do
  it { should validate_presence_of :email }
  it { should validate_presence_of :full_name }
  it { should validate_presence_of :password }
  it { should validate_uniqueness_of(:email) }
  it { should have_many(:queue_items) }
  it { should have_many(:reviews) }

  it_behaves_like "tokenable" do 
    let(:object) { Fabricate(:user) }
  end

  it "generates a token when created" do 
    user = Fabricate(:user)
    expect(user.token).to be_present
  end
  
  describe "#queued_video?" do 
    
    it "should return true if the video is in the user's queue" do 
      andy = Fabricate(:user) 
      video = Fabricate(:video)
      queue_item = Fabricate(:queue_item, user: andy, video: video)
      expect(andy.queued_video?(video)).to be_truthy
    end
    
    it "should return false if the video is not in the user's queue" do
      andy = Fabricate(:user) 
      video = Fabricate(:video)
      expect(andy.queued_video?(video)).to be_falsey
    end
  end

  describe "#follow" do 
    it "follows another user" do 
      andy = Fabricate(:user)
      bobby = Fabricate(:user)
      andy.follow(bobby)
      expect(andy.reload.follows?(bobby)).to be_truthy
    end
    
    it "does not follow oneself" do 
      andy = Fabricate(:user)
      andy.follow(andy)
      expect(Relationship.count).to eq(0)
    end
  end
end