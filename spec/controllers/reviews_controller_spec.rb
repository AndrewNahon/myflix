require 'spec_helper'

describe ReviewsController do
  describe "POST create" do
    let(:video) { Fabricate(:video) } 
    let(:andy) { Fabricate(:user) }
    
    context "with authenticated users" do
      before do 
        session["user_id"] = andy.id 
      end 
      context "with valid inputs" do 
        
        before do 
          post :create, video_id: video.id, review: Fabricate.attributes_for(:review)
        end
        
        it "creates a review" do
           expect(Review.count).to eq(1)
        end
        
        it "creates a review associated with the video" do 
          expect(Review.first.video ).to eq(video)
        end
        it "creates a review associated with the signed in user" do 
          expect(Review.first.user ).to eq(andy)
        end
        
        it "redirects to the video show page" do 
          expect(response).to redirect_to video_path(video)
        end
      end

      context "with invalid inputs" do 
        before do 
          post :create, video_id: video.id, review: { rating: 3 }
        end
        
        it "does not create a review" do 
          expect(Review.count).to eq(0)
        end
        
        it "renders the video/show template" do
          expect(response).to render_template "videos/show"
        end
        
        it "sets @video" do 
          expect(assigns :video).to eq(video)
        end
        
        it "sets @reviews" do 
          review = Fabricate(:review, video: video)
          expect(assigns :reviews).to match_array ([review])
        end
      end
    end

    context "with unauthenticated users" do
      it "redirects to the sign in path" do
        post :create, video_id: video.id, review: Fabricate.attributes_for(:review)
        expect(response).to redirect_to sign_in_path
      end
    end
  end
end
