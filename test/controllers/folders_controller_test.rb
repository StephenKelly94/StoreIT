require 'test_helper'

class FoldersControllerTest < ActionController::TestCase
  setup do
    @folder = folders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:folders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create folder" do
    assert_difference('Folder.count') do
      post :create, folder: { name: @folder.name, path: @folder.path }
    end

    assert_redirected_to folder_path(assigns(:folder))
  end

  test "should show folder" do
    get :show, id: @folder
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @folder
    assert_response :success
  end

  test "should update folder" do
    patch :update, id: @folder, folder: { name: @folder.name, path: @folder.path }
    assert_redirected_to folder_path(assigns(:folder))
  end

  test "should destroy folder" do
    assert_difference('Folder.count', -1) do
      delete :destroy, id: @folder
    end

    assert_redirected_to folders_path
  end
end
