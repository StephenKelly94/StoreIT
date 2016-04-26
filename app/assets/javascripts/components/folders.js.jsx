var Folders = React.createClass({
	render() {
		var createFolder = ({id, name}) => <Folder service={this.props.service} getChildren={this.props.getChildren} key={id.$oid} name={name} id={id.$oid}/>
		var createFile = ({id, name, parent}) => <UserFile service={this.props.service} downloadFile={this.props.downloadFile} key={id} name={name} id={id} parent_id={parent}/>
		var myLeft = { textAlign: 'left', float: 'left', display: 'inline-block'}
        var myRight = { textAlign: 'right', float: 'right', display: 'inline-block'}

		return 	<div>
					<h3 style={myLeft} className={"col-md-9 current-path"} >{this.props.path}</h3>
					<h3 style={myRight} className="col-md-3">{((this.props.used_space/this.props.total_space) * 100).toFixed(2) + "%"}</h3>
					<div className="table-head-separator"></div>
					<table className="folder-browser" >
						<tbody>
							{this.props.folders.map(createFolder)}
							{this.props.user_files.map(createFile)}
						</tbody>
					</table>
				</div>
	}
});
