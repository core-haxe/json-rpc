package cases;

import utest.Assert;
import rest.RestOperation;
import rest.BodyType;
import http.HttpMethod;
import json.rpc.JsonRpcResponse;
import json.rpc.JsonRpcRequest;
import json.rpc.JsonRpcError;
import http.ContentTypes;
import http.StandardHeaders;
import rest.RestClient;
import utest.Test;
import utest.Async;

@:timeout(2000)
class TestTypedOperation extends Test {
	private static inline var BASE_URL:String = "https://httpbin.org";

	function setupClass() {
		logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
			levels: [logging.LogLevel.Info, logging.LogLevel.Error]
		}));
	}

	function teardownClass() {
		logging.LogManager.instance.clearAdaptors();
	}

	function testTypedOperation(async:Async) {
		var client = new RestClient({
			baseAddress: "https://api.random.org/json-rpc/4/invoke",
			defaultRequestHeaders: [StandardHeaders.ContentType => ContentTypes.ApplicationJson]
		});

		var restOperation = new RestOperation<GenerateIntegersRequest, GenerateIntegersResponse, JsonRpcError>();
		restOperation.verb = HttpMethod.Post;
		restOperation.client = client;
		restOperation.bodyType = BodyType.Json;
		restOperation.call({
			apiKey: Sys.getEnv("RANDOM_DOT_ORG_API_KEY"),
			n: 6,
			min: 1,
			max: 6,
			replacement: true
		}).then(response -> {
            Assert.equals("2.0", response.jsonrpc);
            Assert.isTrue(response.bitsUsed > 0);
            Assert.isTrue(response.bitsLeft > 0);
            Assert.isTrue(response.requestsLeft > 0);
            Assert.isTrue(response.advisoryDelay > 0);
            Assert.equals(6, response.random.data.length);
            var total = 0;
            for (n in response.random.data) {
                total += n;
            }
            Assert.isTrue(total > 0);
			async.done();
		}, (error:JsonRpcError) -> {
			Assert.fail();
			async.done();
		});
	}

    function testTypedOperation_Error(async:Async) {
		var client = new RestClient({
			baseAddress: "https://api.random.org/json-rpc/4/invoke",
			defaultRequestHeaders: [StandardHeaders.ContentType => ContentTypes.ApplicationJson]
		});

		var restOperation = new RestOperation<GenerateIntegersRequest, GenerateIntegersResponse, JsonRpcError>();
		restOperation.verb = HttpMethod.Post;
		restOperation.client = client;
		restOperation.bodyType = BodyType.Json;
		restOperation.call({
			apiKey: "INVALID_KEY",
			n: 6,
			min: 1,
			max: 6,
			replacement: true
		}).then(response -> {
			Assert.fail();
			async.done();
		}, (error:JsonRpcError) -> {
            Assert.equals("2.0", error.jsonrpc);
            Assert.equals(200, error.code);
            Assert.equals("Parameter 'apiKey' is malformed", error.message);
            Assert.same(["apiKey"], error.data);
			async.done();
		});
    }
}

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
