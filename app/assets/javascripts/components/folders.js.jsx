var Folders = React.createClass({
	render() {
		var createFolder = ({id, name}) => <Folder getChildren={this.props.getChildren} key={id.$oid} name={name} id={id.$oid}/>
		var createFile = ({id, name, parent}) => <UserFile downloadFile={this.props.downloadFile} key={id} name={name} id={id} parent_id={parent}/>

		return 	<div >
					{this.props.folders.map(createFolder)}
					{" "}
					{this.props.user_files.map(createFile)}
				</div>
	}
});
