require 'spec_helper'

describe Category do
  it { should have_many(:videos) }
  it { should validate_presence_of(:name) }

  describe "#recent_videos" do 
    it "returns an array of six videos" do
      comedies = Category.new(name: "comedies")
      video1 = Video.create(title: "Die Hard", description: "High octane thriller", category: comedies, created_at: 10.day.ago)
      video2 = Video.create(title: "Die Hard 2", description: "High octane thriller", category: comedies, created_at: 9.day.ago)
      video3 = Video.create(title: "Die Hard 3", description: "High octane thriller", category: comedies, created_at: 8.day.ago)
      video4 = Video.create(title: "Die Hard 4", description: "High octane thriller", category: comedies, created_at: 7.day.ago)
      video5 = Video.create(title: "Die Hard 5", description: "High octane thriller", category: comedies, created_at: 6.day.ago)
      video6 = Video.create(title: "Die Hard 6", description: "High octane thriller", category: comedies, created_at: 5.day.ago)

      expect(comedies.recent_videos.size).to eq(6)
    end

    it "return an array in reverse chronological order" do 
      comedies = Category.new(name: "comedies")
      video1 = Video.create(title: "Die Hard", description: "High octane thriller", category: comedies, created_at: 10.day.ago)
      video2 = Video.create(title: "Die Hard 2", description: "High octane thriller", category: comedies, created_at: 9.day.ago)
      video3 = Video.create(title: "Die Hard 3", description: "High octane thriller", category: comedies, created_at: 8.day.ago)
      video4 = Video.create(title: "Die Hard 4", description: "High octane thriller", category: comedies, created_at: 7.day.ago)
      video5 = Video.create(title: "Die Hard 5", description: "High octane thriller", category: comedies, created_at: 6.day.ago)
      video6 = Video.create(title: "Die Hard 6", description: "High octane thriller", category: comedies, created_at: 5.day.ago)
      expect(comedies.recent_videos).to eq([video6, video5, video4, video3, video2, video1])
    end

    it "returns the total an array of all the videos if there are less than six" do
      comedies = Category.new(name: "comedies")
      video1 = Video.create(title: "Die Hard", description: "High octane thriller", category: comedies, created_at: 10.day.ago)
      video2 = Video.create(title: "Die Hard 2", description: "High octane thriller", category: comedies, created_at: 9.day.ago)
      video3 = Video.create(title: "Die Hard 3", description: "High octane thriller", category: comedies, created_at: 8.day.ago)
      expect(comedies.recent_videos.size).to eq(3)
    end

    it "returns only six videos if there are more videos" do 
      comedies = Category.new(name: "comedies")
      video1 = Video.create(title: "Die Hard", description: "High octane thriller", category: comedies, created_at: 10.day.ago)
      video2 = Video.create(title: "Die Hard 2", description: "High octane thriller", category: comedies, created_at: 9.day.ago)
      video3 = Video.create(title: "Die Hard 3", description: "High octane thriller", category: comedies, created_at: 8.day.ago)
      video4 = Video.create(title: "Die Hard 4", description: "High octane thriller", category: comedies, created_at: 7.day.ago)
      video5 = Video.create(title: "Die Hard 5", description: "High octane thriller", category: comedies, created_at: 6.day.ago)
      video6 = Video.create(title: "Die Hard 6", description: "High octane thriller", category: comedies, created_at: 5.day.ago)
      video7 = Video.create(title: "Die Hard 7", description: "High octane thriller", category: comedies, created_at: 4.day.ago)
      video8 = Video.create(title: "Die Hard 8", description: "High octane thriller", category: comedies, created_at: 3.day.ago)
      expect(comedies.recent_videos).to eq([video8, video7, video6, video5, video4, video3])
    end

    it "returns an empty array if the category has no videos" do 
      comedies = Category.new(name: "comedies")
      expect(comedies.recent_videos).to eq([])
    end
  end
end