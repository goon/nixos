{ username, config, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    users.${username} = {
      home = {
        inherit username;
        homeDirectory = config.globals.paths.home;
        stateVersion = "25.11";
      };
    };
  };
}
