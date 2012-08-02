class CanvasImage
	constructor: (element, image) ->
		this.image = image
		this.element = element
		this.element.width = this.image.width
		this.element.height = this.image.height
		this.context = this.element.getContext("2d")
		this.context.drawImage(this.image, 0, 0)

	blur: (passes) ->
		
		this.context.globalAlpha = 0.5
		for i in [0..(passes)]
			for y in [-1..2]
				for x in [-1..2]
					this.context.drawImage(this.element, x, y)
		this.context.globalAlpha = 1.0

				


$(document).ready(() ->
	id = 'bgcanvas'
	url = '/img/bg2.jpg'
	image = new Image()


	image.onload = ->
		canvasImage = new CanvasImage(document.getElementById(id), this)
		canvasImage.blur(4)	

	image.src = url

)