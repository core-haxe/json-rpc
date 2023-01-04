package json.rpc;

import rest.IMappable;

@:structInit
class JsonRpcRequest implements IMappable {
    private static var nextId:Int = 0;

    public var id:Any = null;
    public var method:String;
    public var params:Dynamic;

    public function new(method:String, ?params:Dynamic, ?id:Any) {
        this.id = id;
        this.method = method;
        this.params = params;
    }

    private function toMap():Map<String, Any> {
        return null;
    }

    private function toObject():Dynamic {
        if (id == null) {
            nextId++;
            id = nextId;
        }
        return {
            jsonrpc: "2.0",
            method: method,
            params: params,
            id: id
        };
    }
}