# relais-reports

Some reporting tools for a Relais database

## Requirements

ODBC drivers must be installed, and configured to connect to your Relais database. In addition, the reports require the following Perl modules, which can be installed from CPAN:

 * DBD::ODBC
 * DBI
 * CGI
 * Try::Tiny
 * Template
 * DateTime
 * Config::Tiny

## Installation

Point a webserver at htdocs/report.cgi and make sure the css, fonts, and js directories in htdocs are web-acessible. Copy config.sample.ini to config.ini and add configure your database parameters.

## Authentication

None. Use the web server's built-in authentication methods.
