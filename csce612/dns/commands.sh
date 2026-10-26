#!/bin/sh
# DNS lookup reference (macOS). Run with: sh dns_commands.txt
# Every description is a shell comment, so the file executes as-is.

# ---------- nslookup: basic ----------
nslookup www.cs.tamu.edu                               # A record via default resolver; "Non-authoritative" = from resolver cache/recursion
nslookup -type=aaaa www.google.com                     # AAAA (IPv6) address
nslookup -type=mx cs.tamu.edu                          # mail exchangers; lower preference number = tried first
nslookup -type=ns tamu.edu                             # authoritative name servers for the zone
nslookup -type=soa cs.tamu.edu                         # zone metadata: primary NS, admin mail, serial, refresh/retry/expire, negative-cache TTL
nslookup -type=txt tamu.edu                            # TXT records (SPF, domain verification tokens)
nslookup -type=cname www.github.com                    # alias -> canonical name, if one exists

# ---------- nslookup: reverse (PTR) ----------
nslookup 128.194.138.12                                # PTR lookup; nslookup reverses the IP for you
nslookup -type=ptr 12.138.194.128.in-addr.arpa         # explicit reversed form (what hw2 must construct)
nslookup -type=ptr 12.1.55.186                         # RFC 2317 classless delegation example (CNAME into 184/29 sub-zone)

# ---------- nslookup: error cases ----------
nslookup nope-does-not-exist.tamu.edu                  # NXDOMAIN: name does not exist (RCODE 3)
nslookup -type=hinfo cs.tamu.edu                       # NODATA: name exists, no record of this type; SOA comes back in Authority section

# ---------- nslookup: control ----------
nslookup www.cs.tamu.edu 8.8.8.8                       # query a specific server instead of the system resolver
nslookup -norecurse -type=ns edu 198.41.0.4            # ask a root server directly with RD=0 -> referral, not an answer
nslookup -debug -type=a www.cs.tamu.edu                # dump header flags + question/answer/authority/additional sections with TTLs
nslookup -timeout=2 -retry=1 www.cs.tamu.edu           # 2 s timeout, 1 retry

# ---------- dig (more detail, maps directly onto packet layout) ----------
dig www.cs.tamu.edu A                                  # full response: header flags, all four sections, query time, server
dig cs.tamu.edu MX +short                              # just the record data, no decoration
dig -x 128.194.138.12                                  # reverse (PTR) lookup
dig +trace www.cs.tamu.edu                             # iterative walk: root -> edu -> tamu.edu -> answer, showing each referral
dig +norec @198.41.0.4 www.cs.tamu.edu A               # one manual iterative step: root returns edu NS referral + glue
dig +norec @a.edu-servers.net www.cs.tamu.edu A        # next step: edu servers return tamu.edu referral
dig nope-does-not-exist.tamu.edu                       # see status: NXDOMAIN and SOA in AUTHORITY section

# ---------- packet capture (commented out: blocks / needs sudo) ----------
# sudo tcpdump -i en0 -X port 53                       # hex dump of every DNS packet on the interface; Ctrl-C to stop
# Wireshark with display filter "dns"                  # parsed view of header fields and sections, useful for debugging hw2
