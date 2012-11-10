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

	$('#search-button').click(() ->
		$('#search-form').slideDown('fast', () ->
			$('#search-field').focus();
		)
	)
	
	$('#search-field').blur(() ->
		if($(this).val() == "")
			$('#search-form').slideUp('fast', () ->
				
			)
	)
	$('.contact-form').submit(() ->
		
		$.ajax({
			type: "POST",
			url: "/about/message",
			data: $('.contact-form').serialize(),
			dataType: "json",
			beforeSend: () ->
				#alert('before')
			,
			error: (jqXHR, textStatus, errorThrown) ->
				$('.contact-form').fadeOut(() ->
					$('#contact-form-area').html("<div id='contact-message'><p>Ocorreu um problema ao enviar a mensagem, por favor tente novamente mais tarde ou envie um email diretamente para guilherme.defreitas@gmail.com.</p><p>Obrigado!</p></div>")
					$('#contact-message').fadeIn()	
				)
				
			,
			success: (data) ->
				$('.contact-form').fadeOut(() ->
					$('#contact-form-area').html("<div id='contact-message'><p>Mensagem enviada com sucesso. Obrigado!</p></div>")
					$('#contact-message').fadeIn()
				)
		})
		event.preventDefault()
	)

)