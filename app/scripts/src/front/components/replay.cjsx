React = require 'react'
ReactDOM = require 'react-dom'

# {ButtonGroup, Button} = require 'react-photonkit'
ReplayPlayer = require '../../replay/replay-player'
HSReplayParser = require '../../replay/parsers/hs-replay'
PlayerName = require './ui/replay/player-name'
Hand = require './ui/replay/hand'
Hero = require './ui/replay/hero'
Deck = require './ui/replay/deck'
Mulligan = require './ui/replay/mulligan'
Discover = require './ui/replay/discover'
EndGame = require './ui/replay/endgame'
SecretRevealed = require './ui/replay/secretRevealed'
SplashReveal = require './ui/replay/splashReveal'
Fatigue = require './ui/replay/fatigue'
Board = require './ui/replay/board'
Mana = require './ui/replay/mana'
Health = require './ui/replay/health'
#Scrubber = require './ui/replay/scrubber'
Timeline = require './ui/replay/timeline'
GameLog = require './ui/replay/gamelog'
Play = require './ui/replay/play'
Target = require './ui/replay/target'
TargetManager = require './ui/replay/targetManager'
Turn = require './ui/replay/turn'
TurnLog = require './ui/replay/turnLog'
ActiveSpell = require './ui/replay/activeSpell'

ReactTooltip = require("react-tooltip")
{subscribe} = require '../../subscription'
_ = require 'lodash'

class Replay extends React.Component
	constructor: (props) ->
		super(props)

		# @reloadGame props.route.replay
		@state = replay: new ReplayPlayer(new HSReplayParser(props.route.replay))
		# console.log 'replay-player created'

		@state.style = {}

		@showAllCards = false
		@mainPlayerSwitched = false
		@dirty = false

		subscribe @state.replay, 'players-ready', =>
			console.log 'in players-ready'
			@callProtectedCallback()

		# subscribe @state.replay, 'reset', =>
		# 	console.log 'in reset' 
		# 	@callback

		subscribe @state.replay, 'moved-timestamp', =>
			# console.log 'in moved-timestamp'
			@callProtectedCallback()
			# if !@dirty
			# 	@dirty = true 
			# 	setTimeout @callback, 300

		subscribe @state.replay, 'game-generated', =>
			@gameGenerated = true

		@bindKeypressHandlers()

		# subscribe @state.replay, 'reload-game', (newGame) =>
		# 	console.log 'reloading', newGame
		# 	@reloadGame newGame

		# console.log 'before init', @mounted
		#console.log('sub', @sub)
		@state.replay.init()

		@mounted = true
		# console.log 'after init', @mounted
		#console.log 'first init done'
		# @state.replay.buildGameLog()
		#console.log 'log built'
		#@state.replay.init()
		#console.log 'second init done'

		@displayConf = {
			showLog: false
		}
		# console.log 'new version'


	bindKeypressHandlers: =>
		window.addEventListener 'keydown', (e) =>
			if @mousingover
				@handleKeyDown e

	componentDidMount: ->
		window.addEventListener 'resize', @updateDimensions

		@mounted = true
		@updateDimensions()

	callProtectedCallback: ->
		if !@dirty
			@dirty = true 
			@callback()


	updateDimensions: =>
		if this.refs['root']
			@state.style.fontSize = this.refs['root'].offsetWidth / 50.0 + 'px'
			# console.log 'updated dimensions'
			@callProtectedCallback()

	callback: =>
		if !@mounted
			# console.log 'waiting for callback', @mounted
			setTimeout @callback, 50
		else
			try
				# console.log 'forcing update'
				that = this
				setTimeout () ->
					that.forceUpdate()
					that.dirty = false
				, 50
			catch e
				console.error 'issue in forceUpdate', e

	render: ->
		replay = @state.replay
		# return null unless @gameGenerated

		# console.log 'rerendering replay'

		if replay.players.length == 2
			inMulligan = replay.opponent.tags?.MULLIGAN_STATE < 4 or replay.player.tags?.MULLIGAN_STATE < 4
			# console.log 'All players are here'

			topArea = <div className="top" >
				<PlayerName entity={replay.opponent} isActive={replay.opponent.id == replay.getActivePlayer().id}/>
				<Deck entity={replay.opponent} />
				<Hand entity={replay.opponent} isInfoConcealed={true} isHidden={!@showAllCards} replay={replay}/>
				<Hero entity={replay.opponent} replay={replay} ref="topHero" showConcealedInformation={@showAllCards}/>
				<Board entity={replay.opponent} ref="topBoard" tooltips={true} replay={replay}/>
				<Mana entity={replay.opponent} />
			</div>

			topOverlay = <div className="top" >
				<Mulligan entity={replay.opponent} inMulligan={inMulligan} mulligan={replay.turns[1].opponentMulligan} isHidden={!@showAllCards} replay={replay}/>
				<Discover entity={replay.opponent} discoverController={replay.discoverController} discoverAction={replay.discoverAction} isHidden={!@showAllCards} />
				<EndGame entity={replay.opponent} isEnd={replay.isEndGame} />
			</div>

			bottomArea = <div className="bottom"><Board entity={replay.player} ref="bottomBoard" tooltips={true} replay={replay}/>
				<PlayerName entity={replay.player} isActive={replay.player.id == replay.getActivePlayer().id}/>
				<Deck entity={replay.player} />
				<Hero entity={replay.player} replay={replay} ref="bottomHero" showConcealedInformation={true}/>
				<Hand entity={replay.player} isInfoConcealed={false} isHidden={false} replay={replay} />
				<Mana entity={replay.player} />
			</div>

			bottomOverlay = <div className="bottom">
				<Mulligan entity={replay.player} inMulligan={inMulligan} mulligan={replay.turns[1].playerMulligan} isHidden={false} replay={replay}/>
				<Discover entity={replay.player} discoverController={replay.discoverController} discoverAction={replay.discoverAction} isHidden={false} />
				<EndGame entity={replay.player} isEnd={replay.isEndGame} />
			</div>

			commonOverlay = <div className="common">
				<Fatigue entity={replay.getActivePlayer()} isFatigue={replay.isFatigue()} action={replay.getCurrentAction()} />
				<SecretRevealed entity={replay.revealedSecret} replay={replay} />
				<SplashReveal entity={replay.splashEntity} replay={replay} />
			</div>
			# console.log 'components are ok'

		else 
			console.warn 'Missing players', replay.players
			return null


		targets = []
		if replay.targetDestination and replay.targetSource
			targetManager = <TargetManager replay={replay} components={this} />
			# console.log 'retrieving source and targets from', replay.targetSource, replay.targetDestination
			# if this.refs['topBoard'] and this.refs['bottomBoard'] and this.refs['topHero'] and this.refs['bottomHero'] and this.refs['activeSpell']
			# 	# console.log 'topBoard cards', this.refs['topBoard'].getCardsMap
			# 	allCards = @merge this.refs['topBoard'].getCardsMap(), this.refs['bottomBoard'].getCardsMap(), this.refs['topHero'].getCardsMap(), this.refs['bottomHero'].getCardsMap(), this.refs['activeSpell'].getCardsMap()
			# 	console.log 'merged cards', allCards
			# 	source = @findCard allCards, replay.targetSource

			# for targetId in replay.targetDestination
			# 	target = @findCard allCards, targetId
			# 	console.log 'adding target', target, source
			# 	targets.push <Target source={source} target={target} type={replay.targetType} key={'target' + replay.targetSource + '' + targetId}/>

		playButton = <button className="btn btn-default btn-control glyphicon glyphicon-play" onClick={@onClickPlay} />

		if @state.replay.speed > 0
			playButton = <button className="btn btn-default btn-control glyphicon glyphicon-pause" onClick={@onClickPause}/>

		blur = ""
		overlayCls = "overlay"
		if replay.choosing() or replay.isFatigue()
			blur = "blur"
			overlayCls += " silent"

		# console.log 'applying style', @state.style
		return <div className="replay" ref="root" style={@state.style} onMouseEnter={@onMouseEnter} onMouseLeave={@onMouseLeave}>
					<ReactTooltip />
					
					<div className="game">
						<div className={"game-area " + blur}>
							{topArea}
							{bottomArea}
							{targetManager}
							<div className="active-spell-container">
								<ActiveSpell ref="activeSpell" replay={replay} />
							</div>
							<Turn replay={replay} onClick={@onTurnClick} active={@displayConf.showLog }/>
						</div>
						<div className={overlayCls}>
							{topOverlay}
							{bottomOverlay}
							{commonOverlay}
						</div>
						<div className={"game-border"}></div>
					</div>
					<TurnLog show={@displayConf.showLog} replay={replay} onTurnClick={@onGoToTurnClick} onClose={@onTurnClick}/>
					<GameLog replay={replay} onLogClick={@onTurnClick} logOpen={@displayConf.showLog}/>
					<form className="replay__controls padded">
						<div className="btn-group">
							 <button className="btn btn-default btn-control glyphicon glyphicon-backward" onClick={@goPreviousTurn}/>
							 <button className="btn btn-default btn-control glyphicon glyphicon-step-backward" onClick={@goPreviousAction}/>
							{playButton}
							 <button className="btn btn-default btn-control glyphicon glyphicon-step-forward" onClick={@goNextAction}/>
							 <button className="btn btn-default btn-control glyphicon glyphicon-forward" onClick={@goNextTurn}/>
						</div>
						<Timeline replay={replay} />
						<div className="btn-group">
							<div className="playback-speed">
								<div className="dropup"> 
									<button className="btn btn-default btn-control dropdown-toggle ng-binding" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true"> {@state.replay.speed}x <span className="caret"></span> </button> 
									<ul className="dropdown-menu" aria-labelledby="dropdownMenu1">
										<li><a onClick={@onClickChangeSpeed.bind(this, 1)}>1x</a></li> 
										<li><a onClick={@onClickChangeSpeed.bind(this, 2)}>2x</a></li> 
										<li><a onClick={@onClickChangeSpeed.bind(this, 4)}>4x</a></li> 
										<li><a onClick={@onClickChangeSpeed.bind(this, 8)}>8x</a></li> 
									</ul> 
								</div>
							</div>

							<label className="btn btn-default btn-control glyphicon glyphicon-backward" for="show-hidden-cards">
							<input type="checkbox" id="show-hidden-cards" checked={@showAllCards} onChange={@onShowCardsChange} hidden />
							</label>

							<label className="btn btn-default btn-control glyphicon glyphicon-backward" for="switch-main-player">
								<input type="checkbox" id="switch-main-player" checked={@mainPlayerSwitched} onChange={@onMainPlayerSwitchedChange} hidden />
							</label>
						</div>
						<div id="padding"></div>
					</form>
					
				</div>


	handleKeyDown: (e) =>
		# console.log 'keydown', e
		switch e.code
			when 'ArrowRight'
				@goNextAction e
			when 'ArrowLeft'
				@goPreviousAction e
			when 'ArrowUp'
				@goNextTurn e
			when 'ArrowDown'
				@goPreviousTurn e

	onMouseEnter: (e) =>
		# console.log 'mouse entered', e
		@mousingover = true

	onMouseLeave: (e) =>
		# console.log 'mouse left', e
		@mousingover = false

	goNextAction: (e) =>
		# nononono.sendexception
		e.preventDefault()
		@state.replay.pause()
		@state.replay.goNextAction()
		# start = new Date().getTime()
		@callProtectedCallback()
		# console.log 'force update took', new Date().getTime() - start

	goPreviousAction: (e) =>
		e.preventDefault()
		@state.replay.pause()
		@state.replay.goPreviousAction()
		# start = new Date().getTime()
		@callProtectedCallback()
		# console.log 'force update took', new Date().getTime() - start

	goNextTurn: (e) =>
		e.preventDefault()
		@state.replay.pause()
		@state.replay.goNextTurn()
		@callProtectedCallback()

	goPreviousTurn: (e) =>
		e.preventDefault()
		@state.replay.pause()
		@state.replay.goPreviousTurn()
		@callProtectedCallback()

	onClickPlay: (e) =>
		e.preventDefault()
		@state.replay.autoPlay()
		@callProtectedCallback()

	onClickPause: (e) =>
		e.preventDefault()
		@state.replay.pause()
		@callProtectedCallback()

	onClickChangeSpeed: (speed) ->
		@state.replay.changeSpeed speed
		@callProtectedCallback()

	onShowCardsChange: =>
		@showAllCards = !@showAllCards
		@state.replay.showAllCards = @showAllCards
		@callProtectedCallback()

	onMainPlayerSwitchedChange: =>
		@mainPlayerSwitched = !@mainPlayerSwitched
		@state.replay.switchMainPlayer()
		@callProtectedCallback()

	onTurnClick: (e) =>
		e.preventDefault()
		@displayConf.showLog = !@displayConf.showLog
		if @displayConf.showLog
			replay = @state.replay
			setTimeout () ->
				replay.cardUtils.refreshTooltips()
		@callProtectedCallback()

	onGoToTurnClick: (turn, e) =>
		# console.log 'clicked to go to a turn', turn
		# Mulligan is turn 1
		@state.replay.goToTurn(turn + 1)
		@callProtectedCallback()
		


	findCard: (allCards, cardID) ->
		#console.log 'finding card', topBoardCards, bottomBoardCards, cardID
		if !allCards || !cardID
			return undefined

		#console.log 'topBoard cardsMap', topBoardCards, cardID
		card = allCards[cardID]
		#console.log '\tFound card', card
		return card

	# https://gist.github.com/sheldonh/6089299
	merge: (xs...) ->
	  	if xs?.length > 0
	    	tap {}, (m) -> m[k] = v for k,v of x for x in xs
		tap = (o, fn) -> fn(o); o

module.exports = Replay
