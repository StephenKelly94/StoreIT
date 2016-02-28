var Folder = React.createClass({
	getInitialState() {
			return({open:false})
	},
	toggleHover() {
			this.setState({open:!this.state.open})
	},
	render() {
		return	<tr>
					<td className="selected-item">
						<input type="checkbox" className={"delete-item delete-item-" + this.props.service}/>
					</td>
			   		<td className="psuedo-button" onMouseOver={this.toggleHover} onMouseOut={this.toggleHover} onClick={this.props.getChildren.bind(null, this.props.id)}>
						<span className={this.state.open ? "glyphicon glyphicon-folder-open" : "glyphicon glyphicon-folder-close"}/>
						<span className="item-name">{this.props.name}</span>
					</td>
				</tr>
  	}
});
