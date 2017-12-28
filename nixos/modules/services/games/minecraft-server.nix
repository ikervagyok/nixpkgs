{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.minecraft-server;
in
{
  options = {
    services.minecraft-server = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, start a Minecraft Server. The listening port for
          the server by default is <literal>25565</literal>. The server
          data will be loaded from and saved to
          <literal>${cfg.dataDir}</literal>.
        '';
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/minecraft";
        description = ''
          Directory to store minecraft database and other state/data files.
        '';
      };

      configFile = mkOption {
        type = types.nullOr (types.either types.str types.path);
        default = null;
        description = ''
          Verbatim content of <literal>server.properties</literal> or a path.
          When set to <literal>null</literal>, use Minecraft's auto-generated
          config.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to open ports in the firewall (if enabled) for the server.
        '';
      };

      jvmOpts = mkOption {
        type = types.str;
        default = "-Xmx2048M -Xms2048M";
        description = "JVM options for the Minecraft Service.";
      };
    };
  };

  config = mkIf cfg.enable {
    users.extraUsers.minecraft = {
      description     = "Minecraft Server Service user";
      home            = cfg.dataDir;
      createHome      = true;
      uid             = config.ids.uids.minecraft;
    };

    systemd.services.minecraft-server = {
      description   = "Minecraft Server Service";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

# TODO: Handle case, where configFile is a file
# TODO: NixOS doesn't seem to support prepending dashes in prestart commands
      preStart = mkIf (cfg.configFile != null) ''
# Backup config if it exists
# -${pkgs.coreutils}/bin/mv ${cfg.dataDir}/server.properties{,.bak}
        cat > ${cfg.dataDir}/server.properties << EOF
        ${cfg.configFile}
        EOF
      '';

# TODO: NixOS doesn't seem to support prepending dashes in prestart commands
# postStop = mkIf (cfg.configFile != null) ''
# Restore original config if it exists
#   -${pkgs.coreutils}/bin/mv ${cfg.dataDir}/server.properties{.bak,}
# '';

      serviceConfig.Restart = "always";
      serviceConfig.User    = "minecraft";
      script = ''
        cd ${cfg.dataDir}
        exec ${pkgs.minecraft-server}/bin/minecraft-server ${cfg.jvmOpts}
      '';
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [ 25565 ];
      allowedTCPPorts = [ 25565 ];
    };
  };
}
