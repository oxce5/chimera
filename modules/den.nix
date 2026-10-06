{
  inputs,
  den,
  lib,
  ...
}: {
  _module.args.__findFile = den.lib.__findFile;
  den.schema.user = {
    includes = [den._.mutual-provider];
    classes = lib.mkDefault ["homeManager"];
  };
  flake.den = den;
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "chimera" true)
  ];
}
