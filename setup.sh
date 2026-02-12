#!/bin/bash

echo "----- Kadence Blueprint Setup -----"

# Install Kadence Theme
wp theme install kadence --activate

# Install required plugins
while read plugin; do
  wp plugin install $plugin --activate
done < required-plugins.txt

# Import Kadence Elements
wp import kadence-elements.xml --authors=create

# Import Reusable Blocks
wp import patterns.xml --authors=create

echo "----- Setup Complete -----"
