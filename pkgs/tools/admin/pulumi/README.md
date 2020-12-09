Update versions at the top of update.sh to match those in pacakge-lock.json of aws-infra

Run ./update.sh

nix-env -iA nixpkgs-fork.pulumi-bin
