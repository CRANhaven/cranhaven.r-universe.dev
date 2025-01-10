 

#include "Rip.h"

 
#define RIP_OP2_IP_IP(___IPv__, ___group__, ___opname__,  ___fn__) \
SEXP Rip_ip##___IPv__##_op2_##___group__##_##___opname__##_0( \
    SEXP Rip1, SEXP Rip2\
){ \
  SEXP Res;  \
  int nprotected=0, nip=0, i,i1,i2, dbg=0;   \
  RIP##___IPv__##_SLOTS_GET( Rip1 ) \
  RIP##___IPv__##_SLOTS_GET( Rip2 ) \
  nip = Rip1_nip > Rip2_nip ? Rip1_nip : Rip2_nip; \
    \
   \
  RIP##___IPv__##_RIP_ALLOC(Res,nip)  \
  Res_nip+=0; \
  RIP_BEGIN \
  RIP_ITERATE_STEP(nip, Rip1_nip, Rip2_nip){ \
 \
    if(  \
         ( Rip1_ip_idxptr[i1]==NA_INTEGER )  \
      || ( Rip2_ip_idxptr[i2]==NA_INTEGER ) \
    ){ \
      Res_ip_idxptr[i] = NA_INTEGER; \
        \
      continue; \
    } \
    RIP_CHECK_IDX(Rip1##_ip_idxptr, i1, nip) \
    RIP_CHECK_IDX(Rip2##_ip_idxptr, i2, nip) \
    RIP##___IPv__##_ELT_PTR_DCL(Rip1, i1) \
    RIP##___IPv__##_ELT_PTR_DCL(Rip2, i2) \
    RIP##___IPv__##_RES_DCL(res) \
    resptr = ___fn__(  \
       Rip1_ip_elt_ptr \
       , Rip2_ip_elt_ptr  \
       , resptr \
    ); \
    RIP##___IPv__##_ITER_SET( Res, i, res) \
  } \
  RIP_END \
  RIP##___IPv__##_IS_NA_WARN_REPROTECT( Res, nip, "bool" ) \
  RIP##___IPv__##_SLOTS_SET( Res ) \
    \
  UNPROTECT(nprotected); \
  return Res; \
}
 
#define RIP_OP2_MASK(___IPv__, ___opname__,  ___fn__) \
  RIP_OP2_IP_IP(___IPv__, mask, ___opname__,  ___fn__) \

uint64_t ipv6_hostmask_hi(unsigned masklen)
{
    if (masklen >= 64)
        return 0;
    if (masklen == 0)
        return ~((uint64_t)0);
    return (((uint64_t)(1U)) << (64-masklen)) - 1U;
}
 
uint64_t ipv6_hostmask_lo(unsigned masklen)
{
    if (masklen <= 64)
        return ~((uint64_t)0);
    return (((uint64_t)(1U)) << (128-masklen)) - 1U;
}
 
uint64_t ipv6_netmask_hi(unsigned masklen)
{
    return ~ipv6_hostmask_hi(masklen);
}
 
uint64_t ipv6_netmask_lo(unsigned masklen)
{
    return ~ipv6_hostmask_lo(masklen);
}
 
 
unsigned ipv6_masklen64(uint64_t lo, uint64_t hi, int offset)
{
    uint64_t d = (lo ^ hi) + 1;
    int t = 0;
    int b;

     
    if (d == 0)
        return (lo == 0 && hi == ~((uint64_t)0)) ? offset : ~0;
    if (d == 1)
        return (lo == hi) ? 64+offset : ~0;

    if (!(d & 0xFFFFFFFFUL))
    {
        t = 32;
        d >>= 32;
    }
    b = ffs((uint32_t) d);
    if ((((uint32_t)1U) << (b-1)) != d)
        return ~0;

    {
        uint64_t mask = ((uint64_t)(1U) << (t+b-1)) - 1U;
        if ((lo & mask) == 0 && (hi & mask) == mask)
            return 65-t-b + offset;
    }

    return ~0;
}
 
unsigned ipv6_masklen(IPv6 *lo, IPv6 *hi)
{
    if (lo->ipv6[0] == hi->ipv6[0])      
    {
        return ipv6_masklen64(lo->ipv6[1], hi->ipv6[1], 64);
    }
    else                                 
    {
        if (lo->ipv6[1] != 0 || hi->ipv6[1] != ~((uint64_t)0))
            return ~0U;
        return ipv6_masklen64(lo->ipv6[0], hi->ipv6[0], 0);
    }
}
 
 
int ipv6_valid_netmask(uint64_t maskhi, uint64_t masklo)
{
    uint64_t d;
    int fbit;

    if (maskhi == ~((uint64_t)0))
        d = ~masklo + 1;
    else if (masklo == 0)
        d = ~maskhi + 1;
    else
        return FALSE;

    if (!(d & 0xFFFFFFFFUL))
        d >>= 32;
    if (!d)
        return TRUE;

    fbit = ffs((uint32_t)d);
    return ((uint32_t)(1U) << (fbit-1)) == d;
}

___RIP_inline
IPv4*
  Rippaddr_ipv4_and(
    IPv4 ip1, IPv4 ip2, IPv4 *res
){
 *res = ip1 & ip2;
  return res;
}
 
RIP_OP2_MASK(v4, and, Rippaddr_ipv4_and)
 
 
___RIP_inline
uint64_t *
  Rippaddr_ipv6_and(
    uint64_t* ip1, uint64_t* ip2, uint64_t* res
){
  res[0] = ip1[0] & ip2[0];
  res[1] = ip1[1] & ip2[1];
  return res;
}
 
RIP_OP2_MASK(v6, and, Rippaddr_ipv6_and)

___RIP_inline
IPv4*
  Rippaddr_ipv4_or(
    IPv4 ip1, IPv4 ip2, IPv4 *res
){
 *res = ip1 | ip2;
  return res;
}
 
 
RIP_OP2_MASK(v4, or, Rippaddr_ipv4_or)

 
___RIP_inline
uint64_t *
  Rippaddr_ipv6_or(
    uint64_t* ip1, uint64_t* ip2, uint64_t* res
){
  res[0] = ip1[0] | ip2[0];
  res[1] = ip1[1] | ip2[1];
  return res;
}
 
RIP_OP2_MASK(v6, or, Rippaddr_ipv6_or)

___RIP_inline
IPv4*
  Rippaddr_ipv4_xor(
    IPv4 ip1, IPv4 ip2, IPv4 *res
){
 *res = ip1 ^ ip2;
  return res;
}
 
RIP_OP2_MASK(v4, xor, Rippaddr_ipv4_xor)
 
 
___RIP_inline
uint64_t *
  Rippaddr_ipv6_xor(
    uint64_t* ip1, uint64_t* ip2, uint64_t* res
){
  res[0] = ip1[0] ^ ip2[0];
  res[1] = ip1[1] ^ ip2[1];
  return res;
}
 
RIP_OP2_MASK(v6, xor, Rippaddr_ipv6_xor)

