package wsocket
{
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	
	import flash.external.ExternalInterface;
	import flash.system.Security;

	public class GenericWebSocket
	{
		private var myURL:String;
		private var myId:String;
		private var websocket:WebSocket;

		private static var initialized:Boolean = false;
		private static var dispatchers:Object = new Object(); 
		private var subprotocol:String = "turntable";
		
		public static function getUniqueId():String {
			var uniqId:String = ""+(new Date().time)+"_"+(Math.random());
			return uniqId;
		}
		
		public static function addDispatcher(uniqId:String, callback:Function):void {
			dispatchers[uniqId] = callback;
		}
		
		public static function getDispatcher(uniqId:String):Function {
			return dispatchers[uniqId];
		}
		
		public function GenericWebSocket(serverURL:String, onMessageFunction:Function, onOpenFunction:Function=null, onCloseFunction:Function=null, onErrorFunction:Function=null)
		{
			myURL = serverURL;
			myId = getUniqueId();
			addDispatcher(myId+"_Open",onOpenFunction);
			addDispatcher(myId+"_Close",onCloseFunction);
			addDispatcher(myId+"_Message",onMessageFunction);
			addDispatcher(myId+"_Error",onErrorFunction);
			createWebSocket();
		}
		
		private function createWebSocket():void {
			var useWebWebSocket:Boolean = false;
			if(!useWebWebSocket)
			{
				createNativeWebSocket();
			} else {
				createBrowserWebSocket();
			}
		}
		
		public function createBrowserWebSocket():void {
			if(ExternalInterface.available) {
				try {
					if(!initialized) {						
						Security.allowDomain(Security.pageDomain);
						ExternalInterface.addCallback("handleOpen", handleIdOpen);
						ExternalInterface.addCallback("handleClose", handleIdClose);
						ExternalInterface.addCallback("handleMessage", handleIdMessage);
						ExternalInterface.addCallback("handleError", handleIdError);
						initialized = true;
					}
					ExternalInterface.call("openWebSocket", myURL, myId);
				} catch (e: Error) {
					log(e.getStackTrace());
				}
			}
		}
		
		public static function handleIdOpen(uniqId:String): void{
			var openfunction:Function = getDispatcher(uniqId+"_Open");
			if(openfunction != null)
				openfunction();
		}
		
		private static function handleIdClose(uniqId:String):void {
			var closefunction:Function = getDispatcher(uniqId+"_Close");
			if(closefunction != null)
				closefunction();
		}

		private static function handleIdMessage(uniqId:String, message_command:String, message_data:Object):void {
			var messagefunction:Function = getDispatcher(uniqId+"_Message");			
			if(messagefunction != null)
				messagefunction(message_command, message_data);
		}

		private static function handleIdError(uniqId:String, err:Object):void {
			log('WebSocket['+uniqId+']'+" Error: " + err.toString());
			var errorfunction:Function = getDispatcher(uniqId+"_Error");
			if(errorfunction != null)
				errorfunction(err.toString());
		}
		
		
		public function createNativeWebSocket():void {
			websocket = new WebSocket(myURL,"*",subprotocol,5000);
			websocket.debug = true;
			websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClose);
			websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionError);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			log('WebSocket['+myId+']'+' = '+myURL);
			websocket.connect();			
		}
		
		private static function log(... arguments):void{
			trace(arguments);
		}
		
		private function handleWebSocketOpen(event:WebSocketEvent):void {
			log('WebSocket['+myId+']'+" Open.");
			var openfunction:Function = getDispatcher(myId+"_Open");
			if(openfunction != null)
				openfunction();
		}

		private function handleWebSocketClose(event:WebSocketEvent):void {
			log('WebSocket['+myId+']'+" Closed.");
			var closefunction:Function = getDispatcher(myId+"_Close");
			if(closefunction != null)
				closefunction();
		}
		
		private function handleConnectionError(event:WebSocketErrorEvent):void {
			log('WebSocket['+myId+']'+" Error: " + event.text);
			var errorfunction:Function = getDispatcher(myId+"_Error");
			if(errorfunction != null)
				errorfunction(event.text);
		}
		
		private function handleWebSocketMessage(event:WebSocketEvent):void {
			if (event.message.type === WebSocketMessage.TYPE_UTF8) {
				//log("Text Message Recieved: "+event.message.utf8Data);
				var message_response:Object =JSON.parse(event.message.utf8Data);
				var message_command:String=message_response["command"];
				var message_data:Object=message_response["data"];
				var messagefunction:Function = getDispatcher(myId+"_Message");
				if(messagefunction != null)
					messagefunction(message_command, message_data);
			}
		}
		
		public function sendCommand(command:String, data:Object):void {
			try {
				if(websocket != null) {
					var message:String = JSON.stringify({"command":command, "data":data});
					websocket.sendUTF(message);				
				} else {
					ExternalInterface.call("sendWebSocketMessage", myId, command, data);	
				}
			} catch (e: Error) {
					log(e.getStackTrace());
			}
		}
		
		public function close():void {
			try {
				if(websocket != null)
					websocket.close();
				else {
					ExternalInterface.call("closeWebSocket", myId);
				}
			} catch (e: Error) {
				log(e.getStackTrace());
			}
		}
	}
}
