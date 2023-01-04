package json.rpc;

import rest.RestClient;

@:autoBuild(json.rpc.macros.JsonRpcApiBuilder.build())
class JsonRpcApi {
    private var client:RestClient;
    private var parentApi:JsonRpcApi = null;

    public function new(client:RestClient = null, parentApi:JsonRpcApi = null) {
        this.client = client;
        this.parentApi = parentApi;
        if (this.client == null) {
            this.client = new RestClient();
        }
    }

    private var _useAlternateConfig:Bool = false;
    private var useAlternateConfig(get, set):Bool;
    private function get_useAlternateConfig():Bool {
        if (parentApi == null) {
            return _useAlternateConfig;
        }
        return parentApi.useAlternateConfig;
    }
    private function set_useAlternateConfig(value:Bool) {
        if (parentApi == null) {
            _useAlternateConfig = value;
            return value;
        }

        parentApi.useAlternateConfig = value;
        return value;
    }

    private static var _nextId:Int = 0;
    private static var nextId(get, null):Int;
    private static function get_nextId():Int {
        _nextId++;
        return _nextId;
    }
}