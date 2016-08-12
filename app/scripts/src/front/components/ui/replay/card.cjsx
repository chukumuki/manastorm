React = require 'react'
ReactDOM = require 'react-dom'
ReactTooltip = require("react-tooltip")
{subscribe} = require '../../../../subscription'

class Card extends React.Component

	render: ->
		# console.log 'rendering card'
		locale = if window.localStorage.language and window.localStorage.language != 'en' then '/' + window.localStorage.language else ''
		cardUtils = @props.cardUtils
		entity = @props.entity
		art = "https://s3.amazonaws.com/com.zerotoheroes/plugins/hearthstone/allCards#{locale}/#{entity.cardID}.png"


		imageCls = "art"
		if entity.cardID && !@props.isHidden
			originalCard = cardUtils?.getCard(entity.cardID)
			# Keep both the img (for hand) and background (for the rest)
			imgSrc = art
			style =
				backgroundImage: "url(#{art})"
			cls = "game-card visible"

			# Cost update 
			# We don't have the data for the cards in our opponent's hand
			if @props.cost and !@props.isInfoConcealed
				# console.log 'showing card cost', entity.cardID, entity, !@props.isInfoConcealed
				costCls = "card-cost"
				# console.log 'getting card cost from', originalCard, entity
				originalCost = originalCard.cost
				if entity.tags.COST is 0
					tagCost = 0
				else
					tagCost = entity.tags.COST || originalCost
				if tagCost < originalCost
					costCls += " lower-cost"
				else if tagCost > originalCost
					costCls += " higher-cost"
				cost = <div className={costCls}><span>{tagCost or 0}</span></div>
		else
			style = {}
			cls = "game-card"
			imgSrc = "images/cardback.png"
			imageCls += " card--unknown"

		frameCls = "frame minion"
		legendaryCls = ""

		console.log 'rendering card', entity.cardID, @props.cost, entity.tags.COST, @props.isHidden, entity, @props.isInfoConcealed

		if originalCard?.rarity is 'Legendary'
			legendaryCls = " legendary"

		if entity.tags.TAUNT
			frameCls += " card--taunt"

		if entity.tags.DEATHRATTLE
			effect = <div className="effect deathrattle"></div>
		if entity.tags.INSPIRE
			effect = <div className="effect inspire"></div>
		if entity.tags.POISONOUS
			effect = <div className="effect poisonous"></div>
		if entity.tags.TRIGGER
			effect = <div className="effect trigger"></div>

		if @props.className
			cls += " " + @props.className

		if @props.isDiscarded
			cls += " discarded"

		if entity.tags.DIVINE_SHIELD
			divineShield = <div className="overlay divine-shield"></div>

		if entity.tags.SILENCED
			overlay = <div className="overlay silenced"></div>

		if entity.tags.FROZEN
			overlay = <div className="overlay frozen"></div>

		if entity.tags.STEALTH
			overlay = <div className="overlay stealth"></div>

		if entity.tags.WINDFURY
			windfury = <div className="overlay windfury"></div>

		# if @props.stats
		healthClass = "card__stats__health"
		if entity.tags.DAMAGE > 0
			healthClass += " damaged"

		atkCls = "card__stats__attack"
		if originalCard and (originalCard.attack or originalCard.health) and !@props.isInfoConcealed
			originalAtk = originalCard.attack
			tagAtk = entity.tags.ATK || originalAtk
			if tagAtk > originalAtk
				atkCls += " buff"
			else if tagAtk < originalAtk
				atkCls += " debuff"

			originalHealth = originalCard.health
			tagHealth = entity.tags.HEALTH || originalHealth
			if tagHealth > originalHealth
				healthClass += " buff"

			tagDurability = entity.tags.DURABILITY || originalCard.durability
			stats = <div className="card__stats">
				<div className={atkCls}><span>{tagAtk or 0}</span></div>
				<div className={healthClass}><span>{(tagHealth or tagDurability) - (entity.tags.DAMAGE or 0)}</span></div>
			</div>


		entity.damageTaken = entity.damageTaken or 0
		# console.log entity.cardID, entity

		# Can attack
		if entity.highlighted
			highlight = <div className="option-on"></div>
			imageCls += " img-option-on"

			if @props.controller?.tags?.COMBO_ACTIVE == 1 and entity.tags.COMBO == 1
				imageCls += " combo"

		if entity.tags.POWERED_UP == 1
			imageCls += " img-option-on combo"
			# cls += " option-on"

		# Exhausted
		if entity.tags.EXHAUSTED == 1 and entity.tags.JUST_PLAYED == 1
			exhausted = <div className="exhausted"></div>

		if entity.tags.DAMAGE - entity.damageTaken > 0
			damage = <span className="damage"><span>{-(entity.tags.DAMAGE - entity.damageTaken)}</span></span>

		# console.log 'entity in card', entity, entity.getEnchantments
		if entity.getEnchantments?()?.length > 0
			# console.log '\tcard rendered', entity.cardID, entity
			# console.log 'enchantments', entity.getEnchantments()

			enchantments = entity.getEnchantments().map (enchant) ->
				enchantor = entity.replay.entities[enchant.tags.CREATOR]
				# console.log 'enchantor', enchantor, entity.replay.entities, enchant.tags.CREATOR, enchant
				enchantCard = cardUtils?.getCard(enchant.cardID)

				if enchantor
					enchantImage = 
						backgroundImage: "url(https://s3.amazonaws.com/com.zerotoheroes/plugins/hearthstone/allCards#{locale}/#{enchantor.cardID}.png)"
					enchantImageUrl = "https://s3.amazonaws.com/com.zerotoheroes/plugins/hearthstone/allCards#{locale}/#{enchantor.cardID}.png"

				<div className="enchantment">
					<h3 className="name">{cardUtils?.localizeName(enchantCard)}</h3>
					<div className="info-container">
						<div className="icon" style={enchantImage}></div>
						<span className="text" dangerouslySetInnerHTML={{__html: cardUtils?.localizeText(enchantCard)}}></span>
					</div>
				</div>

			enchantmentClass = "status-effects"
		# Build the card link on hover. It includes the card image + the status alterations			
		cardTooltip = 
			<div className="card-container">
				<img src={art} />
				<div className={enchantmentClass}>
					{enchantments}
				</div>
			</div>

		# Don't use tooltips if we don't know what card it is - or shouldn't know
		if entity.cardID && !@props.isHidden
			# link = '<img src="' + art + '">';
			return <div className={cls} style={@props.style} data-tip data-for={entity.id} data-place="right" data-effect="solid" data-delay-show="50" data-class="card-tooltip">
				<div className={imageCls} style={style}></div>
				<img src={imgSrc} className={imageCls}></img>
				<div className={frameCls}></div>
				<div className={legendaryCls}></div>
				{highlight}
				{effect}
				{windfury}
				{overlay}
				{damage}
				{exhausted}
				{stats}
				{divineShield}
				{cost}
				<ReactTooltip id={"" + entity.id} >
				    {cardTooltip}
				</ReactTooltip>
			</div>

		else
			return <div className={cls} style={@props.style}>
				<div className={imageCls} style={style}></div>
				<img src={imgSrc} className={imageCls} style={style}></img>
				<div className={frameCls}></div>
				<div className={legendaryCls}></div>
				{highlight}
				{effect}
				{windfury}
				{overlay}
				{damage}
				{exhausted}
				{stats}
				{divineShield}
			</div>

	# cleanTemporaryState: ->
	# 	# console.log 'cleaning temp state'
	# 	entity.damageTaken = entity.tags.DAMAGE or 0
	# 	entity.highlighted = false

	# reset: ->
	# 	console.log 'resetting card'
	# 	entity.damageTaken = 0
	# 	entity.highlighted = false

	# highlightOption: ->
	# 	entity.highlighted = true
	# 	console.log 'highlighting option', entity.cardID, entity, entity.highlighted

	componentDidUpdate: ->
		domNode = ReactDOM.findDOMNode(this)
		if domNode
			#console.log 'updating card dimensions'
			dimensions = @dimensions = domNode.getBoundingClientRect()
			@centerX = dimensions.left + dimensions.width / 2
			@centerY = dimensions.top + dimensions.height / 2
		#console.log @centerX, @centerY, dimensions, domNode

	getDimensions: ->
		#console.log 'getting dimensions for card', @centerX, @centerY
		return {@centerX, @centerY}

module.exports = Card
