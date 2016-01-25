var UserFile = React.createClass({
	render() {
		return <button onDoubleClick={this.props.downloadFile.bind(null, this.props.id, this.props.parent_id)} className="btn btn-warning">{this.props.name}</button>
  	}
});
