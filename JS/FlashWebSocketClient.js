var Default_SWF_Name = "flashcontent";
var webSockets = {};

function getSWF(movieName) 
{  
   var movie = document.getElementById(movieName);
   return movie;
} 

function openWebSocket(serverURL, uniqId) {
   if(!uniqId)
        uniqId = serverURL;
   client = new WebSocketClient();
   var openFunc = function() {
   	 if(console) console.log("WebSocket["+uniqId+"]"+" Open.");
         handleOpen(uniqId);
   };
   var closeFunc = function() {
   	 if(console) console.log("WebSocket["+uniqId+"]"+" Closed.");
         handleClose(uniqId);
   };
   var messageFunc = function(command, data) {
         handleMessage(uniqId, command, data);
   };
   client.registerCallback("Open", openFunc);
   client.registerCallback("Close", closeFunc);
   client.registerDefaultCallback(messageFunc);
   console.log("WebSocket["+uniqId+"]"+" = "+serverURL);
   client.connect(serverURL);
   webSockets[uniqId] = client;
}

function sendWebSocketMessage(uniqId, command, data) {
  try {
     webSockets[uniqId].handleWebSocketSend({"command": command, "data":data});
  } catch (e) {
     handleError(uniqId, e);
  }
}

function closeWebSocket(uniqId) {
  try {
    webSockets[uniqId].close(); 
    delete webSockets[uniqId];
  } catch (e) {
     handleError(uniqId, e);
  }
}

function handleError(uniqId, err) {
	if(console)
		console.log("Occured Error: %o", err);
	try {
		var movie = getSWF(Default_SWF_Name);
		movie.handleError(uniqId, err);
	} catch (e) {
		if(console)
			console.log("Cascaded Occured Error: %o", e);
	}
}

function handleOpen(uniqId) {
	try {
		var movie = getSWF(Default_SWF_Name);
		movie.handleOpen(uniqId);
	} catch (e) {
		handleError(uniqId, e);
	}
}

function handleMessage(uniqId, command, data) {
	try {
		var movie = getSWF(Default_SWF_Name);
		movie.handleMessage(uniqId, command, data);
	} catch (e) {
		handleError(uniqId, e);
	}
}

function handleClose(uniqId) {
	try {
		var movie = getSWF(Default_SWF_Name);
		movie.handleClose(uniqId);
	} catch (e) {
		handleError(uniqId, e);
	}
}
