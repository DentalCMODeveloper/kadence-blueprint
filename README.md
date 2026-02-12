## Kadence Blueprint Deployment System

---

# Quick Start

Follow these steps to deploy the Kadence Blueprint on a new site.

## 1. SSH Into the Server

Copy and paste the command under Kinsta > Sites > Environment > Info > Primary SFTP/SSH user > SSH terminal command
(i.e. ssh elizabethkadence@00.000.00.000 -p port)

Type 'yes' if prompted to save fingerprint

Enter password in same 'Primary SFTP/SSH user' section

## 2. Navigate to the WordPress root

cd public

You should see folders like:
wp-admin
wp-content
wp-config.php

## 3. Clone the blueprint

git clone git@github.com:DentalCMODeveloper/kadence-blueprint.git

## 4. Run the blueprint

# First time
bash blueprint.sh

# Every other time
wp blueprint deploy

The system will now:

Install Kadence theme
Install plugins
Import design system
Import forms & snippets
Apply settings
Activate everything automatically

## 5. If Prompted — Add SSH Key to GitHub

On first run, you may see an SSH key displayed.

1. Copy the key shown in terminal
2. Go to GitHub → Settings → SSH Keys
3. Click New SSH Key
4. Paste and save
5. Run: bash blueprint.sh
5. Reruns: wp blueprint deploy

## 5. (Optional) Use a Child Theme

wp blueprint deploy --child=default

Available child themes are located in:
kadence-blueprint/child-themes/

--

This repository contains the **Kadence Blueprint**, an automated deployment tool used to standardize WordPress builds across projects.

It installs the Kadence framework, plugins, custom settings, forms, snippets, and optional child themes using a single command.

---

## What This Does

Running the Blueprint will:

- Install Kadence theme
- Install required free & premium plugins
- Pull and update custom plugins from GitHub
- Apply Kadence Customizer design system
- Import Kadence Elements & reusable blocks
- Import WPCode (Insert Headers & Footers) snippets
- Import Formidable forms
- Apply plugin license keys (if provided)
- Optionally install a selected Kadence child theme
- Automatically resume if interrupted
- Work across staging or production

---

## Requirements

- SSH access to the server
- WP-CLI installed (Kinsta includes this)
- Access to the private GitHub repositories
- Kadence Blueprint repo cloned into WordPress root (`/public/kadence-blueprint`)

---

## First-Time Setup (Per Environment)

1. SSH into the server
2. Navigate to the WordPress root:
   cd public
3. Run
   # First time
   bash blueprint.sh
   # Every other time
   wp blueprint deploy
4. If prompted, add the displayed SSH key to GitHub:
   GitHub → Settings → SSH Keys
5. Rerun the command after adding the key

## Standard Deployment
# First time
bash blueprint.sh
# Every other time
wp blueprint deploy

## Deploy with a child theme
wp blueprint deploy --child=default

## Child themes must exist in
kadence-blueprint/child-themes/{name}

## License keys are stored locally and never committed to Git.
kadence-blueprint/.licenses

If the file is missing, Blueprint will prompt for licenses automatically.

## If deployment is interrupted, simply rerun:
wp blueprint deploy

The process resumes from the last completed step.

## To force a full rebuild
rm kadence-blueprint/.kadence_step
wp blueprint deploy

## After pulling updates to this repo
cd kadence-blueprint
git pull
# First time
bash blueprint.sh
# Every other time
wp blueprint deploy

## Repository structure
kadence-blueprint/
  blueprint.sh               Deployment script
  blueprint-cli.php          WP-CLI command wrapper
  required-plugins.txt       Free plugins to install
  customizer.dat             Kadence design system
  kadence-elements.xml       Headers / Elements
  reusable-blocks.xml        Reusable block templates
  formidable-forms.xml       Standard Formidable forms
  wpcode-snippets.xml        WPCode snippets
  premium-plugins/           Premium plugin ZIP files
  child-themes/              Optional Kadence child themes
  .licenses                  (local, ignored)

## Troubleshooting
# Command not found
Ensure MU plugin loader exists:
wp-content/mu-plugins/blueprint-cli-loader.php

# GitHub access denied
Run:
wp blueprint deploy

Add the displayed SSH key to GitHub and rerun.

# Plugins not activating
Run:
wp plugin list

Confirm required plugins are installed.

## Notes for Developers
Do NOT commit .licenses
Do NOT commit .kadence_step
Premium plugin ZIPs must be kept updated
Child themes must follow WordPress theme structure
Blueprint is safe to rerun multiple times

---

# Developer Setup

This section is for developers who need to **modify, update, or maintain the Kadence Blueprint** repository.

If you only need to deploy sites, see **Quick Start** instead.

---

## 1. Add Your SSH Key to GitHub
To work with this private repository, your machine must be authorized.

### Check if you already have a key
ls ~/.ssh

Look for:
id_ed25519
id_ed25519.pub

If missing, generate one:
ssh-keygen -t ed25519 -C "developers@dentalcmo.com"

Copy your public key:
cat ~/.ssh/id_ed25519.pub

Then:
1. Go to GitHub → Settings → SSH Keys
2. Click New SSH Key
3. Paste the key
4. Save

Test Connection:
ssh -T git@github.com

You should see:
You've successfully authenticated

## 2. Clone the Blueprint repository
Go to your preferred directory and run:
git clone git@github.com:DentalCMODeveloper/kadence-blueprint.git
cd kadence-blueprint

## 3. Pull Latest Updates
Before making changes, always update:
git pull origin main

## 4. Make Changes

Typical changes include:

- Updating blueprint.sh
- Updating blueprint-cli.php
- Updating exports (Customizer, Forms, Snippets)
- Updating premium plugin ZIP files
- Adding or modifying child themes
- Updating documentation

## 5. Commit Changes

Check what changed:
git status

Stage files:
git add .

Commit:
git commit -m "Describe your change"

## 6. Push to Github
git push origin main

## 7. Deploy Updated Blueprint to a Site
cd kadence-blueprint
git pull
# First time
bash blueprint.sh
# All following
wp blueprint deploy