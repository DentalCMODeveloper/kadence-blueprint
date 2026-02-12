#!/bin/bash

echo "===== Kadence Blueprint Deploy ====="

############################################
# LICENSE PROMPT (One-Time Setup)
############################################
if [ ! -f ".licenses" ]; then
  echo ""
  echo "License file not found."
  echo "Enter license keys now (press Enter to skip any):"
  echo ""

  read -p "Formidable Pro License: " FORMIDABLE_LICENSE
  read -p "Perfmatters License: " PERFMATTERS_LICENSE
  read -p "Kadence License: " KADENCE_LICENSE

  cat > .licenses <<EOF
FORMIDABLE_LICENSE="$FORMIDABLE_LICENSE"
PERFMATTERS_LICENSE="$PERFMATTERS_LICENSE"
KADENCE_LICENSE="$KADENCE_LICENSE"
EOF

  chmod 600 .licenses
  echo ".licenses file created."
fi

# Load licenses
source .licenses

# Verify licenses
echo "Verifying licenses..."

wp option get frmpro_license
wp option get perfmatters_license_key
wp option get kt_api_manager_kadence_theme

STEP_FILE=".kadence_step"

# Read step
if [ -f "$STEP_FILE" ]; then
  STEP=$(cat "$STEP_FILE")
else
  STEP=0
fi

echo "Current step: $STEP"

############################################
# STEP 1 — GitHub SSH Check (Pause/Resume)
############################################
if [ "$STEP" -lt 1 ]; then
  echo "Checking GitHub SSH access..."

  if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "kinsta-blueprint" -N "" -f ~/.ssh/id_ed25519
    echo ""
    echo "Add this key to GitHub → SSH Keys, then rerun:"
    echo "wp blueprint deploy"
    cat ~/.ssh/id_ed25519.pub
    exit 1
  fi

  if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo ""
    echo "GitHub SSH not authorized. Add this key and rerun:"
    cat ~/.ssh/id_ed25519.pub
    exit 1
  fi

  echo "GitHub access OK"
  echo "1" > "$STEP_FILE"
fi

############################################
# STEP 2 — Install Theme
############################################
if [ "$STEP" -lt 2 ]; then
  echo "Installing Kadence theme..."
  wp theme install kadence --activate --quiet
  echo "2" > "$STEP_FILE"
fi

############################################
# STEP 3 — Free Plugins
############################################
if [ "$STEP" -lt 3 ]; then
  echo "Installing free plugins..."
  while IFS= read -r plugin || [ -n "$plugin" ]; do
    wp plugin install "$plugin" --activate --quiet
  done < required-plugins.txt
  echo "3" > "$STEP_FILE"
fi

############################################
# STEP 4 — Premium Plugins
############################################
if [ "$STEP" -lt 4 ]; then
  echo "Installing premium plugins..."
  for zip in premium-plugins/*.zip; do
    wp plugin install "$zip" --activate --quiet
  done
  echo "4" > "$STEP_FILE"
fi

############################################
# STEP 5 — Licenses
############################################
if [ "$STEP" -lt 5 ]; then
  echo "Applying licenses..."

  if [ -n "$FORMIDABLE_LICENSE" ]; then
    wp option update frmpro_license "$FORMIDABLE_LICENSE"
  fi

  if [ -n "$PERFMATTERS_LICENSE" ]; then
    wp option update perfmatters_license_key "$PERFMATTERS_LICENSE"
  fi

  if [ -n "$KADENCE_LICENSE" ]; then
    wp option update kt_api_manager_kadence_theme "$KADENCE_LICENSE"
  fi

  echo "5" > "$STEP_FILE"
fi

wp cron event run --due-now >/dev/null 2>&1 || true

############################################
# STEP 6 — Import Formidable Forms (XML)
############################################
FORM_COUNT=$(wp db query "SELECT COUNT(*) FROM wp_frm_forms;" --skip-column-names)

if [ "$FORM_COUNT" -eq 0 ]; then
  # run import
fi

if [ "$STEP" -lt 6 ]; then
  echo "Importing Formidable forms..."

  if [ -f "formidable-forms.xml" ]; then
    wp eval '
    if ( class_exists("FrmXMLController") ) {
        $xml_file = "formidable-forms.xml";
        FrmXMLController::import_xml( $xml_file );
        echo "Forms imported.\n";
    } else {
        echo "Formidable importer not available.\n";
    }
    '
  fi

  echo "6" > "$STEP_FILE"
fi

echo "Importing Formidable settings..."

wp option update frm_options "$(cat formidable-settings.json)"


############################################
# STEP 7 — Custom Plugins (Git Pull/Clone)
############################################
if [ "$STEP" -lt 7 ]; then
  echo "Installing/updating custom plugins..."

  cd ../wp-content/plugins || exit

  # LUMN Utilities
  if [ -d "lumn-utilities-2" ]; then
    cd lumn-utilities-2 && git pull origin main && cd ..
  else
    git clone git@github.com:DentalCMODeveloper/lumn-utilities-2.git
  fi

  # LUMN Prospecta
  if [ -d "LUMN-Prospecta" ]; then
    cd LUMN-Prospecta && git pull origin main && cd ..
  else
    git clone git@github.com:DentalCMODeveloper/LUMN-Prospecta.git
  fi

  cd ../../kadence-blueprint || exit

  wp plugin activate lumn-utilities-2 --quiet || true
  wp plugin activate LUMN-Prospecta --quiet || true

  echo "7" > "$STEP_FILE"
fi

############################################
# STEP 8 — Import WPCode Snippets
############################################
if [ "$STEP" -lt 8 ]; then
  echo "Importing WPCode snippets..."
  wp import wpcode-snippets.xml --authors=create --quiet || true
  echo "7" > "$STEP_FILE"
fi

echo "Activating WPCode snippets..."

wp post list --post_type=wpcode --format=ids | while read id; do
  wp post meta update "$id" _wpcode_active 1
done

############################################
# STEP 9 — Import Elements + Blocks
############################################
if [ "$STEP" -lt 9 ]; then
  echo "Importing Kadence Elements..."
  wp import kadence-elements.xml --authors=create --quiet

  echo "Importing Reusable Blocks..."
  wp import reusable-blocks.xml --authors=create --quiet

  echo "9" > "$STEP_FILE"
fi

############################################
# STEP 10 — Ensure Customizer CLI Installed
############################################
if [ "$STEP" -lt 10 ]; then
  echo "Checking Customizer CLI..."

  if ! wp customizer --help >/dev/null 2>&1; then
    wp package install wp-cli/customizer-command --quiet
  fi

  echo "10" > "$STEP_FILE"
fi

############################################
# STEP 11 — Import Customizer
############################################
if [ "$STEP" -lt 11 ]; then
  echo "Importing Customizer settings..."
  wp customizer import customizer.dat --yes --quiet
  echo "11" > "$STEP_FILE"
fi

############################################
# STEP 12 — Install MU Plugin (Blueprint CLI Loader)
############################################
if [ "$STEP" -lt 12 ]; then
  echo "Installing Blueprint MU plugin..."

  MU_DIR="../wp-content/mu-plugins"
  MU_FILE="$MU_DIR/blueprint-cli-loader.php"

  mkdir -p "$MU_DIR"

  cat > "$MU_FILE" <<'PHP'
<?php
/**
 * Plugin Name: Blueprint CLI Loader
 * Description: Loads the Kadence Blueprint WP-CLI command.
 */

if ( defined( 'WP_CLI' ) && WP_CLI ) {
    $path = ABSPATH . 'kadence-blueprint/blueprint-cli.php';
    if ( file_exists( $path ) ) {
        require_once $path;
    }
}
PHP

  echo "MU plugin installed."
  echo "12" > "$STEP_FILE"
fi

############################################
# STEP 13 — Flush + Finish
############################################
if [ "$STEP" -lt 13 ]; then
  echo "Finalizing..."
  wp rewrite flush --quiet
  wp cache flush --quiet
  rm -f "$STEP_FILE"
  echo "Blueprint deploy complete."
fi
