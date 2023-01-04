package cases.api;

import rest.RestOperation;
import rest.RestClient;
import json.rpc.JsonRpcRequest;
import json.rpc.JsonRpcResponse;
import json.rpc.JsonRpcError;
import json.rpc.JsonRpcApi;

@:config({
    baseAddress: "https://api.random.org/json-rpc/4/invoke"
})
class RandomApi extends JsonRpcApi {
    @:get(GenerateIntegersResponse)             public function generateIntegers(apiKey:String, n:Int, min:Int, max:Int, replacement:Bool = true, base:Int = 10);
    @:post(GenerateIntegerSequencesResponse)    public function generateIntegerSequences(apiKey:String, n:Int, length:Array<Int>, min:Array<Int>, max:Array<Int>, replacement:Array<Bool> = null, base:Array<Int> = null);
}

class GenerateIntegersResponse extends JsonRpcResponse {
    public var bitsUsed:Int;
    public var bitsLeft:Int;
    public var requestsLeft:Int;
    public var advisoryDelay:Int;
    public var random:{ data:Array<Int>, completionTime:String };
}

class GenerateIntegerSequencesResponse extends JsonRpcResponse {
    public var bitsUsed:Int;
    public var bitsLeft:Int;
    public var requestsLeft:Int;
    public var advisoryDelay:Int;
    public var random:{ data:Array<Array<Int>>, completionTime:String };
}
