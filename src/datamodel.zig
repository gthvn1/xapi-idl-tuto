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

// Here is the list of all objects
pub const all_objects = [_]Object{
    host_object,
    vm_object,
};

// Host Object
pub const host_object = Object{
    .name = "Host",
    .methods = &[_]Method{ enable_host, disable_host },
};

const enable_host = Method{
    .name = "enable",
    .params = &[_]Param{.{ .name = "hostname", .ty = Type.string }},
    .result = Type.string,
};

const disable_host = Method{
    .name = "disable",
    .params = &[_]Param{.{ .name = "hostname", .ty = Type.string }},
    .result = Type.string,
};

// VM object
pub const vm_object = Object{ .name = "VM", .methods = &[_]Method{ create_vm, destroy_vm } };

const create_vm = Method{
    .name = "create",
    .params = &[_]Param{
        .{ .name = "name_label", .ty = Type.string },
        .{ .name = "memory", .ty = Type.int },
    },
    .result = Type.string,
};

const destroy_vm = Method{
    .name = "destroy",
    .params = &[_]Param{
        .{ .name = "name_label", .ty = Type.string },
    },
    .result = Type.string,
};
