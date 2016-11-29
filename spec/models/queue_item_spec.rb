require 'spec_helper'

describe QueueItem do 
  it { should belong_to :video }
  it { should belong_to :user } 
  it { should validate_numericality_of(:position).only_integer }

  describe "#video_title" do 
    it "should return the title of the associated video's title" do
      video = Fabricate(:video, title: 'The Replacement Killers')
      queue_item = Fabricate(:queue_item, video: video)
      expect(queue_item.video_title).to eq('The Replacement Killers')
    end
  end

  describe "#rating" do 
    it "returns the rating from the review if present" do 
      video = Fabricate(:video)
      user = Fabricate(:user)
      review = Fabricate(:review, video: video, user: user, rating: 4)
      queue_item = Fabricate(:queue_item, user: user, video: video)
      expect(queue_item.rating).to eq(4)
    end
    it "returns nil when the review is not present" do 
      video = Fabricate(:video)
      user = Fabricate(:user)
      queue_item = Fabricate(:queue_item, user: user, video: video)
      expect(queue_item.rating).to be_nil
    end
  end

  describe "#rating=" do 
    it "sets the rating of the associated video" do 
      video = Fabricate(:video)
      andy = Fabricate(:user)
      review = Fabricate(:review, rating: 5, video: video, user: andy)
      queue_item = Fabricate(:queue_item, user: andy, video: video)
      queue_item.rating = 4 
      expect(Review.first.rating).to eq(4)
    end
    it "clears the rating of the review if present" do 
      video = Fabricate(:video)
      andy = Fabricate(:user)
      review = Fabricate(:review, rating: 5, video: video, user: andy)
      queue_item = Fabricate(:queue_item, user: andy, video: video)
      queue_item.rating = nil 
      expect(Review.first.rating).to be_nil
    end
    it "creates a review with the rating if the review is not present" do 
      video = Fabricate(:video)
      andy = Fabricate(:user)
      queue_item = Fabricate(:queue_item, user: andy, video: video)
      queue_item.rating = 5 
      expect(Review.first.rating).to eq(5)
    end
  end

  describe "#category_name" do 
    it "returns the category of the associated video if present" do 
      category = Fabricate(:category, name: "Action")
      video = Fabricate(:video, category: category)
      queue_item = Fabricate(:queue_item, video: video)
      expect(queue_item.category_name).to eq("Action")
    end
  end
  describe "#category" do 
    it "returns the category of the video" do 
      category = Fabricate(:category)
      video = Fabricate(:video, category: category)
      queue_item = Fabricate(:queue_item, video: video)
      expect(queue_item.category).to eq(category)
    end
  end
end