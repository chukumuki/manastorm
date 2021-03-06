React = require 'react'
SubscriptionList = require '../../../../subscription-list'

class GameLog extends React.Component
	componentDidMount: ->
		@subs = new SubscriptionList

		@replay = @props.replay
		@logIndex = 0

		@subs.add @replay, 'new-log', (log) =>
			@log = log

	render: ->
		return null unless !@props.hide
		# console.log 'rendering gamelog'
		buttonText = <span>Full log</span>
		if @props.logOpen
			buttonText = <span>Hide log</span>

		<div className="game-log">
			{@log} 
			<button className="btn btn-default" onClick={@props.onLogClick}>{buttonText}</button>
		</div>


module.exports = GameLog