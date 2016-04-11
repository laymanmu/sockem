
var App = {

  init: function() {
    App.initWebSocket();
    App.initUI();
  },

  initWebSocket: function() {
    App.ws = new WebSocket("ws://localhost:8080");

    App.ws.onopen = function(evt) {
      App.appendLog("opened connection");
    };

    App.ws.onmessage = function(evt) {
      App.react(evt.data);
    };

    App.ws.onclose = function(evt) {
      App.appendLog("closed connection");
    };

    App.ws.onerror = function(err) {
      App.appendLog("websocket error: "+ err.name + " => " + err.message);
    };
  },

  initUI: function() {
    App.ui = {};
    App.ui.log         = document.getElementById('log');
    App.ui.messages    = document.getElementById('messages');
    App.ui.sendButton  = document.getElementById('sendButton');
    App.ui.messageText = document.getElementById('messageText');

    App.ui.sendButton.onclick = function() {
      var message = App.ui.messageText.value;
      App.ui.messageText.value = "";
      App.ws.send(message);
    };
  },

  appendMessage: function(msg) {
    App.ui.messages.innerHTML += "<p>"+ msg +"</p>\n";
  },

  appendLog: function(msg) {
    App.ui.log.innerHTML += "<p>"+msg+"</p>\n";
  },

  react: function(message) {
    var json = eval(message);
    switch (json.type) {
      case "msg": App.appendMessage(json.msg); break;
      case "log": App.appendLog(json.msg); break;
      default:    App.appendLog("unhandled message! type: "+ json.type +" msg: "+ json.msg);
    }
  }

};

















