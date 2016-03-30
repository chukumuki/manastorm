React = require 'react'
Card = require './card'
HeroCard = require './herocard'
HeroPower = require './heropower'
Weapon = require './weapon'

Hero = React.createClass
	componentDidMount: ->

	render: ->
		@hero = @props.entity.getHero()
		@heroPower = @props.entity.getHeroPower()
		@weapon = @props.entity.getWeapon()
		@secrets = @props.entity.getSecrets()
		cardUtils = @props.replay.cardUtils
			
		return 	<div className="hero">
					<Weapon entity={@weapon} key={@weapon?.id} ref={@weapon?.id} cardUtils={cardUtils} className="weapon"/>
					<HeroCard entity={@hero} key={@hero.id} secrets={@secrets} ref={@hero.id} showSecrets={@props.showConcealedInformation} className="avatar"/>
					<HeroPower entity={@heroPower} key={@heroPower.id} ref={@heroPower.id} className="power"/>
				</div>

	getCardsMap: ->
		result = {}

		if !@hero || !@heroPower
			return result

		#console.log 'building cards map in hero', this.refs

		result[@hero.id] = this.refs[@hero.id]
		result[@heroPower.id] = this.refs[@heroPower.id]
		if @weapon
			result[@weapon.id] = this.refs[@weapon.id]

		#console.log '\tbuilt cards map', result

		return result

module.exports = Hero
