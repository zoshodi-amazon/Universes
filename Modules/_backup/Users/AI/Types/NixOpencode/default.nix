# NixOpencode — typed option space for OpenCode AI agent
{ lib, ... }:
{
  options.ai.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding agent";
    provider = lib.mkOption {
      type = lib.types.enum [ "amazon-bedrock" "anthropic" "openai" "openrouter" "ollama" ];
      default = "amazon-bedrock";
      description = "LLM provider backend";
    };
    region = lib.mkOption {
      type = lib.types.str;
      default = "us-east-1";
      description = "AWS region for Bedrock provider";
    };
    profile = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "AWS named profile from ~/.aws/credentials";
    };
    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Custom endpoint URL for VPC PrivateLink";
    };
    rules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Global custom instructions for the agent";
    };
    extraSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Additional opencode config merged into settings";
    };
  };
}
