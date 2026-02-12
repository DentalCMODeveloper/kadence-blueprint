<?php
if ( ! defined( 'WP_CLI' ) ) {
    return;
}

class Blueprint_Command {

    /**
     * Deploy Kadence Blueprint
     *
     * ## OPTIONS
     *
     * [--child=<slug>]
     * : Optional child theme folder name inside kadence-blueprint/child-themes/
     *
     * ## EXAMPLES
     *
     *     wp blueprint deploy
     *     wp blueprint deploy --child=default
     */
    public function deploy( $args, $assoc_args ) {

        /* ======================================================
           ADD CHILD THEME ARGUMENT HANDLING RIGHT HERE
           ====================================================== */

        $child = isset( $assoc_args['child'] ) ? $assoc_args['child'] : '';

        if ( $child ) {
            // Pass child theme to shell script as env variable
            putenv( "BLUEPRINT_CHILD_THEME=$child" );
            WP_CLI::log( "Child theme selected: $child" );
        }

        /* ====================================================== */

        $script = ABSPATH . 'kadence-blueprint/blueprint.sh';

        if ( ! file_exists( $script ) ) {
            WP_CLI::error( "blueprint.sh not found." );
        }

        WP_CLI::log( "Running Kadence Blueprint..." );
        passthru( "bash $script" );
        WP_CLI::success( "Blueprint finished." );
    }
}

WP_CLI::add_command( 'blueprint', 'Blueprint_Command' );
