# Constants used in many parts of the SpamAssassin codebase.
#
# TODO! we need to reimplement parts of the RESERVED regexp!

# <@LICENSE>
# Copyright 2004 Apache Software Foundation
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# </@LICENSE>

package Mail::SpamAssassin::Constants;

use vars qw (
	@BAYES_VARS @IP_VARS @SA_VARS
);

use base qw( Exporter );

@IP_VARS = qw(
	IP_IN_RESERVED_RANGE IP_PRIVATE LOCALHOST IPV4_ADDRESS IP_ADDRESS
);
@BAYES_VARS = qw(
	DUMP_MAGIC DUMP_TOKEN DUMP_BACKUP 
);
# These are generic constants that may be used across several modules
@SA_VARS = qw(
	META_TEST_MIN_PRIORITY HARVEST_DNSBL_PRIORITY MBX_SEPARATOR
	MAX_BODY_LINE_LENGTH MAX_HEADER_KEY_LENGTH MAX_HEADER_VALUE_LENGTH
	MAX_HEADER_LENGTH ARITH_EXPRESSION_LEXER AI_TIME_UNKNOWN
);

%EXPORT_TAGS = (
	bayes => [ @BAYES_VARS ],
        ip => [ @IP_VARS ],
        sa => [ @SA_VARS ],
        all => [ @BAYES_VARS, @IP_VARS, @SA_VARS ],
);

@EXPORT_OK = ( @BAYES_VARS, @IP_VARS, @SA_VARS );

# BAYES_VARS
use constant DUMP_MAGIC  => 1;
use constant DUMP_TOKEN  => 2;
use constant DUMP_SEEN   => 4;
use constant DUMP_BACKUP => 8;

# IP_VARS
# ---------------------------------------------------------------------------
# Initialize a regexp for private IPs, i.e. ones that could be
# used inside a company and be the first or second relay hit by
# a message. Some companies use these internally and translate
# them using a NAT firewall. These are listed in the RBL as invalid
# originators -- which is true, if you receive the mail directly
# from them; however we do not, so we should ignore them.
# 
# sources:
#   IANA  = <http://www.iana.org/assignments/ipv4-address-space>,
#           <http://duxcw.com/faq/network/privip.htm>,
#   APIPA = <http://duxcw.com/faq/network/autoip.htm>,
#   3330  = <ftp://ftp.rfc-editor.org/in-notes/rfc3330.txt>
#   CYMRU = <http://www.cymru.com/Documents/bogon-list.html>
#
# Last update
#   2005-01-10 Daniel Quinlan - reduced to standard private IP addresses
#
use constant IP_PRIVATE => qr{^(?:
  10|				   # 10/8:             Private Use (3330)
  127|				   # 127/8:            Private Use (localhost)
  169\.254|			   # 169.254/16:       Private Use (APIPA)
  172\.(?:1[6-9]|2[0-9]|3[01])|	   # 172.16-172.31/16: Private Use (3330)
  192\.168			   # 192.168/16:       Private Use (3330)
)\.}ox;

# backward compatibility
use constant IP_IN_RESERVED_RANGE => IP_PRIVATE;

# ---------------------------------------------------------------------------
# match the various ways of saying "localhost".
# 
use constant LOCALHOST => qr/
		    (?:
		      # as a string
		      localhost(?:\.localdomain)?
		    |
		      \b(?<!:)	# ensure no "::" IPv4 marker before this one
		      # plain IPv4
		      127\.0\.0\.1 \b
		    |
		      # IPv4 mapped in IPv6
		      0{0,4} : (?:0{0,4}\:){1,2} ffff: 
		      127\.0\.0\.1 \b
		    |
		      # pure-IPv6 address
		      (?:IPv6:    # with optional prefix
                        | (?<!:)
                      )
		      (?:0{0,4}\:){0,7} 1 
		    )
		  /oxi;

# ---------------------------------------------------------------------------
# an IP address, in IPv4 format only.
#
use constant IPV4_ADDRESS => qr/\b
		    (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\.
                    (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\.
                    (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\.
                    (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)
                  \b/ox;

# ---------------------------------------------------------------------------
# an IP address, in IPv4, IPv4-mapped-in-IPv6, or IPv6 format.  NOTE: cannot
# just refer to $IPV4_ADDRESS, due to perl bug reported in nesting qr//s. :(
#
use constant IP_ADDRESS => qr/
		    (?:
		      \b(?<!:)	# ensure no "::" IPv4 marker before this one
		      # plain IPv4, as above
		      (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\.
		      (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\.
		      (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\.
		      (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\b
		    |
		      # IPv4 mapped in IPv6
		      \:\: (?:[a-f0-9]{0,4}\:){0,4}
		      (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\.
		      (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\.
		      (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\.
		      (?:1\d\d|2[0-4]\d|25[0-5]|\d\d|\d)\b
		    |
		      # a pure-IPv6 address
		      # don't use \b here, it hits on :'s
		      (?:IPv6:    # with optional prefix
                        | (?<!:)
                      )
		      (?:[a-f0-9]{0,4}\:){0,7} [a-f0-9]{0,4}
		    )
		  /oxi;

# ---------------------------------------------------------------------------

use constant META_TEST_MIN_PRIORITY => 500;
use constant HARVEST_DNSBL_PRIORITY => 500;

# regular expression that matches message separators in The University of
# Washington's MBX mailbox format
use constant MBX_SEPARATOR => qr/([\s|\d]\d-[a-zA-Z]{3}-\d{4}\s\d{2}:\d{2}:\d{2}.*),(\d+);([\da-f]{12})-(\w{8})/;
# $1 = datestamp (str)
# $2 = size of message in bytes (int)
# $3 = message status - binary (hex)
# $4 = message ID (hex)

# ---------------------------------------------------------------------------
# values used for internal message representations

# maximum byte length of lines in the body
use constant MAX_BODY_LINE_LENGTH => 2048;
# maximum byte length of a header key
use constant MAX_HEADER_KEY_LENGTH => 256;
# maximum byte length of a header value including continued lines
use constant MAX_HEADER_VALUE_LENGTH => 8192;
# maximum byte length of entire header
use constant MAX_HEADER_LENGTH => 65536;

# used for meta rules and "if" conditionals in Conf::Parser
use constant ARITH_EXPRESSION_LEXER => qr/(?:
        [\-\+\d\.]+|                            # A Number
        \w[\w\:]+|                              # Rule or Class Name
        [\(\)]|                                 # Parens
        \|\||                                   # Boolean OR
        \&\&|                                   # Boolean AND
        \^|                                     # Boolean XOR
        !|                                      # Boolean NOT
        >=?|                                    # GT or EQ
        <=?|                                    # LT or EQ
        ==|                                     # EQ
        !=|                                     # NEQ
        [\+\-\*\/]|                             # Mathematical Operator
        [\?:]                                   # ? : Operator
      )/ox;

# ArchiveIterator

# if AI doesn't read in the message in the first pass to see if the received
# date makes the message useful or not, we need to mark it so that in the
# second pass (when the message is actually read + processed) the received
# date is calculated.  this value signifies "unknown" from the first pass.
use constant AI_TIME_UNKNOWN => 0;

1;
