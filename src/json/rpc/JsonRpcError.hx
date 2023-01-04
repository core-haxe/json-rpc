package json.rpc;

import rest.IParsableError;
import rest.RestError;

class JsonRpcError implements IParsableError {
    public var jsonrpc:String;
    public var id:Any;
    public var code:Int;
    public var message:String;
    public var data:Dynamic;
    public var httpStatus:Null<Int> = null;

    private function parse(error:RestError) {
        this.httpStatus = error.httpStatus;
        if (this.httpStatus == null || (this.httpStatus >= 200 && this.httpStatus <= 299)) {
            var json = error.bodyAsJson;
            if (json == null || json.error == null) {
                return;
            }
            this.jsonrpc = json.jsonrpc;
            this.id = json.id;
            this.code = json.error.code;
            this.message = json.error.message;
            this.data = json.error.data;
        } else {
            this.message =  error.bodyAsString;
        }
    }
}