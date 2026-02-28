# Sovereignty Options — mechanical projection of Sovereignty.lean ADT
# Single source of truth for the entire capability type space.
# Every field bounded with a default. No nulls. No loose strings.
# Physical quantities use submodules with value + unit.
{ lib, ... }:
let
  # -- Typed quantity submodules (value + unit, not strings) --
  massType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; description = "Value"; };
    options.unit = lib.mkOption { type = lib.types.enum [ "g" "kg" ]; default = "g"; description = "Unit"; };
  };
  volType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; description = "Value"; };
    options.unit = lib.mkOption { type = lib.types.enum [ "mL" "L" ]; default = "L"; description = "Unit"; };
  };
  durationType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; description = "Value"; };
    options.unit = lib.mkOption { type = lib.types.enum [ "s" "min" "hr" ]; default = "min"; description = "Unit"; };
  };
  powerType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; description = "Value"; };
    options.unit = lib.mkOption { type = lib.types.enum [ "mW" "W" "kW" ]; default = "W"; description = "Unit"; };
  };
  energyQtyType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; description = "Value"; };
    options.unit = lib.mkOption { type = lib.types.enum [ "Wh" "kWh" ]; default = "Wh"; description = "Unit"; };
  };
  distType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; description = "Value"; };
    options.unit = lib.mkOption { type = lib.types.enum [ "m" "km" ]; default = "m"; description = "Unit"; };
  };
  capType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; description = "Value"; };
    options.unit = lib.mkOption { type = lib.types.enum [ "mL" "L" "gal" ]; default = "L"; description = "Unit"; };
  };
  costType = lib.types.submodule {
    options.value = lib.mkOption { type = lib.types.float; default = 0.0; description = "Value"; };
    options.currency = lib.mkOption { type = lib.types.enum [ "USD" "EUR" "XMR" "BTC" "none" ]; default = "USD"; description = "Currency"; };
  };

  # -- Signature submodule --
  sigType = lib.types.submodule {
    options = {
      thermal    = lib.mkOption { type = lib.types.enum [ "unmanaged" "passive" "active" ]; default = "unmanaged"; description = "Thermal"; };
      acoustic   = lib.mkOption { type = lib.types.enum [ "unmanaged" "dampened" "silent" ]; default = "unmanaged"; description = "Acoustic"; };
      visual     = lib.mkOption { type = lib.types.enum [ "visible" "camouflaged" "concealed" ]; default = "visible"; description = "Visual"; };
      electronic = lib.mkOption { type = lib.types.enum [ "tracked" "minimal" "dark" ]; default = "minimal"; description = "Electronic"; };
      financial  = lib.mkOption { type = lib.types.enum [ "traceable" "pseudonymous" "anonymous" ]; default = "traceable"; description = "Financial"; };
    };
  };

  # -- Item submodule (BOM leaf node) --
  itemType = lib.types.submodule {
    options = {
      name       = lib.mkOption { type = lib.types.str; description = "Human-readable name"; };
      model      = lib.mkOption { type = lib.types.str; description = "Specific model/SKU"; };
      qty        = lib.mkOption { type = lib.types.int; default = 1; description = "Qty"; };
      unitCost   = lib.mkOption { type = costType; default = {}; description = "Unit cost"; };
      weight     = lib.mkOption { type = massType; default = {}; description = "Weight"; };
      volume     = lib.mkOption { type = volType; default = {}; description = "Volume"; };
      packTime   = lib.mkOption { type = durationType; default = {}; description = "Pack time"; };
      source     = lib.mkOption { type = lib.types.enum [ "diy" "salvage" "trade" "url" "local" ]; default = "diy"; description = "Source"; };
      status     = lib.mkOption { type = lib.types.enum [ "needed" "sourced" "ordered" "acquired" "tested" "deployed" ]; default = "needed"; description = "Status"; };
      competency = lib.mkOption { type = lib.types.enum [ "untrained" "novice" "intermediate" "proficient" "expert" ]; default = "untrained"; description = "Competency"; };
      signature  = lib.mkOption { type = sigType; default = {}; description = "Signature"; };
    };
  };

  items = lib.mkOption { type = lib.types.listOf itemType; default = []; description = "Items"; };
  sig = lib.mkOption { type = sigType; default = {}; description = "Sig"; };
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
        teardownTime = lib.mkOption { type = durationType; default = { value = 15.0; unit = "min"; }; description = "Teardown time"; };
        maxWeight    = lib.mkOption { type = massType; default = { value = 25.0; unit = "kg"; }; description = "Max weight"; };
        maxVolume    = lib.mkOption { type = volType; default = { value = 65.0; unit = "L"; }; description = "Max volume"; };
        mobility     = lib.mkOption { type = lib.types.enum [ "foot" "bicycle" "motorcycle" "vehicle" ]; default = "foot"; description = "Mobility"; };
      };
      urban = {
        blendLevel        = lib.mkOption { type = lib.types.enum [ "tourist" "resident" "local" "native" ]; default = "resident"; description = "Blend level"; };
        infrastructureUse = lib.mkOption { type = lib.types.enum [ "none" "minimal" "selective" "full" ]; default = "selective"; description = "Infrastructure use"; };
        burnerDevices     = lib.mkEnableOption "burner devices for cover";
        realDevices       = lib.mkEnableOption "real identity devices (separate)";
      };
      base = {
        permanence        = lib.mkOption { type = lib.types.enum [ "temporary" "seasonal" "semi-permanent" "permanent" ]; default = "semi-permanent"; description = "Permanence"; };
        expansionCapacity = lib.mkOption { type = lib.types.int; default = 4; description = "Expansion capacity"; };
        redundancy        = lib.mkOption { type = lib.types.enum [ "none" "n+1" "2n" ]; default = "n+1"; description = "Redundancy"; };
        cacheLocations    = lib.mkOption { type = lib.types.int; default = 0; description = "Cache locations"; };
      };
    };

    # -- Energy (Tier 1) --
    energy = {
      generation = {
        types    = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "solar" "wind" "hydro" "thermal" "manual" "fuel" ]); default = [ "solar" ]; description = "Types"; };
        capacity = lib.mkOption { type = powerType; default = { value = 100.0; unit = "W"; }; description = "Capacity"; };
        inherit items;
      };
      storage = {
        capacity  = lib.mkOption { type = energyQtyType; default = { value = 1.0; unit = "kWh"; }; description = "Capacity"; };
        chemistry = lib.mkOption { type = lib.types.enum [ "lifepo4" "li-ion" "lead-acid" "supercap" "mechanical" ]; default = "lifepo4"; description = "Chemistry"; };
        inherit items;
      };
      distribution = {
        voltage = lib.mkOption { type = lib.types.enum [ "5V" "12V" "24V" "48V" "120V" "240V" ]; default = "12V"; description = "Voltage"; };
        inherit items;
      };
      signature = sig;
    };

    # -- Water (Tier 1) --
    water = {
      sources      = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "rain" "well" "surface" "atmospheric" "recycled" ]); default = [ "rain" ]; description = "Sources"; };
      purification = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "filter" "uv" "boil" "distill" "reverse-osmosis" "chemical" ]); default = [ "filter" "uv" ]; description = "Purification"; };
      capacity     = lib.mkOption { type = capType; default = { value = 100.0; unit = "L"; }; description = "Capacity"; };
      signature    = sig;
      inherit items;
    };

    # -- Food (Tier 1) --
    food = {
      acquisition  = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "forage" "hunt" "fish" "cultivate" "trade" "store" ]); default = [ "store" "cultivate" ]; description = "Acquisition"; };
      preservation = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "dry" "smoke" "salt" "ferment" "freeze" "can" "vacuum" ]); default = [ "dry" "vacuum" ]; description = "Preservation"; };
      cultivation = {
        method = lib.mkOption { type = lib.types.enum [ "soil" "hydroponic" "aquaponic" "aeroponic" ]; default = "soil"; description = "Method"; };
        scale  = lib.mkOption { type = lib.types.enum [ "personal" "family" "community" ]; default = "personal"; description = "Scale"; };
        inherit items;
      };
      signature = sig;
      inherit items;
    };

    # -- Shelter (Tier 1) --
    shelter = {
      shelterType = lib.mkOption { type = lib.types.enum [ "tent" "vehicle" "structure" "underground" "natural" ]; default = "tent"; description = "Shelter type"; };
      mobility    = lib.mkOption { type = lib.types.enum [ "portable" "relocatable" "fixed" ]; default = "portable"; description = "Mobility"; };
      climate = {
        heating = lib.mkOption { type = lib.types.enum [ "none" "passive" "active" ]; default = "passive"; description = "Heating"; };
        cooling = lib.mkOption { type = lib.types.enum [ "none" "passive" "active" ]; default = "passive"; description = "Cooling"; };
      };
      signature = sig;
      inherit items;
    };

    # -- Medical (Tier 2) --
    medical = {
      level        = lib.mkOption { type = lib.types.enum [ "firstaid" "emt" "paramedic" "field-surgery" ]; default = "firstaid"; description = "Level"; };
      pharmacy = {
        synthesis = lib.mkEnableOption "compound synthesis";
        botanical = lib.mkEnableOption "botanical medicine";
        inherit items;
      };
      diagnostics  = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "vitals" "blood" "imaging" "lab" ]); default = [ "vitals" ]; description = "Diagnostics"; };
      telemedicine = lib.mkEnableOption "remote medical consultation";
      inherit items;
    };

    # -- Comms (Tier 2) --
    comms = {
      mesh = {
        enable   = lib.mkEnableOption "mesh networking";
        protocol = lib.mkOption { type = lib.types.enum [ "lora" "meshtastic" "reticulum" "yggdrasil" "cjdns" ]; default = "meshtastic"; description = "Protocol"; };
        inherit items;
      };
      burst = {
        enable      = lib.mkEnableOption "burst transmission mode";
        maxDuration = lib.mkOption { type = durationType; default = { value = 500.0; unit = "s"; }; description = "Max duration"; };
      };
      encryption = lib.mkOption { type = lib.types.enum [ "none" "aes256" "chacha20" "otp" ]; default = "chacha20"; description = "Encryption"; };
      rf = {
        maxPower = lib.mkOption { type = powerType; default = { value = 100.0; unit = "mW"; }; description = "Max power"; };
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
      architecture = lib.mkOption { type = lib.types.enum [ "riscv64" "aarch64" "x86_64" ]; default = "aarch64"; description = "Architecture"; };
      openness     = lib.mkOption { type = lib.types.enum [ "full" "partial" "pragmatic" ]; default = "partial"; description = "Openness"; };
      airgap       = lib.mkEnableOption "air-gapped operation";
      disposable   = lib.mkEnableOption "disposable/burner capability";
      knowledge = {
        static = {
          enable  = lib.mkEnableOption "static knowledge base (kiwix, offline wikis)";
          sources = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "wikipedia" "wikibooks" "stackexchange" "arxiv" "gutenberg" ]); default = [ "wikipedia" "wikibooks" "stackexchange" ]; description = "Sources"; };
          inherit items;
        };
        llm = {
          enable = lib.mkEnableOption "local LLM";
          model  = lib.mkOption { type = lib.types.enum [ "llama-7b" "llama-13b" "mistral-7b" "phi-2" "codellama" ]; default = "llama-7b"; description = "Model"; };
          inherit items;
        };
        structured = {
          enable  = lib.mkEnableOption "structured queryable databases";
          domains = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "plants" "chemicals" "electronics" "medical" "geology" "astronomy" ]); default = [ "plants" "chemicals" "electronics" "medical" ]; description = "Domains"; };
          inherit items;
        };
      };
      inherit items;
    };

    # -- Intelligence (Tier 3) --
    intelligence = {
      osint = {
        enable  = lib.mkEnableOption "OSINT capabilities";
        domains = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "social" "geospatial" "domain" "image" "video" "document" "darkweb" ]); default = [ "social" "geospatial" "image" ]; description = "Domains"; };
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
        sensors = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "motion" "seismic" "acoustic" "thermal" "rf" ]); default = []; description = "Sensors"; };
        inherit items;
      };
      earlyWarning = {
        enable = lib.mkEnableOption "early warning system";
        range  = lib.mkOption { type = distType; default = { value = 100.0; unit = "m"; }; description = "Range"; };
        inherit items;
      };
      physical = {
        hardening   = lib.mkOption { type = lib.types.enum [ "none" "basic" "reinforced" "fortified" ]; default = "none"; description = "Hardening"; };
        concealment = lib.mkOption { type = lib.types.enum [ "none" "camouflage" "decoy" "underground" ]; default = "none"; description = "Concealment"; };
        inherit items;
      };
      commsec = lib.mkEnableOption "communications security";
    };

    # -- Transport (Tier 4) --
    transport = {
      modes      = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "foot" "bicycle" "motorcycle" "vehicle" "boat" "aircraft" ]); default = [ "foot" "bicycle" ]; description = "Modes"; };
      fuel       = lib.mkOption { type = lib.types.enum [ "human" "electric" "gasoline" "diesel" "multi" ]; default = "human"; description = "Fuel"; };
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
      methods = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "barter" "crypto" "cash" "commodity" "service" ]); default = [ "barter" "crypto" ]; description = "Methods"; };
      crypto = {
        enable      = lib.mkEnableOption "cryptocurrency";
        coins       = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "btc" "xmr" "zec" ]); default = [ "xmr" ]; description = "Coins"; };
        coldStorage = lib.mkEnableOption "cold storage";
        inherit items;
      };
      supplyChain = {
        verification = lib.mkEnableOption "supply chain verification";
        redundancy   = lib.mkOption { type = lib.types.int; default = 2; description = "Redundancy"; };
      };
      signature = sig;
    };

    # -- Fabrication (Tier 4) --
    fabrication = {
      tier = lib.mkOption { type = lib.types.enum [ "assembly" "component" "material" ]; default = "assembly"; description = "Tier"; };
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
      materials = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "plastic" "metal" "wood" "ceramic" "composite" "electronic" ]); default = [ "plastic" ]; description = "Materials"; };
      inherit items;
    };
  };
}
