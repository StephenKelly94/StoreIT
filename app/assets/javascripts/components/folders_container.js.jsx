var FoldersContainer = React.createClass({
	//Store the current folder the user is in (changes so can't use props)
	contextTypes: {
    	foldersPath: React.PropTypes.string
  	},

  	getInitialState(){
		this.context.foldersPath = this.props.foldersPath
		return {folders: [], user_files: []}
	},

	componentWillMount(){
		this.fetchFolders()
		setInterval(this.dirtyCheck, 10000)
	},

	//Get the children(files and folders) and parent
	fetchFolders(){
		$.getJSON(
			this.context.foldersPath,
			(data) => this.setState({folders: data.children, user_files: data.user_files, parent: data.parent.$oid})
		)
	},

	//When folder is clicked change the folderspath and fetch folders
	getChildren(folderData) {
		this.context.foldersPath = "/folders/" + folderData
		this.fetchFolders()
  	},

  	//When file is clicked download it
  	downloadFile(folderId, parentId){	
  		window.location = "/dropbox_download/" + parentId + "/" + folderId
  	},

  	dirtyCheck(){
  		$.ajax({
    		url: "/dirty_check/" + this.context.foldersPath.replace("/folders/", ""),
    		type: "get"
    	})
	this.fetchFolders()
  	},

  	//when the back button is clicked change the folder to the parent	
  	goBack(){
  		this.getChildren(this.state.parent)
  	},

	render() {
		return 	<div>
			   		<Folders getChildren={this.getChildren} downloadFile={this.downloadFile} folders={this.state.folders} user_files={this.state.user_files}/>
			   		<br/>
			   		<button className="btn btn-danger" onClick={this.goBack}> Back </button>
			   	</div>
	}
});
