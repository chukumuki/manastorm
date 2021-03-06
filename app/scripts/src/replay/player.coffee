{zones, zoneNames, cardTypes} = require './enums'
_ = require 'lodash'
Entity = require './entity'

class Player extends Entity
	constructor: (definition, replay) ->
		super(definition, replay)

	getHand: ->
		hand = _.filter @replay.entities, (entity) =>
			entity.tags.ZONE is zones.HAND and entity.tags.CONTROLLER is @tags.CONTROLLER
 
		return _.sortBy hand, (entity) -> entity.tags.ZONE_POSITION

	getDeck: ->
		return _.filter @replay.entities, (entity) =>
			entity.tags.ZONE is zones.DECK and entity.tags.CONTROLLER is @tags.CONTROLLER

	getBoard: ->
		board = _.filter @replay.entities, (entity) =>
			entity.tags.ZONE is zones.PLAY and entity.tags.CONTROLLER is @tags.CONTROLLER and entity.tags.CARDTYPE is 4

		return _.sortBy board, (entity) -> entity.tags.ZONE_POSITION

	getSecrets: ->
		secrets = _.filter @replay.entities, (entity) =>
			entity.tags.ZONE is zones.SECRET and entity.tags.CONTROLLER is @tags.CONTROLLER

		return _.sortBy secrets, (entity) -> entity.tags.ZONE_POSITION

	getWeapon: ->
		weapon = _.filter @replay.entities, (entity) =>
			entity.tags.ZONE is zones.PLAY and entity.tags.CONTROLLER is @tags.CONTROLLER and entity.tags.CARDTYPE is 7

		return weapon[0]

	getHero: -> @replay.entities[@tags.HERO_ENTITY]

	getHeroPower: ->
		heroPower = _.filter @replay.entities, (entity) =>
			entity.tags.ZONE is zones.PLAY and entity.tags.CARDTYPE is cardTypes.HERO_POWER and entity.tags.CONTROLLER is @tags.CONTROLLER
		return heroPower[0]

	getOpponent: ->
		if @tags.CONTROLLER is 1
			return @replay.entities[3]
		else
			return @replay.entities[2]

	entityEnteredHand: (entity) ->
		# @emit 'entity-entered-hand', {entity}

	entityLeftDeck: (entity) ->
		# @emit 'entity-left-deck', {entity}

	entityEnteredDeck: (entity) ->
		# @emit 'entity-entered-deck', {entity}

	entityEnteredPlay: (entity) ->
		# @emit 'entity-entered-play', {entity}

	entityEnteredSecret: (entity) ->
		# @emit 'entity-entered-secret', {entity}

module.exports = Player
