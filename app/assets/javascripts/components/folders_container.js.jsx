var FoldersContainer = React.createClass({
  	getInitialState(){
		return {folders: [], user_files: [], foldersPath: this.props.foldersPath, service: this.props.service};
	},

	componentWillMount(){
        var that = this;
        $("#" + this.state.service + "_form").fileupload({
            add: function(e, data){
                if(data.originalFiles.length <= 3)
                {
                    // Filesize is limited to 100mb
                    if(data.files[0].size > 104857600){
                        console.log('Filesize is too big');
                    }else{
                        data.formData={path: that.state.path}
                        data.submit();
                        that.fetchFolders();
                    }
                }else {
                    console.log("Too many files")
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

	//Get the children(files and folders) and parent
	fetchFolders(){
        var that = this;
        $.ajax({
                url: this.state.foldersPath,
                dataType: 'json',
                success: function(data) {
                    that.setState({folders: data.children, user_files: data.user_files, parent: data.parent.$oid,
                                      path: data.folder_path, total_space: data.service.total_space, used_space: data.service.used_space})
                }
        });
	},

	//When folder is clicked change the folderspath and fetch folders
	getChildren(folderData) {
		this.state.foldersPath = "/folders/" + folderData;
		this.fetchFolders();
  	},


  	//When file is clicked download it
  	downloadFile(folderId, parentId){
  		window.location = "/" + this.state.service + "_download/" + parentId + "/" + folderId;
        $.notify(
          "Downloading",
          { position:"left bottom",  className: "info" }
        );
  	},

  	dirtyCheck(){
  		$.ajax({
    		url:  "/" + this.state.service + "_dirty_check/" +  this.state.foldersPath.replace("/folders/", ""),
    		type: "get"
    	});
		this.fetchFolders();
  	},

  	//when the back button is clicked change the folder to the parent
  	goBack(){
		if(this.state.parent)
			this.getChildren(this.state.parent);
  	},


	addFolder(){
    	var that = this;
		$.ajax({
    		url: "/" + this.state.service + "_create_folder/" + this.state.foldersPath.replace("/folders/", "") + "/" +  $('#folder-name').val(),
    		type: "post",
			success: function(data){
                $('#addFolder').modal('hide');
                $('#folder-name').val('').css('borderColor', 'red');
                that.dirtyCheck();
                $.notify(
                    "Added",
                    { position:"left bottom" , className: "success" }
                );
			}
    	});
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
                    that.dirtyCheck();
                    $.notify(
                      "Deleted",
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
		return 	<div>
                    <h3 className={"current-path-" + this.state.path} >{this.state.path}</h3>
                    <h3>{((this.state.used_space/this.state.total_space) * 100).toFixed(2) + "%"}</h3>
			   		<Folders addFolder={this.addFolder} deleteItem={this.deleteItem}
							 goBack={this.goBack} getChildren={this.getChildren}
							 downloadFile={this.downloadFile} folders={this.state.folders}
							 user_files={this.state.user_files} service={this.state.service}/>
				</div>
	}
});
