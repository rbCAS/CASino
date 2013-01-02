# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  if $('#login-form').length
    cookie_regex = /(^|;)\s*tgt=/
    checkCookieExists = ->
      if(cookie_regex.test(document.cookie))
        service = $('#service').val()
        url = '/login'
        url += ('?service=' + encodeURIComponent(service)) if service
        window.location = url
      else
        setTimeout(checkCookieExists, 1000)
    checkCookieExists()
