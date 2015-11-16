class UserFilesController < ApplicationController
  before_action :set_user_file, only: [:show, :edit, :update, :destroy]

  # GET /user_files
  # GET /user_files.json
  def index
    @folders = Folder.all
  end

  # GET /user_files/1
  # GET /user_files/1.json
  def show
  end

  # GET /user_files/new
  def new
    @user_file = UserFile.new
    @folders = Folder.all
  end

  # GET /user_files/1/edit
  def edit
  end

  # POST /user_files
  # POST /user_files.json
  def create
    @user_file = UserFile.new(user_file_params)
    @folder = Folder.find_by(name: user_file_params[:parent])
    @folder.user_files.push(@user_file)
    respond_to do |format|
      if @user_file.save
        format.html { redirect_to @folder, notice: 'User file was successfully created.' }
        format.json { redirect_to @folder, status: :created, location: @user_file.path }
      else
        format.html { render :new }
        format.json { render json: @user_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_files/1
  # PATCH/PUT /user_files/1.json
  def update
    respond_to do |format|
      if @user_file.update(user_file_params)
        format.html { redirect_to @user_file, notice: 'User file was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_file }
      else
        format.html { render :edit }
        format.json { render json: @user_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_files/1
  # DELETE /user_files/1.json
  def destroy
    @user_file.destroy
    respond_to do |format|
      format.html { redirect_to user_files_url, notice: 'User file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_file
      @folder = Folder.where("user_files.id" => params[:$oid]).first
      puts "--------------------------------------------"
      puts @folder
      @user_file = @folder.user_files.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_file_params
      params.require(:user_file).permit(:name, :path, :parent)
    end
end
