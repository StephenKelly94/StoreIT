var Folder = React.createClass({
	render() {
		return <button onDoubleClick={this.props.getChildren.bind(null, this.props.id)} className="btn btn-info">{this.props.name}</button>
  	}
});
