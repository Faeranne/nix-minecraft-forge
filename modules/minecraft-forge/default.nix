flake: { config, lib, pkgs, ... }:
let
  libraries = pkgs.requireFile {
    name = "libraries-1.18.2-40.2.17";
    sha256 = "sha256-5hxGdkTqcvKC95v/YNl/z/me9GloJedCVo8+az0K1Jg=";
    url = "build.sh";
    hashMode = "recursive";
  };
  run = pkgs.writeScript {
    name = "run.sh";
    text = ''
      ln -s ${libraries} ./libraries/ 
      java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-40.2.17/unix_args.txt "$@"
    '';
  };
  cfg = config.services.minecraft-forge;
  jvmArgs = pkgs.writeText "user_jvm_args.txt"
    ''
      -Xmx4G
      -Xms4G
    '';
in
{
  options = {
    services.minecraft-forge = {
      enable = lib.mkEnableOption ''
        Minecraft Forge: A modded Minecraft platform
      '';

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/minecraft";
        description = lib.mdDock ''
          The path for all the server files.
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.minecraft = {
      description = "Minecraft Forge Daemon user";
      isSystemUser = true;
      group = "minecraft";
    };
    users.groups.minecraft = {};
    systemd.services.minecraft-forge = {
      description = "Minecraft Forge Server";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "minecraft";
        Group = "minecraft";
        Restart = "always";
        ExecStart = "${run}";
        StateDirectory = "minecraft";
        StateDirectoryMode = "0750";
      };
    };
  };
}
