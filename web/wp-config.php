<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'wpuser' );

/** Database password */
define( 'DB_PASSWORD', 'password' );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          'Dvo(6:yD0V/PeTtNHX:j~ii+6|q(fGn(j|6^{Zt5aj>Up= jOT~BpU/E}L&xhh3t' );
define( 'SECURE_AUTH_KEY',   'mLU:[klfZY_^BnjeU):JDw[dK/PbzT0p?S6<^jkd]-0.h95lOB8&dha.4xiyIST_' );
define( 'LOGGED_IN_KEY',     '<-Z{,i%>7aA_P`G}z]Z6Utf-b.c*;2qc%s}$p=BI1x|+a7yQEBi+VKZ)3<?kVRIz' );
define( 'NONCE_KEY',         '8J)35!~ ,n^p[4-ny&+?=rf=>9~&,FS.W 2&swIOn1X{+D<|d%NrkG9:B{D|^q<S' );
define( 'AUTH_SALT',         '.iC9?,y, LEBh0pbG(sv|GPpt.AZR$/ZgMj6!IWJ8WV/7`2t>h)RB1Pycy0];;P9' );
define( 'SECURE_AUTH_SALT',  '8V4-%L9F@[V6J*K=,AY7J9`y|}?a<KPe{nXs5sFS:MS0nCnn6?}=B:%QJ0`69&pV' );
define( 'LOGGED_IN_SALT',    'cfFkM 0D`^KD]6*_:um*] xb`X|S)`)[#n,^ssTA%#90pt;7#7K|aY$c;Mi eQAK' );
define( 'NONCE_SALT',        'IPwImrY~+e],cn;YwtAJ_U.%2m9J7b;!^0I4TO!N(`<|bEbE,N^,- KN?6U~(;B<' );
define( 'WP_CACHE_KEY_SALT', '5Z6nUJi@Bq3/kAj>~Fb2o2#0{M|n;~EYwRdi-;UTs!0C_5x@)C4>2Or=/4@=]%u}' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */



/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', false );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
