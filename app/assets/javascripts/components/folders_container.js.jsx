var FoldersContainer = React.createClass({
  	getInitialState(){
		return {folders: [], user_files: [], foldersPath: this.props.foldersPath, service: this.props.service};
	},

	componentWillMount(){
        var that = this;


        //File upload functionality
        $("#" + this.state.service + "-form").fileupload({
            dropZone: $(".dropzone"),
            //When files get added
            add: function(e, data){
                //If there is not too many files
                if(data.originalFiles.length <= 3)
                {
                    // Filesize is limited to 100mb
                    if(data.files[0].size > 104857600){
                        $.notify(
                          "File too large",
                          { position:"left bottom",  className: "warn" }
                        );
                    //Submit files and alert
                    }else{
                        if(that.state.service === "onedrive"){
                          that.setState({path: that.state.path.replace("/", "/drive/root:/")})
                        }
                        data.formData={path: that.state.path}
                        data.submit()
                            //On successful upload
                            .success(function(result, textStatus, jqXHR){
                                $.notify(
                                  "Uploaded file:  '" + result.name + "'",
                                  { position:"left bottom",  className: "success" }
                                );
                                that.hardRefresh();
                			})
                            //If it fails
                            .error(function (jqXHR, textStatus, errorThrown) {
                                console.log(jqXHR)
                                $.notify(
                                  "Something has gone wrong",
                                  { position:"left bottom",  className: "warn" }
                                );
                            })
                        $('#uploadFile-'+that.state.service).modal('hide');
                    }
                }else {
                    $.notify(
                      "Too many files",
                      { position:"left bottom",  className: "warn" }
                    );
                }
            }
        });


		this.fetchFolders();
		this.dirtyCheckTimer = setInterval(this.dirtyCheck, 60000);
	},

    componentWillUnmount(){
        $("#" + this.state.service + "_form").fileupload('destroy');
        clearInterval(this.dirtyCheckTimer);
        this.dirtyCheckTimer = false;
	},

    //Checks the folder name
    checkName(){
		var folderName = $("#folder-name-" + this.props.service)
		var border = $("#add-folder-" + this.props.service)
		if(folderName.val() === ""){
			border.css('borderColor', 'black');
		}
		else if(!$.trim(folderName.val()) || this.state.folders.some(function (element){return element.name === folderName.val() })){
			border.css('borderColor', 'red');
		}
		else{
			border.css('borderColor', 'green');
		}
	},

	//Get the children(files and folders) and parent
	fetchFolders(){
        var that = this;
        $.ajax({
            url: this.state.foldersPath,
            dataType: 'json',
            success: function(data) {
                that.setState({folders: data.children, user_files: data.user_files, parent: data.parent.$oid,
                                  path: data.folder_path, total_space: data.service.total_space, used_space: data.service.used_space})
                //Handle onedrives path to make it look nice
                if(that.state.service === "onedrive"){
                  that.setState({path: data.folder_path.replace("/drive/root:/", "/")})
                }
            },
            error: function(err) {
                $.notify(
                  "Files are not consistent",
                  { position:"left bottom",  className: "warn" }
                );
            }
        });
	},

	//When folder is clicked change the folderspath and fetch folders
	getChildren(folderData) {
		this.state.foldersPath = "/folders/" + folderData;
		this.fetchFolders();
  	},


  	//When file is clicked download it
  	downloadFile(folderId, parentId, name ){
  		window.location = "/" + this.state.service + "_download/" + parentId + "/" + folderId;
        $.notify(
          "Downloading file: '" + name + "'",
          { position:"left bottom",  className: "info" }
        );
  	},

    dirtyCheck(){
        var that = this;
		$.ajax({
    		url:  "/" + this.state.service + "_dirty_check/" +  this.state.foldersPath.replace("/folders/", ""),
    		type: "get",
            success: function(data) {
                that.fetchFolders();
            }
    	});
  	},

    hardRefresh(){
        var that = this;
		$.ajax({
    		url:  "/" + this.state.service + "_hard_refresh/",
    		type: "get",
            success: function(data) {
                that.fetchFolders();
            }
    	});
  	},

  	//when the back button is clicked change the folder to the parent
  	goBack(){
		if(this.state.parent)
			this.getChildren(this.state.parent);
  	},


	addFolder(){
    	var that = this;
        if($("#add-folder-" + this.props.service).css('borderColor') === 'rgb(0, 128, 0)'){
    		$.ajax({
        		url: "/" + this.state.service + "_create_folder/" + this.state.foldersPath.replace("/folders/", "") + "/" +  $('#folder-name-'+this.state.service).val(),
        		type: "post",
    			success: function(data){
                    $('#add-folder-'+that.state.service).css('borderColor', 'black');
                    $('#folder-name-'+that.state.service).val('');
                    that.hardRefresh();
                    $.notify(
                        "Added folder: '" + data.name + "'",
                        { position:"left bottom" , className: "success" }
                    );
    			}
        	});
        }
	},


	deleteItem(){
        // Documentation for querySelectorAll https://www.w3.org/TR/selectors/#attribute-substrings
        // class$= means a class name that ends with. This makes sure that it's deleting for the same service
        var checkedBoxes = $('input[class$=delete-item-' + this.state.service + ']:checked');
        // So I can use 'this' in scope
        var that = this;
		var itemDelete = function(itemId){
    		$.ajax({
        		url: "/" + that.state.service + "_delete_item/" + that.state.foldersPath.replace("/folders/", "") + "/"+  itemId,
        		type: "delete",
    			success: function(data){
                    that.hardRefresh();
                    $.notify(
                      "Deleted item: '" + data.name + "'",
                      { position:"left bottom",  className: "success" }
                    );
    			}
        	});
		}
        for (var i = 0; i < checkedBoxes.length; i++) {
            var row = checkedBoxes[i].parentNode.parentNode
			var itemName = row.getElementsByClassName("item-name")[0].innerHTML
            this.state.folders.some(function (element){ if (element.name === itemName) itemDelete(element.id.$oid)})
			this.state.user_files.some(function (element){ if (element.name === itemName) itemDelete(element.id)})
        }
	},

	render() {
        var myLeft = { textAlign: 'left', float: 'left', display: 'inline-block'}
        var myRight = { textAlign: 'right', float: 'right', display: 'inline-block'}


		return 	<div>
                    <div className="service-title">
                        <h1> {this.props.service} </h1>
                        <hr/>
                    </div>
                    <div style={myRight} className="col-md-12 service-heading">
                        <div className="other-buttons">
                            <button className="menu-button" onClick={this.goBack}>
                                Back
                            </button>
                            <button className="menu-button" onClick={this.deleteItem }>
                                Delete Item
                            </button>
                            <button className="menu-button" data-toggle="modal" data-target={'#uploadFile-'+this.state.service}>Upload File</button>
                        </div>
                        <div style={myLeft}  id={"add-folder-" + this.props.service} className="add-folder">
                            <button type="button" className="menu-button folder-submit" onClick={this.addFolder}>
                                <span className="glyphicon glyphicon-plus-sign"/>
                            </button>
                            <input type="text" id={"folder-name-" + this.props.service } className="folder-name" onChange={this.checkName}/>
                        </div>
                    </div>
			   		<Folders path={this.state.path} used_space={this.state.used_space} total_space={this.state.total_space} getChildren={this.getChildren}
							 downloadFile={this.downloadFile} folders={this.state.folders}
							 user_files={this.state.user_files} service={this.state.service}/>
				</div>
	}
});
