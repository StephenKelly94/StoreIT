var Folders = React.createClass({
	checkName(){
		var folderName = $("#folder-name-" + this.props.service)
		var border = $("#add-folder-" + this.props.service)
		if(!$.trim(folderName.val()) || this.props.folders.some(function (element){return element.name === folderName.val() })){
			border.css('borderColor', 'red');
		}
		else{
			border.css('borderColor', 'green');
		}
	},

	render() {
		var createFolder = ({id, name}) => <Folder service={this.props.service} getChildren={this.props.getChildren} key={id.$oid} name={name} id={id.$oid}/>
		var createFile = ({id, name, parent}) => <UserFile service={this.props.service} downloadFile={this.props.downloadFile} key={id} name={name} id={id} parent_id={parent}/>

		return 	<div>
					<table className="folder-browser" >
						<tbody>
							<tr>
								<th></th>
								<th>
									<span>Name</span>
									<button className="menu-button" onClick={this.props.goBack}>
										Back
									</button>
									<button className="menu-button" onClick={this.props.deleteItem 	}>
										Delete Item
									</button>
									<button className="menu-button" data-toggle="modal" data-target="#addFolder">
										Add Folder
									</button>
									<div id={"add-folder-" + this.props.service} className="add-folder">
										<button type="button" className="menu-button folder-submit" onClick={this.props.addFolder}>
											<span className="glyphicon glyphicon-plus-sign"/>
										</button>
										<input type="text" id={"folder-name-" + this.props.service } className="folder-name" onChange={this.checkName}/>
									</div>
								</th>
							</tr>
								{this.props.folders.map(createFolder)}
								{this.props.user_files.map(createFile)}
						</tbody>
					</table>
				</div>
	}
});
