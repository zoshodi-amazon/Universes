# IOMNixCloud Monad — enables itself with default Conduit profile
{ lib, ... }:
{
  config.cloud = {
    enable = lib.mkDefault true;
    profiles = {
      default = {
        region = "us-east-1";
        output = "json";
      };
      "profile conduit" = {
        sso_account_id = "043309350576";
        sso_role_name = "IibsAdminAccess-DO-NOT-DELETE";
        region = "us-east-1";
        output = "json";
      };
    };
  };
}
