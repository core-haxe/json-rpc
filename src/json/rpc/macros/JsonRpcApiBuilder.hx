package json.rpc.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

class JsonRpcApiBuilder {
    public static macro function build():Array<Field> {
        var clientExpr:Expr = null;  
        var clientMeta = Context.getLocalClass().get().meta.extract(":config");
        if (clientMeta != null && clientMeta.length == 1) {
            clientExpr = clientMeta[0].params[0];
        }

        var alternateClientExpr:Expr = null;  
        var alternateClientMeta = Context.getLocalClass().get().meta.extract(":alternateConfig");
        if (alternateClientMeta != null && alternateClientMeta.length == 1) {
            alternateClientExpr = alternateClientMeta[0].params[0];
        }

        var fields = Context.getBuildFields();
        var ctor = findOrAddConstructor(fields, clientExpr, alternateClientExpr);
        for (field in fields) {
            switch (field.kind) {
                case FFun(f):
                    if (f.expr == null) {
                        var verbMeta = extractVerbMeta(field);
                        var responseType = verbMeta.responseType;
                        var verb = switch (verbMeta.verb) {
                            case "get": http.HttpMethod.Get;
                            case "post": http.HttpMethod.Post;
                            case "put": http.HttpMethod.Put;
                            case "patch": http.HttpMethod.Patch;
                            case "delete": http.HttpMethod.Delete;
                            case _: null;
                        }

                        if (verb == null) {
                            continue;
                        }

                        var methodName = field.name;
                        var paramExprs = [];
                        for (arg in f.args) {
                            var argName = arg.name;
                            paramExprs.push(macro params.$argName = $i{argName});
                        }
                        f.ret = macro: promises.Promise<$responseType>;
                        f.expr = macro {
                            var restOperation = new RestOperation<json.rpc.JsonRpcRequest, $responseType, json.rpc.JsonRpcError>();
                            restOperation.verb = $v{verb};
                            restOperation.client = client;
                            restOperation.bodyType = rest.BodyType.Json;
                            var params:Dynamic = {};
                            $b{paramExprs}
                            return restOperation.call({
                                id: json.rpc.JsonRpcApi.nextId,
                                method: $v{methodName},
                                params: params
                            });
                            /* do we want to cache a promise based on the id, and then store it
                               in a map, and then look it up again based on the response id?
                               It seems more "correct", but these are syncronous requests, so
                               I dont really see how an unsolicited async response could be
                               incoming. ¯\_(ツ)_/¯
                            return new promises.Promise((resolve, reject) -> {
                            });
                            */
                        }
                    }
                case FVar(t, e):
                case _:
            }
        }

        return fields;
    }

    private static function findOrAddConstructor(fields:Array<Field>, clientExpr:Expr, alternateClientExpr:Expr):Field {
        var ctor:Field = null;
        for (field in fields) {
            if (field.name == "new") {
                ctor = field;
            }
        }

        if (ctor == null) {
            var args = [];
            var expr = null;
            if (clientExpr == null && alternateClientExpr == null) {
                args = [{
                    name: "client",
                    type: macro: rest.RestClient
                }];
                expr = macro {
                    super(client);
                }
            } else if (clientExpr != null && alternateClientExpr == null) {
                expr = macro {
                    var client = new rest.RestClient($clientExpr);
                    super(client);
                }
            } else if (clientExpr != null && alternateClientExpr != null) {
                expr = macro {
                    var client = new rest.RestClient($clientExpr, $alternateClientExpr);
                    super(client);
                }
            }

            ctor = {
                name: "new",
                access: [APublic],
                kind: FFun({
                    args: args,
                    expr: expr
                }),
                pos: Context.currentPos()
            }
            fields.push(ctor);
        }

        return ctor;
    }

    private static function extractVerbMeta(field:Field):{verb:String, responseType:ComplexType} {
        var verbMeta = {
            verb: null,
            responseType: null,
        }

        for (m in field.meta) {
            if (m.name == ":get" || m.name == ":post" || m.name == ":put" || m.name == ":patch" || m.name == ":delete") {
                verbMeta.verb = m.name.substring(1);
                if (m.params.length > 0) {
                    verbMeta.responseType = switch (m.params[0].expr) {
                        case EConst(CIdent(s)):
                            var parts = s.split(".");
                            s = parts.pop();

                            TPath({
                                pack: parts,
                                name: s
                            });
                        case _:    
                            null;
                    }
                }
            }
        }

        return verbMeta;
    }
}