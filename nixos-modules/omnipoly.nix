{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.omnipoly;
in
{
  options.services.omnipoly = {
    enable = lib.mkEnableOption "omnipoly";

    package = lib.mkPackageOption pkgs "omnipoly" { };

    openFirewall = lib.mkEnableOption "" // {
      description = "Whether to open the firewall for the port in {option}`services.omnipoly.port`.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      description = "Port to bind webserver.";
      default = 80;
      example = 7011;
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = lib.literalExpression ''
        {
          LIBRETRANSLATE_LANGUAGES = [ "pl" "en" ]; todo
          LANGUAGE_TOOL_LANGUAGES = [ "pl-PL" "en-GB" ]; todo
        }
      '';
      description = ''
        https://github.com/kWeglinski/OmniPoly/blob/develop/.env.sample
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File to load environment variables from. Loaded variables override
        values set in {option}`environment`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.omnipoly = {
      description = "Frontend for LanguageTool and LibreTranslate";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = cfg.environment // {
        PORT = toString cfg.port;
      };

      script = ''
        exec ${pkgs.nodejs}/bin/node ${cfg.package}/index.js
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";

        EnvironmentFile = cfg.environmentFile;

        StateDirectory = "omnipoly";

        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        CapabilityBoundingSet = [ "" ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.port
    ];
  };
}
