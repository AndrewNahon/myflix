require 'spec_helper'

describe Video do

  it { should belong_to(:category) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should have_many(:reviews).order("created_at DESC") }

  describe "search_by_title" do
    it "returns an empty array if no match" do 
      nemo = Video.create(description: 'A fish story', title: 'Nemo')
      expect(Video.search_by_title("Die Hard")).to eq([])
    end

    it "return a single match for an exact match" do 
      nemo = Video.create(description: 'A fish story', title: 'Nemo')
      expect(Video.search_by_title("Nemo")).to eq([nemo])
    end

    it "returns a single match for a partial match" do 
      nemo = Video.create(description: 'A fish story', title: 'Nemo')
      expect(Video.search_by_title("Ne")).to eq([nemo])
    end

    it "ignores case" do 
      nemo = Video.create(description: 'A fish story', title: 'Nemo')
      expect(Video.search_by_title("nemo")).to eq([nemo])
    end

    it "returns all matches ordered by created_at" do 
      
      nemo = Video.create(description: 'A fish story', title: 'Nemo')
      nemo2 = Video.create(description: 'Another fish story', title: 'Nemo II', created_at: 1.day.ago)
      nemo3 = Video.create(description: 'Yet another fish story', title: 'Nemo III')
      expect(Video.search_by_title("nemo")).to eq([nemo3, nemo, nemo2])
    end

    it "returns an empty array for an empty string" do 
      nemo = Video.create(description: 'A fish story', title: 'Nemo')
      expect(Video.search_by_title("")).to eq([])
    end
  end
end
