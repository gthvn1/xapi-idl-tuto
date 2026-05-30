{ pkgs ? import <nixpkgs> {} }:

let
  unstable = import <nixos-unstable> {};
in

pkgs.mkShell {
  buildInputs = [
    unstable.zig
    unstable.zls
  ];

  shellHook = ''
    echo "Using Zig $(zig version)"
  '';
}
