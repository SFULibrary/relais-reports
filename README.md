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

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
