package json.rpc.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

class JsonRpcResponseParser {
    public static macro function build():Array<Field> {
        var fields = Context.getBuildFields();

        var parseFn = findOrAddParse(fields);

        var localClass = Context.getLocalClass();
        var parts = localClass.toString().split(".");
        var s = parts.pop();

        var type = TPath({
            pack: parts,
            name: s
        });

        switch (parseFn.kind) {
            case FFun(f): {
                switch (f.expr.expr) {
                    case EBlock(exprs):
                        exprs.push(macro var resultString = haxe.Json.stringify(this.result));
                        exprs.push(macro var parser = new json2object.JsonParser<$type>());
                        exprs.push(macro var data = parser.fromJson(resultString));

                        for (field in fields) {
                            switch (field.kind) {
                                case FVar(t, e):
                                    var fieldName = field.name;
                                    exprs.push(macro this.$fieldName = data.$fieldName);
                                case _:
                            }
                        }
                    case _:    
                }
            }
            case _:
        }

        return fields;
    }

    private static function findOrAddParse(fields:Array<Field>):Field {
        var fn:Field = null;
        for (field in fields) {
            if (field.name == "parse") {
                fn = field;
            }
        }

        if (fn == null) {
            fn = {
                name: "parse",
                access: [APrivate, AOverride],
                kind: FFun({
                    args:[{
                        name: "response",
                        type: macro: Any
                    }],
                    expr: macro {
                        super.parse(response);
                    }
                }),
                pos: Context.currentPos()
            }
            fields.push(fn);
        }

        return fn;
    }
}