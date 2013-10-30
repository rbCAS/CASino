(function(win, doc) {
  var url = '/login',
      cookie_regex = /(^|;)\s*tgt=/,
      ready_bound = false;

  function checkCookieExists() {
    var serviceEl = doc.getElementById('service'),
        service = serviceEl ? serviceEl.getAttribute('value') : null;

    if(cookie_regex.test(doc.cookie)) {
      url = '/login';
      if(service) {
        url += '?service=' + encodeURIComponent(service);
      }
      win.location = url;
    } else {
      setTimeout(checkCookieExists, 1000);
    }
  }

  // Auto-login when logged-in in other browser window (9887c4e)
  doc.addEventListener('DOMContentLoaded', function() {
    if(ready_bound) {
      return;
    }
    ready_bound = true;
    if(doc.getElementById('login-form')) {
      checkCookieExists();
    }
  });

})(this, document);
