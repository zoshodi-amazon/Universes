{ lib, ... }:
{
  options.lab.metrics = {
    collect = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "size" "duration" "created" ];
      description = "Metrics to collect from artifacts";
    };
    aggregate = lib.mkOption {
      type = lib.types.enum [ "sum" "avg" "min" "max" "count" ];
      default = "count";
      description = "Aggregation function";
    };
    baseline = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Artifact ID to compare against";
    };
  };
}
