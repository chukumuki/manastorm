React = require 'react'
SubscriptionList = require '../../../../subscription-list'
ReactCSSTransitionGroup = require 'react-addons-css-transition-group'
_ = require 'lodash'

Target = React.createClass
	componentDidMount: ->
		#console.log 'target component did mount'

	render: ->
		#console.log 'trying to render target', @props
		return null unless @props.source && @props.target

		sourceDims = @props.source.getDimensions()
		console.log 'sourceDims', sourceDims
		targetDims = @props.target.getDimensions()
		console.log 'targetDims', targetDims

		arrowWidth = Math.abs(sourceDims.centerX - targetDims.centerX)
		arrowHeight = Math.abs(sourceDims.centerY - targetDims.centerY)

		playerEl = document.getElementById('externalPlayer')
		containerTop = playerEl.getBoundingClientRect().top
		containerLeft = playerEl.getBoundingClientRect().left

		top = undefined
		height = undefined
		transform = ''

		# If on the same line, it's easy
		# Also, if they are close enough (like Hero Power on self), treat as though on same line, 
		# otherwise the deformation destroys the arrow wompletely
		if Math.abs(sourceDims.centerY - targetDims.centerY) < 10
			console.log 'Same line interaction'
			left = Math.min(sourceDims.centerX, targetDims.centerX) - containerLeft
			console.log 'initial left', left
			height = arrowWidth

			# All the height business is because we rotate around the center and not the top
			if sourceDims.centerX < targetDims.centerX
				transform += 'rotate(90deg) '
				#left += height / 2
				#console.log 'new lefts', left
			else
				transform += 'rotate(-90deg) '
			
			# Becuase the initial left is always the one most of the left, we always add to it
			left += height / 2

			top = sourceDims.centerY - containerTop - height / 2
			#console.log 'top', top, containerTop

		else 
			# If top player attacks, rotate the arrow to have it point down
			if sourceDims.centerY < targetDims.centerY
				transform += 'rotate(180deg) ' 

			# Now the angle - we want to keep it signed, which is why we don't use arrowWidth here
			tanAlpha = (sourceDims.centerX - targetDims.centerX) * 1.0 / arrowHeight
			alpha = Math.atan(tanAlpha) * 180 / Math.PI
			if sourceDims.centerY < targetDims.centerY
				alpha = -alpha

			console.log 'angle is', alpha
			transform += 'skewX(' + alpha + 'deg)'

			# And readjust the origin
			alpha = alpha * Math.PI / 180
			left = Math.min(sourceDims.centerX, targetDims.centerX) - containerLeft
			console.log 'readjusted left', left
			left = left + Math.tan(Math.abs(alpha)) * arrowHeight / 2
			console.log 'final left', left, alpha, arrowWidth, Math.cos(alpha), Math.cos(alpha) * arrowWidth / 2
			console.log 'final left', left, alpha, arrowHeight, Math.tan(alpha), Math.tan(alpha) * arrowHeight / 2
			console.log 'final top', Math.min(sourceDims.centerY, targetDims.centerY) - containerTop, containerTop

			top = Math.min(sourceDims.centerY, targetDims.centerY) - containerTop
			height = arrowHeight

		cls = "target " + @props.type

		style = {
			height: height
			top: top
			left: left
			transform: transform
		}
		console.log 'applying style', style
		return <div className={cls} style={style} />

module.exports = Target
