 

#include "Rip.h"

 
___RIP_inline
int ipv4_raw_input(const char *osrc, uint32_t *dst)
{
	const unsigned char *src = (const unsigned char *)osrc;
	int digits = 0;
	int octets = 0;
	int ch;
	uint32_t octet = 0;
	uint32_t tmp = 0;

	for (;;)
	{
		switch ((ch = *src++))
		{
			case '0': case '1': case '2': case '3': case '4':
			case '5': case '6': case '7': case '8': case '9':
				if (digits++ && octet == 0)
					return 0;    
				octet = (octet * 10) + (ch - '0');
				if (octet > 255)
					return 0;
				break;

			case '.':
				if (!digits || ++octets > 3)
					return 0;
				tmp = (tmp << 8) | octet;
				digits = 0;
				octet = 0;
				break;

			case 0:
				if (!digits || octets != 3)
					return 0;
				tmp = (tmp << 8) | octet;
				*dst = tmp;
				return 1;

			default:
				return 0;
		}
	}
}

___RIP_inline
int ipv6_raw_input(const char *osrc, uint64_t *dst)
{
	const unsigned char *src = (const unsigned char *)osrc;
	const unsigned char *backtrack = src;
	int ch;
	int digits = 0;
	int words = 0;
	int gap = -1;
	uint16_t word = 0;
	uint16_t tmp[8];

	if (*src == ':')
		if (*++src != ':')
			return 0;

	for (;;)
	{
		switch ((ch = *src++))
		{
			case '0': case '1': case '2': case '3': case '4':
			case '5': case '6': case '7': case '8': case '9':
				word = (word << 4) | (ch - '0');
				break;

			case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
				word = (word << 4) | ((ch - 'a') + 10);
				break;

			case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
				word = (word << 4) | ((ch - 'A') + 10);
				break;

			case ':':
				if (digits == 0)
				{
					if (gap >= 0)
						return 0;
					gap = words;
				}
				else if (!*src)
					return 0;    

				tmp[words++] = word;
				if (words > 7 && *src)
					return 0;
				backtrack = src;
				word = 0;
				digits = 0;
				continue;

			case '.':
				if (words < 1 || words > 6)
					return 0;

				{
					uint32_t ip4val;
					if (!ipv4_raw_input((const char *)backtrack, &ip4val))
						return 0;
					tmp[words++] = (ip4val >> 16);
					word = (ip4val & 0xffff);
					digits = 4;
				}

				 
			case 0:
				if (digits)
					tmp[words++] = word;
				if (words < 8)
				{
					int i,d;
					if (gap < 0)
						return 0;
					d = 8 - words;
					for (i = 7; i > gap+d; --i)
						tmp[i] = tmp[i-d];
					for (; i > gap; --i)
						tmp[i] = 0;
				}
        dst[0] = (((uint64_t)(tmp[0]) << 48) | ((uint64_t)(tmp[1]) << 32)
						  | ((uint64_t)(tmp[2]) << 16) | tmp[3]);
				dst[1] = (((uint64_t)(tmp[4]) << 48) | ((uint64_t)(tmp[5]) << 32)
						  | ((uint64_t)(tmp[6]) << 16) | tmp[7]); 
				 
				return 1;

			default:
				return 0;
		}

		if (++digits > 4)
			return 0;
	}
}

___RIP_inline
int ipv4_raw_output(uint32_t ip, char *str, int len)
{
    return snprintf(str, len, "%u.%u.%u.%u",
					(ip >> 24)&0xff, (ip >> 16)&0xff, (ip >> 8)&0xff, (ip)&0xff);
}

___RIP_inline
int ipv4_to_str(uint32_t ip, char *str, int len){
  return ipv4_raw_output(ip, str, len);
}


___RIP_inline
int ipv6_raw_output(uint64_t * ip, char *str, int len)
{
	uint16_t tmp[8];
	char buf[sizeof("ffff:ffff:ffff:ffff:ffff:ffff:255.255.255.255") + 2];
	char *ptr = buf;
	unsigned flags = (1 << 8);
	int best = -1;
	int best_len = 1;
	int best_end;
	uint16_t word;
	int i,j;
	tmp[0] = ip[0] >> 48;
	tmp[1] = ip[0] >> 32;
	tmp[2] = ip[0] >> 16;
	tmp[3] = ip[0];
	tmp[4] = ip[1] >> 48;
	tmp[5] = ip[1] >> 32;
	tmp[6] = ip[1] >> 16;
	tmp[7] = ip[1];

	for (i = 0; i < 8; ++i)
		flags |= (tmp[i] ? (1 << i) : 0);
	for (i = 0; i < 8; ++i, flags >>= 1)
		if ((flags & 1) == 0 && (ffs(flags)-1) > best_len)
			best = i, best_len = ffs(flags)-1;

	best_end = best + best_len - 1;

	if (best == 0)
	{
		if (best_len == 6
			|| (best_len == 5 && tmp[5] == 0xffff)
			|| (best_len == 4 && tmp[4] == 0xffff && tmp[5] == 0))
		{
			ipv4_raw_output(((uint32_t)(tmp[6]) << 16) | tmp[7], buf, sizeof(buf)-2);
			return snprintf(
        str, len, ":%s%s:%s"
        , (best_len != 6) ? ":ffff" : ""
        , (best_len == 4) ? ":0"    : ""
        , buf
      );
		}
		else if (best_len == 8)
			return snprintf(str, len, "::");
	}

	for (i = 0; i < 8; ++i)
	{
		if (i >= best && i <= best_end)
		{
			if (i == best_end)
				*ptr++ = ':';
			continue;
		}

		if (i > 0)
			*ptr++ = ':';

		word = tmp[i];

		if (!word)
			*ptr++ = '0';
		else
		{
			word = (word >> 8) | (word << 8);
			word = ((word & 0xf0f0) >> 4) | ((word & 0x0f0f) << 4);
			for (j = 0; j < 3; ++j, word >>= 4)
				if (word & 0xf)
					break;
			for (; j < 4; ++j, word >>= 4)
				*ptr++ = ((word & 0xf) > 9) ? ((word & 0xf) + 'a' - 10) : ((word & 0xf) + '0');
		}
	}

	if (best_end == 7)
		*ptr++ = ':';

	*ptr = 0;

	return snprintf(str, len, "%s", buf);
}

 
#if 1
 
___RIP_inline
int ipv4r_from_cidr(IPv4 prefix, unsigned masklen, IPv4r *ipr)
{
    uint32_t mask = hostmask(masklen);
    if (masklen > 32)
        return FALSE;
    if (prefix & mask)
        return FALSE;
    ipr->lo = prefix;
    ipr->hi = prefix | mask;
    return TRUE;
}
 
int
  ipv4r_from_str(char *str, IPv4r *ipr)
{
    char buf[IP4_STRING_SZMAX];
    int pos = strcspn(str, "-/");
    IPv4 ip;

    switch (str[pos])
    {
        case 0:      
        {
            if (!ipv4_raw_input(str, &ip))
                return FALSE;
            ipr->lo = ip;
            ipr->hi = ip;
            return 1;
        }

        case '-':    
        {
            char *rest = str + pos + 1;

            if (pos >= sizeof(buf))
                return 0;
            memcpy(buf, str, pos);
            buf[pos] = 0;
             
            if (!ipv4_raw_input(buf, &ip))
                return 0;
             
            ipr->lo = ip;
             
            if (!ipv4_raw_input(rest, &ip))
                return 0;
             
            if (!Ripaddr_ipv4_cmp_lt(ip, ipr->lo))
                ipr->hi = ip;
            else  
            {
                ipr->hi = ipr->lo;
                ipr->lo = ip;
            }
            return 1;
        }

        case '/':   
        {
            char *rest = str + pos + 1;
            unsigned pfxlen;
            char dummy;

            if (pos >= sizeof(buf))
                return FALSE;
            memcpy(buf, str, pos);
            buf[pos] = 0;
             
            if(
              pos==3  
            ){
                int valid = sscanf(buf,"%u",&ip);
                 
                if( !valid ) return FALSE;
                ip <<= 24;
            }
            else if (!ipv4_raw_input(buf, &ip)){
                return FALSE;
            }
            if (rest[strspn(rest,"0123456789")])
                return FALSE;
            if (sscanf(rest, "%u%c", &pfxlen, &dummy) != 1)
                return FALSE;
            return ipv4r_from_cidr(ip, pfxlen, ipr);
        }

        default:
            return FALSE;       
    }
}
 
___RIP_inline
int ipv4r_raw_input( const char *str, IPv4r *ipr){
   
  return ipv4r_from_str( (char *) str, ipr);
}

 
___RIP_inline
int ipv4r_to_str(IPv4 *ipr, char *str, int slen)
{
    char buf1[IP4_STRING_SZMAX];
    char buf2[IP4_STRING_SZMAX];
    unsigned msk;

    if (Ripaddr_ipv4_cmp_eq(ipr[0], ipr[1]))
        return ipv4_raw_output(ipr[0], str, slen);

    if ((msk = masklen(ipr[0],ipr[1])) <= 32)
    {
        ipv4_raw_output(ipr[0], buf1, sizeof(buf1));
        return snprintf(str, slen, "%s/%u", buf1, msk);
    }

    ipv4_raw_output(ipr[0], buf1, sizeof(buf1));
    ipv4_raw_output(ipr[1], buf2, sizeof(buf2));

    return snprintf(str, slen, "%s-%s", buf1, buf2);
}
 
#endif

#if 1
 
___RIP_inline
int
    ipv6r_from_cidr(IPv6 *prefix, unsigned masklen, IPv6r *ipr)
{
    uint64_t mask_lo = ipv6_hostmask_lo(masklen);
    uint64_t mask_hi = ipv6_hostmask_hi(masklen);
    if (masklen > 128)
        return 0;

    if (
      (prefix->ipv6[0] & mask_hi) || (prefix->ipv6[1] & mask_lo)
       
    ){
      return 0;
    }
    ipr->hi.ipv6[0] = (prefix->ipv6[0] | mask_hi);
    ipr->hi.ipv6[1] = (prefix->ipv6[1] | mask_lo);
    ipr->lo    = *prefix;
    return 1;
}
 
int
    ipv6r_from_str(char *str, IPv6r *ipr)
{
    char buf[IPv6r_STRING_SZMAX];
    int pos = strcspn(str, "-/");
    IPv6 ip;

    switch (str[pos])
    {
        case 0:      
        {
            if (!ipv6_raw_input(str, ip.ipv6))
                return FALSE;
            ipr->lo = ip;
            ipr->hi = ip;
            return TRUE;
        }

        case '-':    
        {
            char *rest = str + pos + 1;

            if (pos > sizeof(buf)-2)
                return FALSE;
            memcpy(buf, str, pos);
            buf[pos] = 0;
            if (!ipv6_raw_input(buf, ip.ipv6))
                return FALSE;
            ipr->lo = ip;
            if (!ipv6_raw_input(rest, ip.ipv6))
                return FALSE;
             
            if (
                !Ripaddr_ipv6_cmp_lt((uint64_t*) &ip, (uint64_t*) &ipr->lo)
            ){
                ipr->hi = ip;
            }else
            {
                ipr->hi = ipr->lo;
                ipr->lo = ip;
            }
            return TRUE;
        }

        case '/':   
        {
            char *rest = str + pos + 1;
            unsigned pfxlen;
            char dummy;
            if (pos > sizeof(buf)-2)
                return FALSE;
            memcpy(buf, str, pos);
            buf[pos] = 0;
 
            if (!ipv6_raw_input(buf, ip.ipv6))
                return FALSE;
            if (rest[strspn(rest,"0123456789")])
                return FALSE;
            if (sscanf(rest, "%u%c", &pfxlen, &dummy) != 1)
                return FALSE;
 
            return ipv6r_from_cidr(&ip, pfxlen, ipr);
        }

        default:
            return FALSE;       
    }
}
 
___RIP_inline
int ipv6r_raw_input( const char *str, IPv6r *ipr){
   
  return ipv6r_from_str( (char *) str, ipr);
}

___RIP_inline
int ipv6r_to_str(IPv6r *ipr, char *str, int slen)
{
    char buf1[IPv6_STRING_SZMAX+10];
    char buf2[IPv6_STRING_SZMAX+10];
    unsigned msk;

    if (Ripaddr_ipv6_cmp_eq((uint64_t*)&ipr->lo, (uint64_t*)&ipr->hi))
        return ipv6_raw_output((uint64_t*)&ipr->lo, str, slen);

    if (
        (msk = ipv6_masklen(&ipr->lo,&ipr->hi)) <= 128
    ){
        ipv6_raw_output((uint64_t*)&ipr->lo, buf1, sizeof(buf1));
        return snprintf(str, slen, "%s/%u", buf1, msk);
    }
     
    ipv6_raw_output((uint64_t*)&ipr->lo, buf1, sizeof(buf1));
    ipv6_raw_output((uint64_t*)&ipr->hi, buf2, sizeof(buf2));
     
    return snprintf(str, slen, "%s-%s", buf1, buf2);
}
 
___RIP_inline
int ipv6r_raw_output(IPv6r *ipr, char *str, int slen){
   
  return ipv6r_to_str( ipr, (char *) str, slen);
}
#endif
