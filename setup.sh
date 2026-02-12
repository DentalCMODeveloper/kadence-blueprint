#!/bin/bash

echo "----- Kadence Blueprint Setup -----"

# Install Kadence Theme
wp theme install kadence --activate

# Install free plugins
while read plugin; do
  wp plugin install $plugin --activate
done < required-plugins.txt

# Install premium plugins
echo "Installing premium plugins..."

wp plugin install premium-plugins/formidable-pro-6.25.1.zip --activate
wp plugin install premium-plugins/kadence-blocks.zip --activate
wp plugin install premium-plugins/kadence-blocks-pro.2.8.10.zip --activate
wp plugin install premium-plugins/kadence-build-child-defaults.1.0.9.zip --activate
wp plugin install premium-plugins/kadence-cloud.1.1.2.zip --activate
wp plugin install premium-plugins/kadence-cloud-pages-release-update.zip --activate
wp plugin install premium-plugins/kadence-cloud-surecart-license.1.0.4.zip --activate
wp plugin install premium-plugins/kadence-conversions.1.1.5.zip --activate
wp plugin install premium-plugins/kadence-creative-kit.1.1.2.zip --activate
wp plugin install premium-plugins/kadence-custom-fonts.1.1.5.zip --activate
wp plugin install premium-plugins/kadence-galleries.1.3.3.zip --activate
wp plugin install premium-plugins/kadence-insights.1.0.3.zip --activate
wp plugin install premium-plugins/kadence-pro.1.1.17.zip --activate
wp plugin install premium-plugins/kadence-recaptcha.1.3.7.zip --activate
wp plugin install premium-plugins/kadence-reading-time.1.0.5.zip --activate
wp plugin install premium-plugins/kadence-simple-share.1.2.13.zip --activate
wp plugin install premium-plugins/kadence-white-label.1.0.1.zip --activate
wp plugin install premium-plugins/kadence-woocommerce-email-designer.zip --activate
wp plugin install premium-plugins/kadence-woo-extras.2.4.13.zip --activate

# Install custom Plugins
echo "Installing custom plugins from GitHub..."
cd ../wp-content/plugins

# Remove existing copies
rm -rf lumn-utilities-2
rm -rf LUMN-Prospecta

# Clone plugins
git clone git@github.com:DentalCMODeveloper/lumn-utilities-2.git
git clone git@github.com:DentalCMODeveloper/LUMN-Prospecta.git

cd ../../kadence-blueprint

# Activate plugins
wp plugin activate lumn-utilities-2
wp plugin activate LUMN-Prospecta-main

# Import Kadence Elements
wp import kadence-elements.xml --authors=create

# Import Reusable Blocks
wp import reusable-blocks.xml --authors=create

echo "----- Setup Complete -----"
