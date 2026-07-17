{ chimera, den, ... }:
{
  chimera.batteries._.privileged-user =
    { user, ... }:
    {
      nixos =
        { lib, config, ... }:
        {
          config.users.users.${user.userName}.extraGroups = config.users.privilegedGroups;
          options.users.privilegedGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
    };
}
