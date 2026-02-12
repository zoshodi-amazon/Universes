# Sovereignty Options — mechanical projection of Sovereignty.lean ADT
# Single source of truth for the entire capability type space.
# Every field bounded with a default. No nulls. No loose strings.
# Physical quantities use submodules with value + unit.
{ lib, ... }:
let
  # -- Typed quantity submodules (value + unit, not strings) --
  massType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; };
    options.unit = lib.mkOption { type = lib.types.enum [ "g" "kg" ]; default = "g"; };
  };
  volType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; };
    options.unit = lib.mkOption { type = lib.types.enum [ "mL" "L" ]; default = "L"; };
  };
  durationType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; };
    options.unit = lib.mkOption { type = lib.types.enum [ "s" "min" "hr" ]; default = "min"; };
  };
  powerType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; };
    options.unit = lib.mkOption { type = lib.types.enum [ "mW" "W" "kW" ]; default = "W"; };
  };
  energyQtyType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; };
    options.unit = lib.mkOption { type = lib.types.enum [ "Wh" "kWh" ]; default = "Wh"; };
  };
  distType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; };
    options.unit = lib.mkOption { type = lib.types.enum [ "m" "km" ]; default = "m"; };
  };
  capType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; };
    options.unit = lib.mkOption { type = lib.types.enum [ "mL" "L" "gal" ]; default = "L"; };
  };
  costType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; };
    options.currency = lib.mkOption { type = lib.types.enum [ "USD" "EUR" "XMR" "BTC" "none" ]; default = "USD"; };
  };

  # -- Signature submodule --
  sigType = lib.types.submodule {
    options = {
      thermal    = lib.mkOption { type = lib.types.enum [ "unmanaged" "passive" "active" ]; default = "unmanaged"; };
      acoustic   = lib.mkOption { type = lib.types.enum [ "unmanaged" "dampened" "silent" ]; default = "unmanaged"; };
      visual     = lib.mkOption { type = lib.types.enum [ "visible" "camouflaged" "concealed" ]; default = "visible"; };
      electronic = lib.mkOption { type = lib.types.enum [ "tracked" "minimal" "dark" ]; default = "minimal"; };
      financial  = lib.mkOption { type = lib.types.enum [ "traceable" "pseudonymous" "anonymous" ]; default = "traceable"; };
    };
  };

  # -- Item submodule (BOM leaf node) --
  itemType = lib.types.submodule {
    options = {
      name       = lib.mkOption { type = lib.types.str; description = "Human-readable name"; };
      model      = lib.mkOption { type = lib.types.str; description = "Specific model/SKU"; };
      qty        = lib.mkOption { type = lib.types.int; default = 1; };
      unitCost   = lib.mkOption { type = costType; default = {}; };
      weight     = lib.mkOption { type = massType; default = {}; };
      volume     = lib.mkOption { type = volType; default = {}; };
      packTime   = lib.mkOption { type = durationType; default = {}; };
      source     = lib.mkOption { type = lib.types.enum [ "diy" "salvage" "trade" "url" "local" ]; default = "diy"; };
      status     = lib.mkOption { type = lib.types.enum [ "needed" "sourced" "ordered" "acquired" "tested" "deployed" ]; default = "needed"; };
      competency = lib.mkOption { type = lib.types.enum [ "untrained" "novice" "intermediate" "proficient" "expert" ]; default = "untrained"; };
      signature  = lib.mkOption { type = sigType; default = {}; };
    };
  };

  items = lib.mkOption { type = lib.types.listOf itemType; default = []; };
  sig = lib.mkOption { type = sigType; default = {}; };
in
{
  options.sovereignty = {
    # -- Global --
    mode = lib.mkOption {
      type = lib.types.enum [ "nomadic" "urban" "base" ];
      default = "base";
    };
    bootstrap.seed = lib.mkOption {
      type = lib.types.enum [ "knowledge" "energy" "compute" ];
      default = "knowledge";
    };
    opsec = {
      physical.enable  = lib.mkEnableOption "physical signature management";
      signal.enable    = lib.mkEnableOption "RF/EM signature management";
      digital.enable   = lib.mkEnableOption "digital trail management";
      social.enable    = lib.mkEnableOption "behavioral pattern management";
      financial.enable = lib.mkEnableOption "economic trail management";
      temporal.enable  = lib.mkEnableOption "timing pattern management";
      legal.enable     = lib.mkEnableOption "jurisdiction/documentation management";
    };
    constraints = {
      nomadic = {
        teardownTime = lib.mkOption { type = durationType; default = { value = 15.0; unit = "min"; }; };
        maxWeight    = lib.mkOption { type = massType; default = { value = 25.0; unit = "kg"; }; };
        maxVolume    = lib.mkOption { type = volType; default = { value = 65.0; unit = "L"; }; };
        mobility     = lib.mkOption { type = lib.types.enum [ "foot" "bicycle" "motorcycle" "vehicle" ]; default = "foot"; };
      };
      urban = {
        blendLevel        = lib.mkOption { type = lib.types.enum [ "tourist" "resident" "local" "native" ]; default = "resident"; };
        infrastructureUse = lib.mkOption { type = lib.types.enum [ "none" "minimal" "selective" "full" ]; default = "selective"; };
        burnerDevices     = lib.mkEnableOption "burner devices for cover";
        realDevices       = lib.mkEnableOption "real identity devices (separate)";
      };
      base = {
        permanence        = lib.mkOption { type = lib.types.enum [ "temporary" "seasonal" "semi-permanent" "permanent" ]; default = "semi-permanent"; };
        expansionCapacity = lib.mkOption { type = lib.types.int; default = 4; };
        redundancy        = lib.mkOption { type = lib.types.enum [ "none" "n+1" "2n" ]; default = "n+1"; };
        cacheLocations    = lib.mkOption { type = lib.types.int; default = 0; };
      };
    };

    # -- Energy (Tier 1) --
    energy = {
      generation = {
        types    = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "solar" "wind" "hydro" "thermal" "manual" "fuel" ]); default = [ "solar" ]; };
        capacity = lib.mkOption { type = powerType; default = { value = 100.0; unit = "W"; }; };
        inherit items;
      };
      storage = {
        capacity  = lib.mkOption { type = energyQtyType; default = { value = 1.0; unit = "kWh"; }; };
        chemistry = lib.mkOption { type = lib.types.enum [ "lifepo4" "li-ion" "lead-acid" "supercap" "mechanical" ]; default = "lifepo4"; };
        inherit items;
      };
      distribution = {
        voltage = lib.mkOption { type = lib.types.enum [ "5V" "12V" "24V" "48V" "120V" "240V" ]; default = "12V"; };
        inherit items;
      };
      signature = sig;
    };

    # -- Water (Tier 1) --
    water = {
      sources      = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "rain" "well" "surface" "atmospheric" "recycled" ]); default = [ "rain" ]; };
      purification = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "filter" "uv" "boil" "distill" "reverse-osmosis" "chemical" ]); default = [ "filter" "uv" ]; };
      capacity     = lib.mkOption { type = capType; default = { value = 100.0; unit = "L"; }; };
      signature    = sig;
      inherit items;
    };

    # -- Food (Tier 1) --
    food = {
      acquisition  = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "forage" "hunt" "fish" "cultivate" "trade" "store" ]); default = [ "store" "cultivate" ]; };
      preservation = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "dry" "smoke" "salt" "ferment" "freeze" "can" "vacuum" ]); default = [ "dry" "vacuum" ]; };
      cultivation = {
        method = lib.mkOption { type = lib.types.enum [ "soil" "hydroponic" "aquaponic" "aeroponic" ]; default = "soil"; };
        scale  = lib.mkOption { type = lib.types.enum [ "personal" "family" "community" ]; default = "personal"; };
        inherit items;
      };
      signature = sig;
      inherit items;
    };

    # -- Shelter (Tier 1) --
    shelter = {
      shelterType = lib.mkOption { type = lib.types.enum [ "tent" "vehicle" "structure" "underground" "natural" ]; default = "tent"; };
      mobility    = lib.mkOption { type = lib.types.enum [ "portable" "relocatable" "fixed" ]; default = "portable"; };
      climate = {
        heating = lib.mkOption { type = lib.types.enum [ "none" "passive" "active" ]; default = "passive"; };
        cooling = lib.mkOption { type = lib.types.enum [ "none" "passive" "active" ]; default = "passive"; };
      };
      signature = sig;
      inherit items;
    };

    # -- Medical (Tier 2) --
    medical = {
      level        = lib.mkOption { type = lib.types.enum [ "firstaid" "emt" "paramedic" "field-surgery" ]; default = "firstaid"; };
      pharmacy = {
        synthesis = lib.mkEnableOption "compound synthesis";
        botanical = lib.mkEnableOption "botanical medicine";
        inherit items;
      };
      diagnostics  = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "vitals" "blood" "imaging" "lab" ]); default = [ "vitals" ]; };
      telemedicine = lib.mkEnableOption "remote medical consultation";
      inherit items;
    };

    # -- Comms (Tier 2) --
    comms = {
      mesh = {
        enable   = lib.mkEnableOption "mesh networking";
        protocol = lib.mkOption { type = lib.types.enum [ "lora" "meshtastic" "reticulum" "yggdrasil" "cjdns" ]; default = "meshtastic"; };
        inherit items;
      };
      burst = {
        enable      = lib.mkEnableOption "burst transmission mode";
        maxDuration = lib.mkOption { type = durationType; default = { value = 500.0; unit = "s"; }; };
      };
      encryption = lib.mkOption { type = lib.types.enum [ "none" "aes256" "chacha20" "otp" ]; default = "chacha20"; };
      rf = {
        maxPower = lib.mkOption { type = powerType; default = { value = 100.0; unit = "mW"; }; };
        inherit items;
      };
      offline = {
        sms   = lib.mkEnableOption "offline SMS via mesh";
        voice = lib.mkEnableOption "offline voice via mesh";
        data  = lib.mkEnableOption "offline data sync";
      };
      signature = sig;
    };

    # -- Compute (Tier 2) --
    compute = {
      architecture = lib.mkOption { type = lib.types.enum [ "riscv64" "aarch64" "x86_64" ]; default = "aarch64"; };
      openness     = lib.mkOption { type = lib.types.enum [ "full" "partial" "pragmatic" ]; default = "partial"; };
      airgap       = lib.mkEnableOption "air-gapped operation";
      disposable   = lib.mkEnableOption "disposable/burner capability";
      knowledge = {
        static = {
          enable  = lib.mkEnableOption "static knowledge base (kiwix, offline wikis)";
          sources = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "wikipedia" "wikibooks" "stackexchange" "arxiv" "gutenberg" ]); default = [ "wikipedia" "wikibooks" "stackexchange" ]; };
          inherit items;
        };
        llm = {
          enable = lib.mkEnableOption "local LLM";
          model  = lib.mkOption { type = lib.types.enum [ "llama-7b" "llama-13b" "mistral-7b" "phi-2" "codellama" ]; default = "llama-7b"; };
          inherit items;
        };
        structured = {
          enable  = lib.mkEnableOption "structured queryable databases";
          domains = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "plants" "chemicals" "electronics" "medical" "geology" "astronomy" ]); default = [ "plants" "chemicals" "electronics" "medical" ]; };
          inherit items;
        };
      };
      inherit items;
    };

    # -- Intelligence (Tier 3) --
    intelligence = {
      osint = {
        enable  = lib.mkEnableOption "OSINT capabilities";
        domains = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "social" "geospatial" "domain" "image" "video" "document" "darkweb" ]); default = [ "social" "geospatial" "image" ]; };
        inherit items;
      };
      sigint = {
        enable   = lib.mkEnableOption "SIGINT capabilities";
        sdr      = lib.mkEnableOption "software-defined radio";
        spectrum = lib.mkEnableOption "spectrum analysis";
        protocol = lib.mkEnableOption "protocol analysis";
        inherit items;
      };
      countersurveillance = {
        enable = lib.mkEnableOption "counter-surveillance";
        rf     = lib.mkEnableOption "RF sweep/detection";
        camera = lib.mkEnableOption "camera detection";
        tscm   = lib.mkEnableOption "technical surveillance countermeasures";
        inherit items;
      };
      re = {
        software = lib.mkEnableOption "software reverse engineering";
        hardware = lib.mkEnableOption "hardware reverse engineering";
        firmware = lib.mkEnableOption "firmware extraction/analysis";
        protocol = lib.mkEnableOption "protocol reverse engineering";
        inherit items;
      };
    };

    # -- Defense (Tier 3) --
    defense = {
      perimeter = {
        enable  = lib.mkEnableOption "perimeter security";
        sensors = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "motion" "seismic" "acoustic" "thermal" "rf" ]); default = []; };
        inherit items;
      };
      earlyWarning = {
        enable = lib.mkEnableOption "early warning system";
        range  = lib.mkOption { type = distType; default = { value = 100.0; unit = "m"; }; };
        inherit items;
      };
      physical = {
        hardening   = lib.mkOption { type = lib.types.enum [ "none" "basic" "reinforced" "fortified" ]; default = "none"; };
        concealment = lib.mkOption { type = lib.types.enum [ "none" "camouflage" "decoy" "underground" ]; default = "none"; };
        inherit items;
      };
      commsec = lib.mkEnableOption "communications security";
    };

    # -- Transport (Tier 4) --
    transport = {
      modes      = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "foot" "bicycle" "motorcycle" "vehicle" "boat" "aircraft" ]); default = [ "foot" "bicycle" ]; };
      fuel       = lib.mkOption { type = lib.types.enum [ "human" "electric" "gasoline" "diesel" "multi" ]; default = "human"; };
      navigation = {
        gps         = lib.mkEnableOption "GPS navigation";
        gpsDenied   = lib.mkEnableOption "GPS-denied navigation (celestial, terrain, inertial)";
        mapsOffline = lib.mkEnableOption "offline maps";
        inherit items;
      };
      signature = sig;
      inherit items;
    };

    # -- Trade (Tier 4) --
    trade = {
      methods = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "barter" "crypto" "cash" "commodity" "service" ]); default = [ "barter" "crypto" ]; };
      crypto = {
        enable      = lib.mkEnableOption "cryptocurrency";
        coins       = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "btc" "xmr" "zec" ]); default = [ "xmr" ]; };
        coldStorage = lib.mkEnableOption "cold storage";
        inherit items;
      };
      supplyChain = {
        verification = lib.mkEnableOption "supply chain verification";
        redundancy   = lib.mkOption { type = lib.types.int; default = 2; };
      };
      signature = sig;
    };

    # -- Fabrication (Tier 4) --
    fabrication = {
      tier = lib.mkOption { type = lib.types.enum [ "assembly" "component" "material" ]; default = "assembly"; };
      capabilities = {
        printing3d = lib.mkEnableOption "3D printing";
        cnc        = lib.mkEnableOption "CNC machining";
        pcb        = lib.mkEnableOption "PCB fabrication";
        welding    = lib.mkEnableOption "welding/metalwork";
        woodwork   = lib.mkEnableOption "woodworking";
        textiles   = lib.mkEnableOption "textile/sewing";
        chemistry  = lib.mkEnableOption "chemical synthesis";
        casting    = lib.mkEnableOption "metal casting";
      };
      materials = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "plastic" "metal" "wood" "ceramic" "composite" "electronic" ]); default = [ "plastic" ]; };
      inherit items;
    };
  };
}
