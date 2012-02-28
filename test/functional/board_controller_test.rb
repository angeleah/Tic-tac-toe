require 'test_helper'

class BoardControllerTest < ActionController::TestCase
  test "should get boards" do
    get :boards
    assert_response :success
  end

end
