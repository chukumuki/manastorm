React = require 'react'
Card = require './card'

ActiveSpell = React.createClass
	componentDidMount: ->

	render: ->
		@spell = @props.replay.activeSpell

		return null unless @spell

		# console.log 'rendering activeSpell'
		return 	<Card entity={@spell} key={@spell.id} ref={@spell.id} className="active-spell"/>

	getCardsMap: ->
		result = {}

		if !@spell
			return result

		result[@spell.id] = this.refs[@spell.id]
		# console.log 'returning activeSpell map', result

		return result

module.exports = ActiveSpell
