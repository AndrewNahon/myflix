require 'spec_helper' 

describe QueueItemsController do 
  describe 'GET index' do
    it "sets @queue_items to the queue items of logged in user" do 
      andy = Fabricate(:user) 
      set_current_user(andy)
      queue_item1 = Fabricate(:queue_item, user: andy)
      queue_item2 = Fabricate(:queue_item, user: andy)
      get :index
      expect(assigns :queue_items).to match_array([queue_item1, queue_item2])
    end
    it_behaves_like "requires sign in" do 
      let(:action) { get :index }
    end
  end

  describe 'POST create' do
    it "creates a queue item" do 
      set_current_user
      video = Fabricate(:video) 
      post :create, video_id: video.id
      expect(QueueItem.count).to eq(1)
    end

    it "creates the queue item associated with the video" do 
      set_current_user
      video = Fabricate(:video) 
      post :create, video_id: video.id
      expect(QueueItem.first.video).to eq(video) 
    end

    it "creates the queue item associated with the signed-in user" do 
      andy = Fabricate(:user) 
      set_current_user(andy)
      video = Fabricate(:video) 
      post :create, video_id: video.id
      expect(andy.queue_items.size).to eq(1) 
    end
    
    it "redirects the my_queue page" do 
      andy = Fabricate(:user) 
      session[:user_id] = andy.id
      video = Fabricate(:video) 
      post :create, video_id: video.id
      expect(response).to redirect_to my_queue_path 
    end

    it "puts the video at the end of list" do 
      andy = Fabricate(:user) 
      set_current_user(andy)
      monk = Fabricate(:video)
      Fabricate(:queue_item, video: monk, user: andy)
      south_park = Fabricate(:video)
      post :create, video_id: south_park.id
      south_park_queue_item = QueueItem.where(video_id: south_park.id, user_id: andy.id).first
      expect(south_park_queue_item.position).to eq(2)
    end

    it "doesn't add the video twice if the video is already in the queue" do 
      andy = Fabricate(:user) 
      set_current_user(andy)
      monk = Fabricate(:video)
      Fabricate(:queue_item, video: monk, user: andy)
      post :create, video_id: monk.id
      expect(QueueItem.count).to eq(1)
    end
  end

  describe "DELETE destroy" do 
    it "redirects to the my queue page" do
      set_current_user
      delete :destroy, id: Fabricate(:queue_item).id
      expect(response).to redirect_to my_queue_path
    end
    it "deletes the queue item from the queue" do 
      andy = Fabricate(:user)
      set_current_user(andy)
      delete :destroy, id: Fabricate(:queue_item, user: andy).id
      expect(QueueItem.count).to eq(0)
    end
    it "does not delete the queue item of another user" do 
      andy = Fabricate(:user)
      set_current_user(andy)
      betty = Fabricate(:user)
      queue_item = Fabricate(:queue_item, user: betty)
      delete :destroy, id: queue_item.id
      expect(betty.queue_items.count).to eq(1)
    end

    it "normalizes the position numbers for queue items" do 
      andy = Fabricate(:user)
      set_current_user(andy)
      queue_item1 = Fabricate(:queue_item, user: andy, position: 1)
      queue_item2 = Fabricate(:queue_item, user: andy, position: 2)
      delete :destroy, id: queue_item1.id
      expect(queue_item2.reload.position).to eq(1)
    end
  end

  describe "POST update_queue" do

    context "with valid inputs" do
      let(:andy) { Fabricate(:user)}
      before do
        set_current_user(andy)
      end
      it "redirects to the my queue page" do 
        queue_item1 = Fabricate(:queue_item, user: andy, position: 1)
        queue_item2 = Fabricate(:queue_item, user: andy, position: 2)
        post :update, queue_items: [ {id: queue_item1.id, position: 2 }, {id: queue_item2.id, position: 1 }]
        expect(response).to redirect_to my_queue_path
      end
      it "reorders the queue items by position" do
        queue_item1 = Fabricate(:queue_item, user: andy, position: 1)
        queue_item2 = Fabricate(:queue_item, user: andy, position: 2)
        post :update, queue_items: [ {id: queue_item1.id, position: 2 }, {id: queue_item2.id, position: 1 }]
        expect(andy.queue_items).to eq([queue_item2, queue_item1]) 
      end

      it "normalizes the position numbers" do 
        queue_item1 = Fabricate(:queue_item, user: andy, position: 1)
        queue_item2 = Fabricate(:queue_item, user: andy, position: 2)
        post :update, queue_items: [ {id: queue_item1.id, position: 3 }, {id: queue_item2.id, position: 1 }]
        expect(andy.queue_items.map(&:position)).to eq([1, 2])
      end
    end

    context "with invalid inputs" do
      let(:andy) { Fabricate(:user) }
      before do 
        set_current_user(andy)
      end
     it "should redirect to the my queue page" do 
        queue_item1 = Fabricate(:queue_item, user: andy, position: 1)
        queue_item2 = Fabricate(:queue_item, user: andy, position: 2)
        post :update, queue_items: [ {id: queue_item1.id, position: 3.4 }, {id: queue_item2.id, position: 1 }]
        expect(response).to redirect_to my_queue_path
     end
     it "should display an error msg" do
        queue_item1 = Fabricate(:queue_item, user: andy, position: 1)
        queue_item2 = Fabricate(:queue_item, user: andy, position: 2)
        post :update, queue_items: [ {id: queue_item1.id, position: 3.4 }, {id: queue_item2.id, position: 1 }]
        expect(flash[:error]).to be_present
     end
     it "should not change the order of the queue items" do
        queue_item1 = Fabricate(:queue_item, user: andy, position: 1)
        queue_item2 = Fabricate(:queue_item, user: andy, position: 2)
        post :update, queue_items: [ {id: queue_item1.id, position: 2 }, {id: queue_item2.id, position: 3.4 }]
        expect(queue_item1.position).to eq(1)
      end
    end

    context "with unauthenticated user" do 
      it_behaves_like "requires sign in" do 
        let(:action) { post :update, queue_items: [ {id: 2, position: 2 }, {id: 4, position: 3 } ] }
      end
    end

    context "with queue items not belonging to the current user" do
      it "does not change the queue items" do 
        andy = Fabricate(:user)
        set_current_user(andy)
        betty = Fabricate(:user)
        queue_item1 = Fabricate(:queue_item, user: andy, position: 1)
        queue_item2 = Fabricate(:queue_item, user: betty, position: 2)
        post :update, queue_items: [ {id: queue_item1.id, position: 2 }, {id: queue_item2.id, position: 3.4 }]
        expect(queue_item1.reload.position).to eq(1)
      end
    end
  end
end