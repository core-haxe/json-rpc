# json-rpc

json rpc client

# features

- Promise based
- Ability to create fully typed json-rpc rest operations
- Ability to auto parse responses (via Json2Object)
- Ability to craft full json-rpc definitions with little effort

# basic usage (typed)

```haxe
@:structInit
class GenerateIntegersRequest extends JsonRpcRequest {
    public function new(apiKey:String, n:Int, min:Int, max:Int, replacement:Bool) {
        super("generateIntegers", {
            apiKey: apiKey,
            n: n,
            min: min,
            max: max,
            replacement: replacement
        });
    }
}

class GenerateIntegersResponse extends JsonRpcResponse {
    public var bitsUsed:Int;
    public var bitsLeft:Int;
    public var requestsLeft:Int;
    public var advisoryDelay:Int;
    public var random:{data:Array<Int>, completionTime:String};
}

var client = new RestClient({
    baseAddress: "https://api.random.org/json-rpc/4/invoke",
    defaultRequestHeaders: [StandardHeaders.ContentType => ContentTypes.ApplicationJson]
});

var restOperation = new RestOperation<GenerateIntegersRequest, GenerateIntegersResponse, JsonRpcError>();
restOperation.verb = HttpMethod.Post;
restOperation.client = client;
restOperation.bodyType = BodyType.Json;
restOperation.call({ apiKey: "MY_API_KEY", n: 6, min: 1, max: 6, replacement: true }).then(response -> {
    trace(response.random.data[0]); // response is of type "GenerateIntegersResponse"
}, (error:JsonRpcError) -> {
    // error
});
```

# auto built api (typed)

```haxe
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

randomApi.generateIntegers("MY_API_KEY", 6, 1, 6).then(response -> {
    trace(response.random.data[0]); // response is of type "GenerateIntegersResponse"
}, (error:JsonRpcError) -> {
    // error
});
```
