Template.home.rendered = () ->
	w = new WOW().init()
	window.sr = ScrollReveal({ reset: true })
	sr.reveal('#ipad .container')
	sr.reveal('#how-it-works .container')
	sr.reveal('.navbar')

	# TODO: End after home destroyed

	# make sure div stays full width/height on resize
	# global vars
	winWidth = $(window).width()
	winHeight = $(window).height()

	# set initial div height / width
	$("#intro").css
	  width: winWidth
	  height: winHeight

	$(window).resize ->
	  $("#intro").css
	    width: $(window).width()
	    height: $(window).height()

	#Skroll doesn't work so well on mobile imo
	unless Utils.isMobile
		options =
			forceHeight: false
			smoothScrolling: false

		skrollr.init(options).refresh()

	# Main.js
	jQuery(document).ready ($) ->
	  animating = false
	  #update arrows visibility and detect which section is visible in the viewport
	  #go to next section

	  nextSection = ->
	    if !animating
	      if $('.is-visible[data-type="slider-item"]').next().length > 0
	        smoothScroll $('.is-visible[data-type="slider-item"]').next()
	    return

	  #go to previous section

	  prevSection = ->
	    if !animating
	      lastSection = $('.is-visible[data-type="slider-item"]')
	      if lastSection.length > 0 and $(window).scrollTop() != lastSection.offset().top
	        smoothScroll lastSection
	      else if lastSection.prev().length > 0 and $(window).scrollTop() == lastSection.offset().top
	        smoothScroll lastSection.prev('[data-type="slider-item"]')
	    return

	  setSlider = ->
	    checkNavigation()
	    checkVisibleSection()
	    return

	  #update the visibility of the navigation arrows

	  checkNavigation = ->
	    if $(window).scrollTop() < $(window).height() / 2 then $('.cd-vertical-nav .cd-prev').addClass('inactive') else $('.cd-vertical-nav .cd-prev').removeClass('inactive')
	    if $(window).scrollTop() > $(document).height() - (3 * $(window).height() / 2) then $('.cd-vertical-nav .cd-next').addClass('inactive') else $('.cd-vertical-nav .cd-next').removeClass('inactive')
	    return

	  #detect which section is visible in the viewport

	  checkVisibleSection = ->
	    scrollTop = $(window).scrollTop()
	    windowHeight = $(window).height()
	    $('[data-type="slider-item"]').each ->
	      actualBlock = $(this)
	      offset = scrollTop - (actualBlock.offset().top)
	      #add/remove .is-visible class if the section is in the viewport - it is used to navigate through the sections
	      if offset >= 0 and offset < windowHeight then actualBlock.addClass('is-visible') else actualBlock.removeClass('is-visible')
	      return
	    return

	  smoothScroll = (target) ->
	    animating = true
	    $('body,html').animate { 'scrollTop': target.offset().top }, 500, ->
	      animating = false
	      return
	    return

	  setSlider()
	  $(window).on 'scroll resize', ->
	    if !window.requestAnimationFrame then setSlider() else window.requestAnimationFrame(setSlider)
	    return
	  #move to next/previous section clicking on arrows
	  $('.cd-vertical-nav .cd-prev').on 'click', ->
	    prevSection()
	    return
	  $('.cd-vertical-nav .cd-next').on 'click', ->
	    nextSection()
	    return
	  $('.arrow.bounce').on 'click', ->
	    nextSection()
	    return
	  $('.back-top').on 'click', (event) ->
	    event.preventDefault()
	    $('body,html').animate { scrollTop: 0 }, 700
	    return
	  #move to next/previous using the keyboards
	  $(document).keydown (event) ->
	    if event.which is '38'
	      prevSection()
	      event.preventDefault()
	    else if event.which is '40'
	      nextSection()
	      event.preventDefault()
	    return
	  return

		###
# uilang v1.0.1
# http://uilang.com
###

document.addEventListener 'DOMContentLoaded', ->

  InstructionParsing = (instruction) ->
    separator = instruction.charAt(0)
    instructionSplit = instruction.split(separator)
    @clickSelector = instructionSplit[1]
    @classBehavior = instructionSplit[2].trim().split(' ')[0]
    @classValue = instructionSplit[3]
    @targetSelector = instructionSplit[5]
    return

  UIElement = (clickSelector, classBehavior, classValue, targetSelector) ->
    @clickSelector = clickSelector
    @classBehavior = if classBehavior.charAt(classBehavior.length - 1) == 's' then classBehavior.substring(0, classBehavior.length - 1) else classBehavior
    @classValue = if classValue.charAt(0) == '.' then classValue.substring(1, classValue.length) else classValue
    @targetSelector = targetSelector
    @createEventListener()
    return

  'use strict'
  codeElements = document.getElementsByTagName('code')
  i = codeElements.length
  delimiter = 'clicking on'
  codeBlock = undefined
  codeBlockContent = undefined
  while i--
    code = codeElements[i]
    content = code.textContent.trim()
    if content.lastIndexOf(delimiter, 0) == 0
      codeBlock = code
      codeBlockContent = content
      break
  if !codeBlock
    return
  codeBlock.parentNode.removeChild codeBlock

  UIElement::createEventListener = ->
    self = this
    clicked = document.querySelectorAll(self.clickSelector)
    n = clicked.length

    updateClass = (el) ->
      el.classList[self.classBehavior] self.classValue
      return

    clickCallback = (e) ->
      switch self.targetSelector
        when 'target', 'this', 'it', 'itself', undefined
          updateClass e.target
        else
          target = document.querySelectorAll(self.targetSelector)
          x = target.length
          while x--
            updateClass target.item(i)
      if e.target.nodeName.toLowerCase() == 'a'
        e.preventDefault()
      return

  if n < 1
      throw new Error('There\'s no element matching your "' + self.clickSelector + '" CSS selector.')
    while n--
      clicked.item(i).addEventListener 'click', clickCallback
    return

  codeBlockContent.split(delimiter).forEach (data) ->
    if !data
      return
    params = new InstructionParsing(data.trim())
    new UIElement(params.clickSelector, params.classBehavior, params.classValue, params.targetSelector)
    return
  return

Template.home.destroyed = () ->
	#For Skrollr
	$('body').attr('style','')
