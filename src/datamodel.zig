pub const Type = enum {
    string,
    int,
};

pub const Param = struct {
    name: []const u8,
    ty: Type,
};

pub const Method = struct {
    name: []const u8,
    params: []const Param,
    result: Type,
};

pub const Object = struct { name: []const u8, methods: []const Method };

pub const all_objects = [_]Object{host_object};

// Host Object
pub const host_object = Object{
    .name = "Host",
    .methods = &[_]Method{hello_method},
};

// With one method called hello that takes a string and a int as parameter
const hello_method = Method{
    .name = "hello",
    .params = &[_]Param{
        .{ .name = "hostname", .ty = Type.string },
        .{ .name = "version", .ty = Type.int },
    },
    .result = Type.string,
};
