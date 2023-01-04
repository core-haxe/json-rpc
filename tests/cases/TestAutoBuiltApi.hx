package cases;

import json.rpc.JsonRpcError;
import cases.api.RandomApi;
import utest.Assert;
import utest.Async;
import utest.Test;

@:timeout(2000)
class TestAutoBuiltApi extends Test {
    function setupClass() {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
    }

    function teardownClass() {
        logging.LogManager.instance.clearAdaptors();
    }

    function testGenerateIntegers(async:Async) {
        var randomApi = new RandomApi();
        randomApi.generateIntegers(Sys.getEnv("RANDOM_DOT_ORG_API_KEY"), 6, 1, 6).then(response -> {
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

    function testGenerateIntegerSequences(async:Async) {
        var randomApi = new RandomApi();
        randomApi.generateIntegerSequences(Sys.getEnv("RANDOM_DOT_ORG_API_KEY"), 2, [5, 1], [1, 1], [69, 26], [false, false], [10, 10]).then(response -> {
            Assert.equals("2.0", response.jsonrpc);
            Assert.isTrue(response.bitsUsed > 0);
            Assert.isTrue(response.bitsLeft > 0);
            Assert.isTrue(response.requestsLeft > 0);
            Assert.isTrue(response.advisoryDelay > 0);
            Assert.equals(2, response.random.data.length);
            Assert.equals(5, response.random.data[0].length);
            Assert.equals(1, response.random.data[1].length);
			async.done();
        }, (error:JsonRpcError) -> {
			Assert.fail();
			async.done();
        });
    }
}
