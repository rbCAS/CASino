(function(win, doc) {
  var url = '/login',
      cookie_regex = /(^|;)\s*tgt=/;

  function checkCookieExists() {
    var serviceEl = doc.getElementById('service'),
        svcValue = serviceEl ? serviceEl.getAttribute('value') : null;

    if(svcValue) {
      if(cookie_regex.test(doc.cookie)) {
        win.location = url + '?service=' + encodeURIComponent(svcValue);
      }
    } else {
      setTimeout(checkCookieExists, 1000);
    }
  }

  // Auto-login when logged-in in other browser window (9887c4e)
  if(doc.getElementById('login-form')) {
    checkCookieExists();
  }

})(this, document);
