var FoldersContainer = React.createClass({
  	getInitialState(){
		return {folders: [], user_files: [], foldersPath: this.props.foldersPath, service: this.props.service};
	},

	componentWillMount(){
		this.fetchFolders();
		this.dirtyCheckTimer = setInterval(this.dirtyCheck, 10000);
	},

    componentWillUnmount(){
        clearInterval(this.dirtyCheckTimer);
        this.dirtyCheckTimer = false;
	},

	//Get the children(files and folders) and parent
	fetchFolders(){
		$.getJSON(
			this.state.foldersPath,
			(data) => this.setState({folders: data.children, user_files: data.user_files, parent: data.parent.$oid})
		);
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


	deleteFolder(){
        // Documentation for querySelectorAll https://www.w3.org/TR/selectors/#attribute-substrings
        // class$= means a class name that ends with. This makes sure that it's deleting for the same service
        var checkedBoxes = $('input[class$=delete-item-' + this.props.service + ']:checked');
        // So I can use 'this' in scope
        var that = this;
		var deleteItem = function(itemId){
    		$.ajax({
        		url: "/" + that.state.service + "_delete_folder/" + that.state.foldersPath.replace("/folders/", "") + "/"+  itemId,
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
            this.state.folders.some(function (element){ if (element.name === itemName) deleteItem(element.id.$oid)})
			this.state.user_files.some(function (element){ if (element.name === itemName) deleteItem(element.id)})
        }
	},

	render() {
		return 	<div>
			   		<Folders addFolder={this.addFolder} deleteFolder={this.deleteFolder}
							 goBack={this.goBack} getChildren={this.getChildren}
							 downloadFile={this.downloadFile} folders={this.state.folders}
							 user_files={this.state.user_files} service={this.state.service}/>
				</div>
	}
});
