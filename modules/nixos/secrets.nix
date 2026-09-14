# sops-nix secret decryption. The host SSH key derives the age identity used
# to decrypt secrets/secrets.yaml at activation. Rendered secrets land in
# /run/secrets/<name>, owned by lawliet so user shells and tools can read them.
{ config, ... }:

let
  user = config.users.users.lawliet.name;
in
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    validateSopsFiles = true;

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Only declare keys that exist in secrets.yaml, or activation fails.
    secrets = {
      meta_model_api_key.owner = user;
      gog_keyring_password.owner = user;
      openai_api_key.owner = user;
      figma_token.owner = user;
    };
  };
}
