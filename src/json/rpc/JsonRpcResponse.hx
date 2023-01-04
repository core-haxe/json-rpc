package json.rpc;

import haxe.Json;
import rest.IParsable;

@:autoBuild(json.rpc.macros.JsonRpcResponseParser.build())
class JsonRpcResponse implements IParsable {
    @:jignored public var jsonrpc:String;
    @:jignored public var id:Any;
    @:jignored public var result:Dynamic;

    private function parse(response:Any) {
        var json = Json.parse(response);
        if (json.error != null) {
            throw response;
        }

        this.jsonrpc = json.jsonrpc;
        this.id = json.id;
        this.result = json.result;
    }
}