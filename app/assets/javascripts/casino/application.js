// Place all the behaviors and hooks related to the matching controller here.
(function(win) {
  if(!win.CASino) {
    win.CASino = { baseUrl: '/' };
  }

  win.CASino.url = function(path) {
    return win.CASino.baseUrl + path;
  }
})(this);
