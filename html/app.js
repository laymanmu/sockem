
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
    App.ui.room        = document.getElementById('room');
    App.ui.messages    = document.getElementById('messages');
    App.ui.sendButton  = document.getElementById('sendButton');
    App.ui.messageText = document.getElementById('messageText');
    App.ui.log         = document.getElementById('log');

    App.ui.sendButton.onclick = function() {
      var message = App.ui.messageText.value;
      App.ui.messageText.value = "";
      App.ws.send(message);
    };
  },

  appendMessage: function(msg) {
    App.ui.messages.innerHTML += "<p>"+ msg +"</p>\n";
  },

  appendHTML: function(html) {
    App.ui.messages.innerHTML += html;
  },

  appendLog: function(msg) {
    App.ui.log.innerHTML += "<p>"+msg+"</p>\n";
  },

  react: function(message) {
    console.log("IN: "+ message);
    var json = JSON.parse(message);
    switch (json.type) {
      case "msg":
        App.appendMessage(json.msg);
        break;
      case "log":
        App.appendLog(json.msg);
        break;
      case "room":
        App.ui.room.innerHTML = App.generateRoomHTML(json.msg);
        break;
      default:
        App.appendLog("unhandled message! type: "+ json.type +" msg: "+ json.msg);
    }
  },

  generateRoomHTML: function(data) {
    var name   = "<span class='roomName'>"+ data.name +"</span><br>";
    var desc   = "<span class='roomDesc'>"+ data.desc +"</span><br>";
    var actors = [];
    var exits  = [];
    for (var i=0; i<data.actors.length; i++) {
      actors.push("<span class='roomActor'>"+ data.actors[i] +"</span>");
    }
    for (var i=0; i<data.exits.length; i++) {
      exits.push("<span class='roomExit'>"+ data.exits[i] +"</span>");
    }
    actors = actors.join(", ") + "<br>";
    exits  = exits.join(", ")  + "<br>";
    return name + desc + actors + exits;
  }

};
