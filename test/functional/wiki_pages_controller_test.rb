require 'test_helper'

class WikiPagesControllerTest < ActionController::TestCase
  context "The wiki pages controller" do
    setup do
      @user = Factory.create(:user)
      @mod = Factory.create(:moderator_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
    end
    
    context "index action" do
      setup do
        Factory.create(:wiki_page, :title => "abc")
      end
      
      should "list all wiki_pages" do
        get :index
        assert_response :success
      end
      
      should "list all wiki_pages (with search)" do
        get :index, {:search => {:title_matches => "abc"}}
        assert_response :success
      end
    end
    
    context "show action" do
      setup do
        @wiki_page = Factory.create(:wiki_page)
      end
      
      should "render" do
        get :show, {:id => @wiki_page.id}
        assert_response :success
      end
    end
    
    context "create action" do
      should "create a wiki_page" do
        assert_difference("WikiPage.count", 1) do
          post :create, {:wiki_page => {:title => "abc", :body => "abc"}}, {:user_id => @user.id}
        end
      end
    end
    
    context "update action" do
      setup do
        @wiki_page = Factory.create(:wiki_page)
      end
      
      should "update a wiki_page" do
        post :update, {:id => @wiki_page.id, :wiki_page => {:body => "xyz"}}, {:user_id => @user.id}
        @wiki_page.reload
        assert_equal("xyz", @wiki_page.body)
      end
    end
    
    context "destroy action" do
      setup do
        @wiki_page = Factory.create(:wiki_page)
      end
      
      should "destroy a wiki_page" do
        assert_difference("WikiPage.count", -1) do
          post :destroy, {:id => @wiki_page.id}, {:user_id => @mod.id}
        end
      end
    end
    
    context "revert action" do
      setup do
        @wiki_page = Factory.create(:wiki_page, :body => "1")
        @wiki_page.update_attributes(:body => "1 2")
        @wiki_page.update_attributes(:body => "1 2 3")
      end
      
      should "revert to a previous version" do
        version = @wiki_page.versions(true).last
        assert_equal("1", version.body)
        post :revert, {:id => @wiki_page.id, :version_id => version.id}
        @wiki_page.reload
        assert_equal("1", @wiki_page.body)
      end
    end
  end
end
