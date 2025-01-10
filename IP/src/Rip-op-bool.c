 

 
#include "Rip.h"

___RIP_inline
int 
  Ripaddr_ipv4_cmp_eq(
    IPv4 ip1, IPv4 ip2
){
   
  return ip1 == ip2;
}
 
 
RIP_OP2_BOOL(v4, eq, Ripaddr_ipv4_cmp_eq)
 
 
RIP_OP2_BOOL_1(v4cache, v4cache, eq, Ripaddr_ipv4_cmp_eq)
 
RIP_OP2_BOOL_1(v4cache, v4, eq, Ripaddr_ipv4_cmp_eq)

___RIP_inline
int 
  Ripaddr_ipv4r_cmp_eq(
    IPv4 *ip1, IPv4 *ip2
){
   
   
  return ( ip1[0] == ip2[0] ) & ( ip1[1] == ip2[1] );
}
 
RIP_OP2_BOOL(v4r, eq, Ripaddr_ipv4r_cmp_eq)
 
 
___RIP_inline
int 
  Ripaddr_ipv6_cmp_eq(
  uint64_t *ip1, uint64_t *ip2
){
   
  return (ip1[0] == ip2[0]) && (ip1[1] == ip2[1]);
}
 
RIP_OP2_BOOL(v6, eq, Ripaddr_ipv6_cmp_eq)
 
 
___RIP_inline
int 
  Ripaddr_ipv6r_cmp_eq(
    IPv6r *ip1, IPv6r *ip2
){
   
  return Ripaddr_ipv6_cmp_eq(
      (uint64_t *) &ip1->lo, (uint64_t *) &ip2->lo
    ) && Ripaddr_ipv6_cmp_eq(
      (uint64_t *) &ip1->hi, (uint64_t *) &ip2->hi
  );
} 
 
RIP_OP2_BOOL(v6r, eq, Ripaddr_ipv6r_cmp_eq)

___RIP_inline
int 
  Ripaddr_ipv4_cmp_neq(
    IPv4 ip1, IPv4 ip2
){
   
  return ip1 != ip2;
}
 
RIP_OP2_BOOL(v4, neq, Ripaddr_ipv4_cmp_neq)
 
 
___RIP_inline
int 
  Ripaddr_ipv4r_cmp_neq(
    IPv4 *ip1, IPv4 *ip2
){
   
   
  return ( ip1[0] != ip2[0] ) | ( ip1[1] != ip2[1] );
}
 
RIP_OP2_BOOL(v4r, neq, Ripaddr_ipv4r_cmp_neq)
 
 
___RIP_inline
int 
  Ripaddr_ipv6_cmp_neq(
  uint64_t *ip1, uint64_t *ip2
){
   
  return (ip1[0] != ip2[0]) | (ip1[1] != ip2[1]);
}
 
RIP_OP2_BOOL(v6, neq, Ripaddr_ipv6_cmp_neq)
 
 
___RIP_inline
int 
  Ripaddr_ipv6r_cmp_neq(
    IPv6r *ip1, IPv6r *ip2
){
   
  return Ripaddr_ipv6_cmp_neq(
      (uint64_t *) &ip1->lo, (uint64_t *) &ip2->lo
    ) | Ripaddr_ipv6_cmp_neq(
      (uint64_t *) &ip1->hi, (uint64_t *) &ip2->hi
  );
} 
 
RIP_OP2_BOOL(v6r, neq, Ripaddr_ipv6r_cmp_neq)

___RIP_inline
int 
  Ripaddr_ipv4_cmp_lt(
    IPv4 ip1, IPv4 ip2
){
 
   
  return ip1 < ip2;
}
 
RIP_OP2_BOOL(v4, lt, Ripaddr_ipv4_cmp_lt)
 
 
___RIP_inline
int 
  Ripaddr_ipv4r_cmp_lt(
    IPv4 *ip1, IPv4 *ip2
){
   
  return ( 
    ( ip1[0] < ip2[0] )
    || ( ( ip1[0] == ip2[0] ) && ( ip1[1] < ip2[1] ) ) 
     
     
  );
}
 
RIP_OP2_BOOL(v4r, lt, Ripaddr_ipv4r_cmp_lt)

___RIP_inline
int 
  Ripaddr_ipv6_cmp_lt(
    uint64_t *ip1, uint64_t *ip2
){
 
   
  return ( 
    ( ip1[0] < ip2[0] )
    || ( ( ip1[0] == ip2[0] ) && ( ip1[1] < ip2[1] ) ) 
  );

}
 
RIP_OP2_BOOL(v6, lt, Ripaddr_ipv6_cmp_lt)

___RIP_inline
int 
  Ripaddr_ipv6r_cmp_lt(
    IPv6r *ip1, IPv6r *ip2
){
   
  return ( 
    Ripaddr_ipv6_cmp_lt(  
      (uint64_t *) &ip1->lo, (uint64_t *) &ip2->lo
    )
    || (  
      Ripaddr_ipv6_cmp_eq( 
        (uint64_t *) &ip1->lo, (uint64_t *) &ip2->lo
      ) 
      && Ripaddr_ipv6_cmp_lt( 
        (uint64_t *) &ip1->hi, (uint64_t *) &ip2->hi
      )
    ) 
  );
}
 
RIP_OP2_BOOL(v6r, lt, Ripaddr_ipv6r_cmp_lt)

___RIP_inline
int 
  Ripaddr_ipv4_cmp_le(
    IPv4 ip1, IPv4 ip2
){
   
  return ip1 <= ip2;
}
 
RIP_OP2_BOOL(v4, le, Ripaddr_ipv4_cmp_le)
 
 
___RIP_inline
int 
  Ripaddr_ipv4r_cmp_le(
    IPv4 *ip1, IPv4 *ip2
){
  return ( 
    ( ip1[0] <= ip2[0] )
    && ( ( ip1[1] <= ip2[1] )  ) 
  );

}
 
RIP_OP2_BOOL(v4r, le, Ripaddr_ipv4r_cmp_le)
 
 
___RIP_inline
int 
  Ripaddr_ipv6_cmp_le(
  uint64_t *ip1, uint64_t *ip2
){

  return !Ripaddr_ipv6_cmp_gt(ip1,ip2);
}
 
RIP_OP2_BOOL(v6, le, Ripaddr_ipv6_cmp_le)
 
 
___RIP_inline
int 
  Ripaddr_ipv6r_cmp_le(
    IPv6r *ip1, IPv6r *ip2
){
   
  return ( 
    Ripaddr_ipv6_cmp_le( (uint64_t *) &ip1->hi, (uint64_t *) &ip2->hi)  
    || ( 
      Ripaddr_ipv6_cmp_eq( (uint64_t *) &ip1->hi, (uint64_t *) &ip2->hi
    ) && Ripaddr_ipv6_cmp_le( 
      (uint64_t *) &ip1->lo, (uint64_t *) &ip2->lo)
    )  
  );
}
 
RIP_OP2_BOOL(v6r, le, Ripaddr_ipv6r_cmp_le)

___RIP_inline
int 
  Ripaddr_ipv4_cmp_ge(
    IPv4 ip1, IPv4 ip2
){
   
  return ip1 >= ip2;
}
 
RIP_OP2_BOOL(v4, ge, Ripaddr_ipv4_cmp_ge)
 
 
___RIP_inline
int 
  Ripaddr_ipv4r_cmp_ge(
    IPv4 *ip1, IPv4 *ip2
){
   
  return ( 
    ( ip1[0] >= ip2[0] )
    && ( ( ip1[1] >= ip2[1] ) ) 
  );

}
 
RIP_OP2_BOOL(v4r, ge, Ripaddr_ipv4r_cmp_ge)
 
 
___RIP_inline
int 
  Ripaddr_ipv6_cmp_ge(
  uint64_t *ip1, uint64_t *ip2
){
   
  return !Ripaddr_ipv6_cmp_lt(ip1,ip2);
}
 
RIP_OP2_BOOL(v6, ge, Ripaddr_ipv6_cmp_ge)
 
 
___RIP_inline
int 
  Ripaddr_ipv6r_cmp_ge(
    IPv6r *ip1, IPv6r *ip2
){
   
  return !Ripaddr_ipv6r_cmp_lt(ip1,ip2);
}
 
RIP_OP2_BOOL(v6r, ge, Ripaddr_ipv6r_cmp_ge)

___RIP_inline
int 
  Ripaddr_ipv4_cmp_gt(
    IPv4 ip1, IPv4 ip2
){
   
  return ip1 > ip2;
}
 
RIP_OP2_BOOL(v4, gt, Ripaddr_ipv4_cmp_gt)
 
 
___RIP_inline
int 
  Ripaddr_ipv4r_cmp_gt(
    IPv4 *ip1, IPv4 *ip2
){
   
  return ( 
    ( ip1[0] > ip2[0] )
    || ( ( ip1[0] == ip2[0] ) && ( ip1[1] > ip2[1] ) )
     
     
  );
}
 
RIP_OP2_BOOL(v4r, gt, Ripaddr_ipv4r_cmp_gt)

___RIP_inline
int 
  Ripaddr_ipv6_cmp_gt(
  uint64_t *ip1, uint64_t *ip2
){
#if 0
   
  return !Ripaddr_ipv6_cmp_lt(ip1,ip2) & !Ripaddr_ipv6_cmp_eq(ip1,ip2);
#else
   
  return ( 
    ( ip1[0] > ip2[0] )
    || ( ( ip1[0] == ip2[0] ) && ( ip1[1] > ip2[1] ) ) 
  );
#endif
}
 
RIP_OP2_BOOL(v6, gt, Ripaddr_ipv6_cmp_gt)
 
 
___RIP_inline
int 
  Ripaddr_ipv6r_cmp_gt(
    IPv6r *ip1, IPv6r *ip2
){
   
  return ( 
#if 1
    Ripaddr_ipv6_cmp_gt(  
      (uint64_t *) &ip1->lo, (uint64_t *) &ip2->lo
    )
    || (  
      Ripaddr_ipv6_cmp_eq( 
      (uint64_t *) &ip1->lo, (uint64_t *) &ip2->lo
    ) && Ripaddr_ipv6_cmp_gt( 
      (uint64_t *) &ip1->hi, (uint64_t *)  &ip2->hi)
    )
#else
    Ripaddr_ipv6_cmp_gt( 
      (uint64_t *) &ip1->hi, (uint64_t *) &ip2->hi
    )  
    || ( 
      Ripaddr_ipv6_cmp_eq( 
      (uint64_t *) &ip1->hi, (uint64_t *) &ip2->hi
    ) && Ripaddr_ipv6_cmp_gt( 
      (uint64_t *) &ip1->lo, (uint64_t *)  &ip2->lo)
    )  
#endif
  );
}
 
 
RIP_OP2_BOOL(v6r, gt, Ripaddr_ipv6r_cmp_gt)

#if __RIP_AVX512__ 

___RIP_inline __mmask16
  Ripaddr_ipv4rx16_cmp_eq_mask(
    __m512i vip1_lo, __m512i vip1_hi, __m512i vip2_lo, __m512i vip2_hi
){
   
  return
    _mm512_cmpeq_epi32_mask(vip1_lo, vip2_lo) & _mm512_cmpeq_epi32_mask(vip1_hi, vip2_hi)  
  ;
}
 
 
___RIP_inline __mmask16
  Ripaddr_ipv4rx16_cmp_lt_mask(
    __m512i vip1_lo, __m512i vip1_hi, __m512i vip2_lo, __m512i vip2_hi
){
#if 0
   
  __mmask16 hi_lt = _mm512_cmplt_epu32_mask( vip1_hi, vip2_hi );
   
  __mmask16 hi_eq = _mm512_cmpeq_epu32_mask( vip1_hi, vip2_hi );
   
  __mmask16 lo_lt = _mm512_cmplt_epu32_mask( vip1_lo, vip2_lo );
   
  return
   hi_lt | ( hi_eq & lo_lt )
  ;
#else
   
  __mmask16 hi_lt = _mm512_cmplt_epu32_mask( vip1_hi, vip2_hi );
   
  __mmask16 lo_lt = _mm512_cmplt_epu32_mask( vip1_lo, vip2_lo );
   
  return
   hi_lt | ( ~hi_lt & lo_lt )
  ;
#endif
}
 
 
___RIP_inline __mmask16
  Ripaddr_ipv4rx16_cmp_gt_mask(
    __m512i vip1_lo, __m512i vip1_hi, __m512i vip2_lo, __m512i vip2_hi
){
   
  __mmask16 hi_gt = _mm512_cmpgt_epu32_mask( vip1_hi, vip2_hi );
   
  __mmask16 hi_eq = _mm512_cmpeq_epu32_mask( vip1_hi, vip2_hi );
   
  __mmask16 lo_gt = _mm512_cmplt_epu32_mask( vip1_lo, vip2_lo );
   
  return
   hi_gt | ( hi_eq & lo_gt )
  ;
}

___RIP_inline __mmask8
  Ripaddr_ipv6x8_cmp_eq_mask(
    __m512i vip1_lo, __m512i vip1_hi, __m512i vip2_lo, __m512i vip2_hi
){
   
  return
    _mm512_cmpeq_epi64_mask(vip1_lo, vip2_lo) & _mm512_cmpeq_epi64_mask(vip1_hi, vip2_hi)  
  ;
}
 
 
___RIP_inline __mmask8
  Ripaddr_ipv6x8_cmp_gt_mask(
    __m512i vip1_lo, __m512i vip1_hi, __m512i vip2_lo, __m512i vip2_hi
){
#if 0
   
  __mmask8 hi_gt = _mm512_cmpgt_epu64_mask( vip1_hi, vip2_hi );
   
  __mmask8 hi_eq = _mm512_cmpeq_epu64_mask( vip1_hi, vip2_hi );
   
  __mmask8 lo_gt = _mm512_cmpgt_epu64_mask( vip1_lo, vip2_lo );
   
  return
   hi_gt | ( hi_eq & lo_gt )
  ;
#else
   
  __mmask8 hi_gt = _mm512_cmpgt_epu64_mask( vip1_hi, vip2_hi );
   
  __mmask8 lo_gt = _mm512_cmpgt_epu64_mask( vip1_lo, vip2_lo );
   
  return
   hi_gt | ( ~hi_gt & lo_gt )
  ;
#endif
}

#if 1  
 
#define ___IP_VERSION__      v4
#define ___IP_VERSION_NUM__  40
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  _mm512_cmpeq_epi32_mask( ___x__##_vip, ___y__##_vip)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_eq
 
SEXP Rip_ipv4_op2_bool_eq_3( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-avx512-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  _mm512_cmplt_epu32_mask( ___x__##_vip, ___y__##_vip)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_lt
 
SEXP Rip_ipv4_op2_bool_lt_3( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-avx512-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  _mm512_cmpgt_epu32_mask( ___x__##_vip, ___y__##_vip)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_gt
 
SEXP Rip_ipv4_op2_bool_gt_3( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-avx512-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 

#undef ___IP_VERSION__   
#undef ___IP_VERSION_NUM__ 
 
#endif  

#if 1  
 
#define ___IP_VERSION__      v4r
#define ___IP_VERSION_NUM__  41
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv4rx16_cmp_eq_mask( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4r_cmp_eq
 
SEXP Rip_ipv4r_op2_bool_eq_3( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-avx512-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 

#undef ___IP_VERSION__   
#undef ___IP_VERSION_NUM__   
 
#endif  

#if 1  
 
#define ___IP_VERSION__      v6
#define ___IP_VERSION_NUM__  60

#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6x8_cmp_eq_mask( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)

#define ___SCALAR_Fn__     Ripaddr_ipv6_cmp_eq
 
SEXP Rip_ipv6_op2_bool_eq_3( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-avx512-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6x8_cmp_gt_mask( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)

#define ___SCALAR_Fn__     Ripaddr_ipv6_cmp_gt
 
SEXP Rip_ipv6_op2_bool_gt_3( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-avx512-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 

#undef ___IP_VERSION__   
#undef ___IP_VERSION_NUM__   
 
#endif  

#endif  

#ifdef __RIP_AVX2__
 
 
#if 0  

#endif  
 
 
#if 1
 
 
#if 1
 
 
___RIP_inline __m256i bitmask_unpack_bool0(int ___bitmask__){
   
  const unsigned long long bitmask_bool_selmask = 0x8080808080808080;  \
  const __m256i bitmask_bool_shuffle = _mm256_set_epi8( \
       15, 15,  15,  15, \
       14, 14,  14,  14, \
        5,  5,   5,   5, \
        4,  4,   4,   4, \
       11, 11,  11,  11, \
       10, 10,  10,  10, \
        1,  1,   1,   1, \
        0,  0,   0,   0 \
  );
  unsigned long long bitmask1 = _pdep_u64(___bitmask__, bitmask_bool_selmask);
 
  __m256i b = _mm256_shuffle_epi8(_mm256_set1_epi64x( bitmask1 ), bitmask_bool_shuffle);

  b = _mm256_srli_epi32( b, 31);

  return b;
}

#endif 
 
 
___RIP_inline
__mmask8  
  _mm256_i32x8_cmp_eq_mask(
    __m256i x, __m256i y
){
   
  return _mm256_movemask_ps(
    _mm256_castsi256_ps( _mm256_cmpeq_epi32( x, y ) )
  );
}
 
 
___RIP_inline
int
  _mm256_i32x8_cmp_neq_mask(
    __m256i x, __m256i y
){
   
  return ~_mm256_i32x8_cmp_eq_mask( x, y );
}
 
 
___RIP_inline
__mmask8
  _mm256_u32x8_cmp_gt_mask(
    __m256i x, __m256i y
){
   
  int x_sign = _mm256_movemask_ps(
   _mm256_castsi256_ps(x)
  );
   
  int y_sign = _mm256_movemask_ps(
   _mm256_castsi256_ps(y)
  );
   
  int sign = x_sign ^ y_sign;
   
  int gt = _mm256_movemask_ps(
    _mm256_castsi256_ps(_mm256_cmpgt_epi32( x, y ) )
  );
   
  return sign^gt;
}
 
 
___RIP_inline
__mmask8
  _mm256_u32x8_cmp_lt_mask(
    __m256i x, __m256i y
){
   
  return ~(_mm256_i32x8_cmp_eq_mask(x, y) | _mm256_u32x8_cmp_gt_mask(x, y) );
}
 
 
___RIP_inline
__mmask8
  _mm256_u32x8_cmp_le_mask(
    __m256i x, __m256i y
){
   
  return ~(  _mm256_u32x8_cmp_gt_mask(x, y) );
}
 
___RIP_inline
__mmask8
  _mm256_u32x8_cmp_ge_mask(
    __m256i x, __m256i y
){
   
  return (_mm256_i32x8_cmp_eq_mask(x, y) | _mm256_u32x8_cmp_gt_mask(x, y) );
}

___RIP_inline
__mmask8
  Ripaddr_ipv4rx8_cmp_eq_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  return
    _mm256_i32x8_cmp_eq_mask(vip1_lo, vip2_lo) & _mm256_i32x8_cmp_eq_mask(vip1_hi, vip2_hi)  
  ;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv4rx8_cmp_neq_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  return
    ~Ripaddr_ipv4rx8_cmp_eq_mask0(vip1_lo, vip1_hi, vip2_lo, vip2_hi)  
  ;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv4rx8_cmp_lt_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
#if 1
   
  int lo_lt = ~_mm256_u32x8_cmp_gt_mask( vip1_lo, vip2_lo );
   
  int lo_eq = _mm256_movemask_ps(
    _mm256_castsi256_ps( _mm256_cmpeq_epi32( vip1_lo, vip2_lo ) )
  );
   
  lo_lt = lo_lt ^ lo_eq;
   
  int hi_lt = ~_mm256_u32x8_cmp_gt_mask( vip1_hi, vip2_hi );
   
  int hi_eq = _mm256_movemask_ps(
    _mm256_castsi256_ps( _mm256_cmpeq_epi32( vip1_hi, vip2_hi ) )
  );
   
  hi_lt = hi_lt ^ hi_eq;
   
  return
    lo_lt | ( lo_eq & hi_lt )
  ;
#else
   
  int hi_lt = ~_mm256_u32x8_cmp_gt_mask( vip1_hi, vip2_hi );
   
  int hi_eq = _mm256_movemask_ps(
    _mm256_castsi256_ps( _mm256_cmpeq_epi32( vip1_hi, vip2_hi ) )
  );
   
  hi_lt = hi_lt ^ hi_eq;
   
  int lo_lt = ~_mm256_u32x8_cmp_gt_mask( vip1_lo, vip2_lo );
   
  int lo_eq = _mm256_movemask_ps(
    _mm256_castsi256_ps( _mm256_cmpeq_epi32( vip1_lo, vip2_lo ) )
  );
   
  lo_lt = lo_lt ^ lo_eq;
   
  return
    hi_lt | ( hi_eq & lo_lt )
  ;
#endif
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv4rx8_cmp_gt_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  int lo_gt = _mm256_u32x8_cmp_gt_mask( vip1_lo, vip2_lo );
   
  int lo_eq = _mm256_movemask_ps(
    _mm256_castsi256_ps( _mm256_cmpeq_epi32( vip1_lo, vip2_lo ) )
  );
   
  int hi_gt = _mm256_u32x8_cmp_gt_mask( vip1_hi, vip2_hi );
   
  return
    lo_gt | ( lo_eq & hi_gt )
  ;
}

___RIP_inline
__mmask8
  Ripaddr_ipv4rx8_cmp_le_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  __mmask8 lo_le = ~_mm256_u32x8_cmp_gt_mask( vip1_lo, vip2_lo );

  __mmask8 hi_le = ~_mm256_u32x8_cmp_gt_mask( vip1_hi, vip2_hi );
   
  return
    lo_le  & hi_le 
     
  ;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv4rx8_cmp_ge_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  __mmask8 lo_ge = _mm256_u32x8_cmp_gt_mask( vip1_lo, vip2_lo );
   
  __mmask8 lo_eq = _mm256_i32x8_cmp_eq_mask( vip1_lo, vip2_lo );
   
  lo_ge |= lo_eq;
   
  __mmask8 hi_ge = _mm256_u32x8_cmp_gt_mask( vip1_hi, vip2_hi ) | _mm256_i32x8_cmp_eq_mask( vip1_hi, vip2_hi );
   
  return
    lo_ge & hi_ge 
     
  ;
}

___RIP_inline
__mmask8
  _mm256_i64x4_cmp_eq_mask(
    __m256i x, __m256i y
){
  return _mm256_movemask_pd(
    _mm256_castsi256_pd( _mm256_cmpeq_epi64( x, y ) )
  );
}
 
 
___RIP_inline
__mmask8
  _mm256_u64x4_cmp_gt_mask(
    __m256i x, __m256i y
){
   
  int x_sign = _mm256_movemask_pd(
   _mm256_castsi256_pd(x)
  );
   
  int y_sign = _mm256_movemask_pd(
   _mm256_castsi256_pd(y)
  );
   
  int sign = x_sign ^ y_sign;
   
  int gt = _mm256_movemask_pd(
    _mm256_castsi256_pd(_mm256_cmpgt_epi64( x, y ) )
  );
   
  return sign^gt;
}

___RIP_inline
__mmask8
  Ripaddr_ipv6x4_cmp_eq_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  return
    _mm256_i64x4_cmp_eq_mask(vip1_lo, vip2_lo) & _mm256_i64x4_cmp_eq_mask(vip1_hi, vip2_hi)  
  ;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv6x4_cmp_neq_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  return
    ~Ripaddr_ipv6x4_cmp_eq_mask0(vip1_lo, vip1_hi, vip2_lo, vip2_hi)  
  ;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv6x4_cmp_gt_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){

  int hi_gt = _mm256_u64x4_cmp_gt_mask( vip1_hi, vip2_hi );
   
  int hi_eq = _mm256_movemask_pd(
    _mm256_castsi256_pd( _mm256_cmpeq_epi64( vip1_hi, vip2_hi ) )
  );

  int lo_gt = _mm256_u64x4_cmp_gt_mask( vip1_lo, vip2_lo );
   
  return
    hi_gt | ( hi_eq & lo_gt )
  ;
}
 
___RIP_inline
__mmask8
  Ripaddr_ipv6x4_cmp_lt_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){

  int hi_lt = ~_mm256_u64x4_cmp_gt_mask( vip1_hi, vip2_hi );
   
  int hi_eq = _mm256_movemask_pd(
    _mm256_castsi256_pd( _mm256_cmpeq_epi64( vip1_hi, vip2_hi ) )
  );
   
  hi_lt = hi_lt ^ hi_eq;
   
   
  int lo_lt = ~_mm256_u64x4_cmp_gt_mask( vip1_lo, vip2_lo );
   
  int lo_eq = _mm256_movemask_pd(
    _mm256_castsi256_pd( _mm256_cmpeq_epi64( vip1_lo, vip2_lo ) )
  );
   
  lo_lt = lo_lt ^ lo_eq;
   
  return
    hi_lt | ( hi_eq & lo_lt )
  ;
}

___RIP_inline
__mmask8
  Ripaddr_ipv6x4_cmp_le_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
#if 0  
   
  __mmask8 hi_le = ~_mm256_u64x4_cmp_gt_mask( vip1_hi, vip2_hi );
   
  __mmask8 hi_eq = _mm256_i64x4_cmp_eq_mask( vip1_hi, vip2_hi );
   
  __mmask8 lo_le = ~_mm256_u64x4_cmp_gt_mask( vip1_lo, vip2_lo );
   
  return
    hi_le | ( hi_eq & lo_le )
  ;
#else
  return ~Ripaddr_ipv6x4_cmp_gt_mask0(vip1_lo, vip1_hi, vip2_lo, vip2_hi);
#endif
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv6x4_cmp_ge_mask0(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
#if 0  
   
  __mmask8 hi_ge = _mm256_u64x4_cmp_gt_mask( vip1_hi, vip2_hi );
   
  __mmask8 hi_eq = _mm256_i64x4_cmp_eq_mask( vip1_hi, vip2_hi );
   
  hi_ge |= hi_eq;
   
  __mmask8 lo_ge = _mm256_u64x4_cmp_gt_mask( vip1_lo, vip2_lo ) | _mm256_i64x4_cmp_eq_mask( vip1_lo, vip2_lo );
   
  return
    hi_ge | ( hi_eq & lo_ge )
  ;
#else
  return ~Ripaddr_ipv6x4_cmp_lt_mask0(vip1_lo, vip1_hi, vip2_lo, vip2_hi);
#endif
}

#if 1
 
___RIP_inline
__mmask8
  Ripaddr_ipv6rx4_cmp_eq_mask0(
      __m256i vip1_lo_lo, __m256i vip1_lo_hi
    , __m256i vip1_hi_lo, __m256i vip1_hi_hi
    , __m256i vip2_lo_lo, __m256i vip2_lo_hi
    , __m256i vip2_hi_lo, __m256i vip2_hi_hi
){
  return
      Ripaddr_ipv6x4_cmp_eq_mask0(vip1_lo_lo, vip1_lo_hi, vip2_lo_lo, vip2_lo_hi ) 
    & Ripaddr_ipv6x4_cmp_eq_mask0(vip1_hi_lo, vip1_hi_hi, vip2_hi_lo, vip2_hi_hi ) 
  ;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv6rx4_cmp_neq_mask0(
      __m256i vip1_lo_lo, __m256i vip1_lo_hi
    , __m256i vip1_hi_lo, __m256i vip1_hi_hi
    , __m256i vip2_lo_lo, __m256i vip2_lo_hi
    , __m256i vip2_hi_lo, __m256i vip2_hi_hi
){
  return
      ~Ripaddr_ipv6rx4_cmp_eq_mask0(
        vip1_lo_lo, vip1_lo_hi
      , vip1_hi_lo, vip1_hi_hi
      , vip2_lo_lo, vip2_lo_hi 
      , vip2_hi_lo, vip2_hi_hi 
    ) 
  ;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv6rx4_cmp_lt_mask0(
      __m256i vip1_lo_lo, __m256i vip1_lo_hi
    , __m256i vip1_hi_lo, __m256i vip1_hi_hi
    , __m256i vip2_lo_lo, __m256i vip2_lo_hi
    , __m256i vip2_hi_lo, __m256i vip2_hi_hi
){
  int lo_lt = Ripaddr_ipv6x4_cmp_lt_mask0( 
      vip1_lo_lo, vip1_lo_hi
    , vip2_lo_lo, vip2_lo_hi
  );
  int lo_eq = Ripaddr_ipv6x4_cmp_eq_mask0( 
      vip1_lo_lo, vip1_lo_hi
    , vip2_lo_lo, vip2_lo_hi
  );
  int hi_lt = Ripaddr_ipv6x4_cmp_lt_mask0( 
      vip1_hi_lo, vip1_hi_hi
    , vip2_hi_lo, vip2_hi_hi
  );
   
  return 
    lo_lt | ( lo_eq & hi_lt )
  ;
}
 
___RIP_inline
__mmask8
  Ripaddr_ipv6rx4_cmp_gt_mask0(
      __m256i vip1_lo_lo, __m256i vip1_lo_hi
    , __m256i vip1_hi_lo, __m256i vip1_hi_hi
    , __m256i vip2_lo_lo, __m256i vip2_lo_hi
    , __m256i vip2_hi_lo, __m256i vip2_hi_hi
){
  int lo_gt = Ripaddr_ipv6x4_cmp_gt_mask0( 
      vip1_lo_lo, vip1_lo_hi
    , vip2_lo_lo, vip2_lo_hi
  );
  int lo_eq = Ripaddr_ipv6x4_cmp_eq_mask0( 
      vip1_lo_lo, vip1_lo_hi
    , vip2_lo_lo, vip2_lo_hi
  );
  int hi_gt = Ripaddr_ipv6x4_cmp_gt_mask0( 
      vip1_hi_lo, vip1_hi_hi
    , vip2_hi_lo, vip2_hi_hi
  );
   
  return 
    lo_gt | ( lo_eq & hi_gt )
  ;
}

 
___RIP_inline
__mmask8
  Ripaddr_ipv6rx4_cmp_ge_mask0(
      __m256i vip1_lo_lo, __m256i vip1_lo_hi
    , __m256i vip1_hi_lo, __m256i vip1_hi_hi
    , __m256i vip2_lo_lo, __m256i vip2_lo_hi
    , __m256i vip2_hi_lo, __m256i vip2_hi_hi
){
   
  return ~Ripaddr_ipv6rx4_cmp_lt_mask0(
      vip1_lo_lo, vip1_lo_hi
    , vip1_hi_lo, vip1_hi_hi
    , vip2_lo_lo, vip2_lo_hi
    , vip2_hi_lo, vip2_hi_hi
  );
}
 
___RIP_inline
__mmask8
  Ripaddr_ipv6rx4_cmp_le_mask0(
      __m256i vip1_lo_lo, __m256i vip1_lo_hi
    , __m256i vip1_hi_lo, __m256i vip1_hi_hi
    , __m256i vip2_lo_lo, __m256i vip2_lo_hi
    , __m256i vip2_hi_lo, __m256i vip2_hi_hi
){
   
  return ~Ripaddr_ipv6rx4_cmp_gt_mask0(
      vip1_lo_lo, vip1_lo_hi
    , vip1_hi_lo, vip1_hi_hi
    , vip2_lo_lo, vip2_lo_hi
    , vip2_hi_lo, vip2_hi_hi
  );
}
#endif
 
 
#endif  

#if 1
 
 
#if 1  
 
 
__m256i
  _mm256_not_epu64_hb0(
    __m256i x
){
   
  const __m256d hb   = _mm256_castsi256_pd( _mm256_set1_epi64x( 0x1L << 63 ) );
   
  return _mm256_castpd_si256(_mm256_xor_pd(
    _mm256_castsi256_pd(x), hb
  ));
}
 
 
__m256i
  _mm256_cmpgt_epu64_hb0(
    __m256i vip_lo, __m256i vip_hi
){
   
  const __m256d hb   = _mm256_castsi256_pd( _mm256_set1_epi64x( 0x1L << 63 ) );
   
  __m256d gt0 = _mm256_and_pd(
    _mm256_castsi256_pd(_mm256_cmpgt_epi64( vip_lo, vip_hi ) )
   , hb  
  );
   
  __m256d lo_sign = _mm256_and_pd(
   _mm256_castsi256_pd(vip_lo)
   , hb 
  );
   
  __m256d hi_sign = _mm256_and_pd(
   _mm256_castsi256_pd(vip_hi)
   , hb 
  );
   
  __m256d sign = _mm256_xor_pd(lo_sign, hi_sign);
   
  gt0 = _mm256_xor_pd(
       sign, gt0
  );
   
  return _mm256_castpd_si256( gt0 );
}
 
 
__m256i
  Ripaddr_ipv6_cmp_simd_gt(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  const __m256d hb = _mm256_castsi256_pd( _mm256_set1_epi64x( 0x1L << 63 ) );
   
  __m256d hi_gt = _mm256_castsi256_pd( _mm256_cmpgt_epu64_hb0(vip1_hi, vip2_hi )) ; 
   
  __m256d hi_eq = _mm256_and_pd(
    _mm256_castsi256_pd( _mm256_cmpeq_epi64( vip1_hi, vip2_hi ) )
    , hb
  );
   
  __m256d lo_gt = _mm256_castsi256_pd( _mm256_cmpgt_epu64_hb0( vip1_lo, vip2_lo ));
   
  return _mm256_srli_epi64(
   _mm256_castpd_si256(_mm256_or_pd(
      hi_gt
      , _mm256_and_pd(
        hi_eq, lo_gt
      )
    ))
    , 63
  );
}
 
 
__m256i
  Ripaddr_ipv6_cmp_simd_lt(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  const __m256d hb = _mm256_castsi256_pd( _mm256_set1_epi64x( 0x1L << 63 ) );
   
  __m256d hi_lt = _mm256_castsi256_pd(_mm256_not_epu64_hb0(
    _mm256_cmpgt_epu64_hb0(vip1_hi, vip2_hi )
  )); 
   
  __m256d hi_eq = _mm256_and_pd(
    _mm256_castsi256_pd( _mm256_cmpeq_epi64( vip1_hi, vip2_hi ) )
    , hb
  );
 
   
  hi_lt = _mm256_xor_pd(hi_lt, hi_eq);
   
  __m256d lo_lt = _mm256_castsi256_pd(_mm256_not_epu64_hb0(
    _mm256_cmpgt_epu64_hb0(vip1_lo, vip2_lo )
  )); 
 
  __m256d lo_eq = _mm256_and_pd(
    _mm256_castsi256_pd( _mm256_cmpeq_epi64( vip1_lo, vip2_lo ) )
    , hb
  );
   
  lo_lt = _mm256_xor_pd(lo_lt, lo_eq);
 
   
  return _mm256_srli_epi64(
   _mm256_castpd_si256(_mm256_or_pd(
      hi_lt
      , _mm256_and_pd(
        hi_eq, lo_lt
      )
    ))
    , 63
  );
}
 
 
#else
 
__m256i
  Ripaddr_ipv6_cmp_simd_gt(
    __m256i vip1_lo, __m256i vip1_hi, __m256i vip2_lo, __m256i vip2_hi
){
   
  __m256d one = _mm256_castsi256_pd( _mm256_set1_epi64x( 0x1 ) );
   
  __m256d hi_gt = _mm256_castsi256_pd( _mm256_cmpgt_epi64( vip1_hi, vip2_hi ));
 
   
  __m256d hi_eq = _mm256_castsi256_pd( _mm256_cmpeq_epi64( vip1_hi, vip2_hi ));
 
   
  __m256d lo_gt = _mm256_castsi256_pd( _mm256_cmpgt_epi64( vip1_lo, vip2_lo ));
 
   
  return
    _mm256_castpd_si256( _mm256_and_pd(
      _mm256_or_pd(
        hi_gt
        , _mm256_and_pd(
          hi_eq, lo_gt
        )
      )
      , one
    ))
  ;
}
#endif  
 
 
SEXP Rip_ipv6x4_gt_test0(
  SEXP Rip1, SEXP Rip2 
){
  SEXP Res; 
  int nprotected=0, nip=0, *resptr, i=0;
  RIPv6_SLOTS_GET( Rip1 )  
  RIPv6_SLOTS_GET( Rip2 )  
Rprintf("%d %d\n", Rip1_nip, Rip2_nip);
  if(Rip1_nip!=Rip2_nip){UNPROTECT(nprotected); error("nip");return ScalarLogical(0);}
  nip = Rip1_nip;
  PROTECT( Res = allocVector(LGLSXP, nip ) ); 
  nprotected++; 
  if( nip<1 ){UNPROTECT(nprotected); return Res;}; 
  resptr = INTEGER( Res ); 
  RIP_BEGIN
  RIP_END
 
  int step=8;
  for(i=0; i<nip-(nip%step); i+=step){

    __m256i vip1_lo = _mm256_loadu_si256( (__m256i const *) &Rip1_ip_lo_ptr[i] );
    __m256i vip1_hi = _mm256_loadu_si256( (__m256i const *) &Rip1_ip_hi_ptr[i] );
    __m256i vip2_lo = _mm256_loadu_si256( (__m256i const *) &Rip2_ip_lo_ptr[i] );
    __m256i vip2_hi = _mm256_loadu_si256( (__m256i const *) &Rip2_ip_hi_ptr[i] );
 
#if 1
 
     
    int res0 = Ripaddr_ipv6x4_cmp_lt_mask0(
       vip1_lo, vip1_hi
       , vip2_lo, vip2_hi
    );  

    vip1_lo = _mm256_loadu_si256( (__m256i const *) &Rip1_ip_lo_ptr[i+4] );
    vip1_hi = _mm256_loadu_si256( (__m256i const *) &Rip1_ip_hi_ptr[i+4] );
    vip2_lo = _mm256_loadu_si256( (__m256i const *) &Rip2_ip_lo_ptr[i+4] );
    vip2_hi = _mm256_loadu_si256( (__m256i const *) &Rip2_ip_hi_ptr[i+4] );
     
    int res1 = Ripaddr_ipv6x4_cmp_lt_mask0(
       vip1_lo, vip1_hi
       , vip2_lo, vip2_hi
    );

    _mm256_storeu_si256(
      (__m256i *) &resptr[i]
      , _mm256_set_epi32( 
         
          ( res1 & ( 1 << 3) )>0
        , ( res1 & ( 1 << 2) )>0 
        , ( res1 & ( 1 << 1) )>0 
        , ( res1 & ( 1 )     )>0
        , ( res0 & ( 1 << 3) )>0 
        , ( res0 & ( 1 << 2) )>0 
        , ( res0 & ( 1 << 1) )>0
        , ( res0 & ( 1 )     )>0
      )
    );

#else
    __m256i res = Ripaddr_ipv6_cmp_simd_gt(
       vip1_lo, vip1_hi
       , vip2_lo, vip2_hi
    );
 
 
#if 1
    vip1_lo = _mm256_loadu_si256( (__m256i const *) &Rip1_ip_lo_ptr[i+4] );
    vip1_hi = _mm256_loadu_si256( (__m256i const *) &Rip1_ip_hi_ptr[i+4] );
    vip2_lo = _mm256_loadu_si256( (__m256i const *) &Rip2_ip_lo_ptr[i+4] );
    vip2_hi = _mm256_loadu_si256( (__m256i const *) &Rip2_ip_hi_ptr[i+4] );
     
    __m256i res1 = Ripaddr_ipv6_cmp_simd_gt(
       vip1_lo, vip1_hi
       , vip2_lo, vip2_hi
    );
 
    res = _mm256_permutevar8x32_epi32(
      res
      , _mm256_set_epi32(
           7, 5, 3, 1 
         , 6, 4, 2, 0
      )
    );

    res1 = _mm256_permutevar8x32_epi32(
      res1
      , _mm256_set_epi32(
            6, 4, 2, 0
          , 7, 5, 3, 1
      )
    );

    res = _mm256_castps_si256(_mm256_or_ps(
      _mm256_castsi256_ps(res), _mm256_castsi256_ps(res1)
    ));

     _mm256_storeu_si256(
      (__m256i *) &resptr[i]
      , res
    );
#else
     
    resptr[i]   = res[0];
    resptr[i+1] = res[1];
    resptr[i+2] = res[2];
    resptr[i+3] = res[3];
#endif

#endif  
    
  }
 
  for(;i<nip;i++){
    RIPv6_ELT_PTR_DCL(Rip1, i) 
    RIPv6_ELT_PTR_DCL(Rip2, i)
    resptr[i] = Ripaddr_ipv6_cmp_lt(   
       Rip1_ip_elt_ptr 
       , Rip2_ip_elt_ptr 
    ); 
  }
  RIP_Rvec_IDSLOT_CP(Res, Rip1 )
  RIP_Rvec_IDSLOT_CP(Res, Rip2 )
  UNPROTECT(nprotected); 
  return Res;
}

#endif  

#if 1  
 
#define ___IP_VERSION__      v4
#define ___IP_VERSION_NUM__  40

#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_eq
 
SEXP Rip_ipv4_op2_bool_scalar_eq_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  _mm256_i32x8_cmp_eq_mask( ___x__##_vip, ___y__##_vip)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_eq
 
SEXP Rip_ipv4_op2_bool_eq_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  _mm256_i32x8_cmp_neq_mask( ___x__##_vip, ___y__##_vip)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_neq
 
SEXP Rip_ipv4_op2_bool_neq_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#if 1
 
#define ___SIMD_Fn__(___x__, ___y__) \
   _mm256_u32x8_cmp_lt_mask( ___x__##_vip, ___y__##_vip)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_lt
 
SEXP Rip_ipv4_op2_bool_lt_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  _mm256_u32x8_cmp_gt_mask( ___x__##_vip, ___y__##_vip)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_gt
 
SEXP Rip_ipv4_op2_bool_gt_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
   _mm256_u32x8_cmp_le_mask( ___x__##_vip, ___y__##_vip)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_le
 
SEXP Rip_ipv4_op2_bool_le_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
   _mm256_u32x8_cmp_ge_mask( ___x__##_vip, ___y__##_vip)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4_cmp_ge
 
SEXP Rip_ipv4_op2_bool_ge_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
#endif  
 
 
#undef ___IP_VERSION__   
#undef ___IP_VERSION_NUM__   
 
#endif  

#if 1  
 
#define ___IP_VERSION__      v4r
#define ___IP_VERSION_NUM__  41

#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv4rx8_cmp_eq_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4r_cmp_eq
 
SEXP Rip_ipv4r_op2_bool_eq_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv4rx8_cmp_neq_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4r_cmp_neq
 
SEXP Rip_ipv4r_op2_bool_neq_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv4rx8_cmp_gt_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4r_cmp_gt
 
SEXP Rip_ipv4r_op2_bool_gt_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv4rx8_cmp_lt_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4r_cmp_lt
 
SEXP Rip_ipv4r_op2_bool_lt_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 

#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv4rx8_cmp_le_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4r_cmp_le
 
SEXP Rip_ipv4r_op2_bool_le_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 

#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv4rx8_cmp_ge_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv4r_cmp_ge
 
SEXP Rip_ipv4r_op2_bool_ge_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 

#undef ___IP_VERSION__   
#undef ___IP_VERSION_NUM__   
 
#endif  

#if 1  
 
#define ___IP_VERSION__      v6
#define ___IP_VERSION_NUM__  60

#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6x4_cmp_eq_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv6_cmp_eq
 
SEXP Rip_ipv6_op2_bool_eq_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6x4_cmp_neq_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv6_cmp_neq
 
SEXP Rip_ipv6_op2_bool_neq_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#if 1
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6x4_cmp_lt_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
#else
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6_cmp_simd_lt( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
#endif  
 
#define ___SCALAR_Fn__     Ripaddr_ipv6_cmp_lt
 
SEXP Rip_ipv6_op2_bool_lt_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#if 1
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6x4_cmp_gt_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
#else
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6_cmp_simd_gt( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
#endif  
 
#define ___SCALAR_Fn__     Ripaddr_ipv6_cmp_gt
 
SEXP Rip_ipv6_op2_bool_gt_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6x4_cmp_ge_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv6_cmp_ge
 
SEXP Rip_ipv6_op2_bool_ge_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6x4_cmp_le_mask0( ___x__##_vlo , ___x__##_vhi , ___y__##_vlo , ___y__##_vhi)
 
#define ___SCALAR_Fn__     Ripaddr_ipv6_cmp_le
 
SEXP Rip_ipv6_op2_bool_le_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#undef ___IP_VERSION__   
#undef ___IP_VERSION_NUM__  
 
#endif  

#if 1  
 
#define ___IP_VERSION__      v6r
#define ___IP_VERSION_NUM__  61
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6rx4_cmp_eq_mask0( \
      ___x__##_vlo_lo , ___x__##_vlo_hi \
    , ___x__##_vhi_lo , ___x__##_vhi_hi \
    , ___y__##_vlo_lo , ___y__##_vlo_hi \
    , ___y__##_vhi_lo , ___y__##_vhi_hi \
  )

 
#define ___SCALAR_Fn__     Ripaddr_ipv6r_cmp_eq
 
SEXP Rip_ipv6r_op2_bool_eq_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6rx4_cmp_neq_mask0( \
      ___x__##_vlo_lo , ___x__##_vlo_hi \
    , ___x__##_vhi_lo , ___x__##_vhi_hi \
    , ___y__##_vlo_lo , ___y__##_vlo_hi \
    , ___y__##_vhi_lo , ___y__##_vhi_hi \
  )

 
#define ___SCALAR_Fn__     Ripaddr_ipv6r_cmp_neq
 
SEXP Rip_ipv6r_op2_bool_neq_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6rx4_cmp_gt_mask0( \
      ___x__##_vlo_lo , ___x__##_vlo_hi \
    , ___x__##_vhi_lo , ___x__##_vhi_hi \
    , ___y__##_vlo_lo , ___y__##_vlo_hi \
    , ___y__##_vhi_lo , ___y__##_vhi_hi \
  )

 
#define ___SCALAR_Fn__     Ripaddr_ipv6r_cmp_gt
 
SEXP Rip_ipv6r_op2_bool_gt_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6rx4_cmp_lt_mask0( \
      ___x__##_vlo_lo , ___x__##_vlo_hi \
    , ___x__##_vhi_lo , ___x__##_vhi_hi \
    , ___y__##_vlo_lo , ___y__##_vlo_hi \
    , ___y__##_vhi_lo , ___y__##_vhi_hi \
  )

 
#define ___SCALAR_Fn__     Ripaddr_ipv6r_cmp_lt
 
SEXP Rip_ipv6r_op2_bool_lt_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6rx4_cmp_ge_mask0( \
      ___x__##_vlo_lo , ___x__##_vlo_hi \
    , ___x__##_vhi_lo , ___x__##_vhi_hi \
    , ___y__##_vlo_lo , ___y__##_vlo_hi \
    , ___y__##_vhi_lo , ___y__##_vhi_hi \
  )

 
#define ___SCALAR_Fn__     Ripaddr_ipv6r_cmp_ge
 
SEXP Rip_ipv6r_op2_bool_ge_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__) \
  Ripaddr_ipv6rx4_cmp_le_mask0( \
      ___x__##_vlo_lo , ___x__##_vlo_hi \
    , ___x__##_vhi_lo , ___x__##_vhi_hi \
    , ___y__##_vlo_lo , ___y__##_vlo_hi \
    , ___y__##_vhi_lo , ___y__##_vhi_hi \
  )

 
#define ___SCALAR_Fn__     Ripaddr_ipv6r_cmp_le
 
SEXP Rip_ipv6r_op2_bool_le_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_BOOL_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_BOOL_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#undef ___IP_VERSION__   
#undef ___IP_VERSION_NUM__  
 
#endif  

#endif  

___RIP_inline
int
  Rippaddr_ipv4r_cmp_pmin(
    IPv4 *ip1, IPv4 *ip2, IPv4r *res
){
   
  int lt = 0;
  if( ( lt = Ripaddr_ipv4r_cmp_lt(ip1,ip2) ) ){
    res->lo = ((IPv4r*) ip1 )->lo;
    res ->hi = ((IPv4r*) ip1 )->hi;
    return 1;
  }
  res->lo = ((IPv4r*) ip2 )->lo;
  res->hi = ((IPv4r*) ip2 )->hi;
  return 1;
}

___RIP_inline
int
  Rippaddr_ipv6_cmp_pmin(
    uint64_t *ip1, uint64_t *ip2, uint64_t *res
){
   
  int lt = 0;
  if( ( lt = Ripaddr_ipv6_cmp_lt(ip1,ip2) ) ){
    res[0] = ip1[0];
    res[1] = ip1[1];
    return 1;
  }
  res[0] = ip2[0];
  res[1] = ip2[1];
  return 1;
}
 
RIP_OP2_ARITH_IP(v6, pmin, Rippaddr_ipv6_cmp_pmin)
 
 
___RIP_inline
int
  Rippaddr_ipv6_cmp_pmax(
    uint64_t *ip1, uint64_t *ip2, uint64_t *res
){
   
  int lt = 0;
  if( ( lt = Ripaddr_ipv6_cmp_gt(ip1,ip2) ) ){
    res[0] = ip1[0];
    res[1] = ip1[1];
    return 1;
  }
  res[0] = ip2[0];
  res[1] = ip2[1];
  return 1;
}
 
RIP_OP2_ARITH_IP(v6, pmax, Rippaddr_ipv6_cmp_pmax)

#ifdef  __RIP_AVX2__  

___RIP_inline
__mmask8
  Ripaddr_ipv4rx8_cmp_pmin0(
     __m256i  vip1_lo, __m256i  vip1_hi, __m256i  vip2_lo, __m256i  vip2_hi
   , __m256i *rv_lo  , __m256i *rv_hi
){
   
  __mmask8 lt = Ripaddr_ipv4rx8_cmp_lt_mask0(vip1_lo, vip1_hi, vip2_lo, vip2_hi);
Rprintf("lt:%d\n", lt);
   
  __m256i idx = _mm256_sllv_epi32(
      _mm256_set1_epi32( lt )
    , _mm256_set_epi32(
       
      24, 25, 26, 27, 28, 29, 30, 31
    )
  );
Rippaddr_ipv4x8_Rprintf_0(idx);

  *rv_lo = _mm256_castps_si256(_mm256_blendv_ps(
      _mm256_castsi256_ps( vip1_lo )
    , _mm256_castsi256_ps( vip2_lo )
    , _mm256_castsi256_ps( idx )
  ));
   
  *rv_hi = _mm256_castps_si256(_mm256_blendv_ps(
      _mm256_castsi256_ps( vip1_hi )
    , _mm256_castsi256_ps( vip2_hi )
    , _mm256_castsi256_ps( idx )
  ));
   
  return 0xFF;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv6x4_cmp_pmin0(
     __m256i  vip1_lo, __m256i  vip1_hi, __m256i  vip2_lo, __m256i  vip2_hi
   , __m256i *rv_lo  , __m256i *rv_hi
){
   
  __mmask8 lt = Ripaddr_ipv6x4_cmp_lt_mask0(vip1_lo, vip1_hi, vip2_lo, vip2_hi);
 
   
  __m256i idx = _mm256_sllv_epi64(
      _mm256_set1_epi64x( ~lt & 0xf )
    , _mm256_set_epi64x(
       
      60, 61, 62, 63
    )
  );

  *rv_lo = _mm256_castpd_si256(_mm256_blendv_pd(
      _mm256_castsi256_pd( vip1_lo )
    , _mm256_castsi256_pd( vip2_lo )
    , _mm256_castsi256_pd( idx )
  ));
   
  *rv_hi = _mm256_castpd_si256(_mm256_blendv_pd(
      _mm256_castsi256_pd( vip1_hi )
    , _mm256_castsi256_pd( vip2_hi )
    , _mm256_castsi256_pd( idx )
  ));
   
  return 0xFF;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv6x4_cmp_pmax0(
     __m256i  vip1_lo, __m256i  vip1_hi, __m256i  vip2_lo, __m256i  vip2_hi
   , __m256i *rv_lo  , __m256i *rv_hi
){
 
   
  __mmask8 lt = Ripaddr_ipv6x4_cmp_gt_mask0(vip1_lo, vip1_hi, vip2_lo, vip2_hi);
 
   
  __m256i idx = _mm256_sllv_epi64(
      _mm256_set1_epi64x( ~lt & 0xf )
    , _mm256_set_epi64x(
       
      60, 61, 62, 63
    )
  );
   
  *rv_lo = _mm256_castpd_si256(_mm256_blendv_pd(
      _mm256_castsi256_pd( vip1_lo )
    , _mm256_castsi256_pd( vip2_lo )
    , _mm256_castsi256_pd( idx )
  ));
   
  *rv_hi = _mm256_castpd_si256(_mm256_blendv_pd(
      _mm256_castsi256_pd( vip1_hi )
    , _mm256_castsi256_pd( vip2_hi )
    , _mm256_castsi256_pd( idx )
  ));
   
  return 0xFF;
}
 
 
___RIP_inline
__mmask8
  Ripaddr_ipv6rx4_cmp_pmin0(
      __m256i vip1_lo_lo, __m256i vip1_lo_hi
    , __m256i vip1_hi_lo, __m256i vip1_hi_hi
    , __m256i vip2_lo_lo, __m256i vip2_lo_hi
    , __m256i vip2_hi_lo, __m256i vip2_hi_hi
     
    , __m256i *rv_lo_lo, __m256i *rv_lo_hi
    , __m256i *rv_hi_lo, __m256i *rv_hi_hi
){
   
  __mmask8 lt = Ripaddr_ipv6x4_cmp_lt_mask0(vip1_lo_lo, vip1_lo_hi, vip2_lo_lo, vip2_lo_hi );
   
  __m256i idx = _mm256_srlv_epi64(
      _mm256_set1_epi64x(lt)
    , _mm256_set_epi64x(
      0,  1, 2, 3
    )
  );

  *rv_lo_lo = _mm256_castpd_si256(_mm256_blendv_pd(
      _mm256_castsi256_pd( vip1_lo_lo )
    , _mm256_castsi256_pd( vip2_lo_lo )
    , _mm256_castsi256_pd( idx )
  ));
   
  *rv_lo_hi = _mm256_castpd_si256(_mm256_blendv_pd(
      _mm256_castsi256_pd( vip1_lo_hi )
    , _mm256_castsi256_pd( vip2_lo_hi )
    , _mm256_castsi256_pd( idx )
  ));
   
  *rv_hi_lo = _mm256_castpd_si256(_mm256_blendv_pd(
      _mm256_castsi256_pd( vip1_hi_lo )
    , _mm256_castsi256_pd( vip2_hi_lo )
    , _mm256_castsi256_pd( idx )
  ));
   
  *rv_hi_hi = _mm256_castpd_si256(_mm256_blendv_pd(
      _mm256_castsi256_pd( vip1_hi_hi )
    , _mm256_castsi256_pd( vip2_hi_hi )
    , _mm256_castsi256_pd( idx )
  ));
   
  return lt;
}

#if 0  
 
#define ___IP_VERSION__      v4r
#define ___IP_VERSION_NUM__  41
 
 
#define ___SIMD_Fn__(___x__, ___y__, ___res__) \
  Ripaddr_ipv4rx8_cmp_pmin0( \
      ___x__##_vlo , ___x__##_vhi \
    , ___y__##_vlo , ___y__##_vhi \
    , ___res__##_vlo , ___res__##_vhi \
  )

 
#define ___SCALAR_Fn__   Rippaddr_ipv4r_cmp_pmin   
 
SEXP Rip_ipv4r_op2_cmp_pmin_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_ARITH_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_ARITH_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#undef ___IP_VERSION__   
#undef ___IP_VERSION_NUM__  
 
#endif  

#if 1  
 
#define ___IP_VERSION__      v6
#define ___IP_VERSION_NUM__  60
 
 
#define ___SIMD_Fn__(___x__, ___y__, ___res__) \
  Ripaddr_ipv6x4_cmp_pmin0( \
      ___x__##_vlo , ___x__##_vhi \
    , ___y__##_vlo , ___y__##_vhi \
    , ___res__##_vlo , ___res__##_vhi \
  )

 
#define ___SCALAR_Fn__   Rippaddr_ipv6_cmp_pmin   
 
SEXP Rip_ipv6_op2_cmp_pmin_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_ARITH_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_ARITH_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#define ___SIMD_Fn__(___x__, ___y__, ___res__) \
  Ripaddr_ipv6x4_cmp_pmax0( \
      ___x__##_vlo , ___x__##_vhi \
    , ___y__##_vlo , ___y__##_vhi \
    , ___res__##_vlo , ___res__##_vhi \
  )

 
#define ___SCALAR_Fn__   Rippaddr_ipv6_cmp_pmax 
 
SEXP Rip_ipv6_op2_cmp_pmax_2( 
    SEXP Rip1, SEXP Rip2 
){ 
 
#define ___IP_OP2_ARITH_BODY__
   
  #include "templates/Rip-iter-template.c"
 
#undef ___IP_OP2_ARITH_BODY__
}
 
#undef ___SIMD_Fn__   
#undef ___SCALAR_Fn__ 
 
 
#undef ___IP_VERSION__   
#undef ___IP_VERSION_NUM__  
 
#endif  
 
 
#endif  

___RIP_inline
int 
  Ripaddr_ipv4r_cmp_intersects(
    IPv4 *ip1, IPv4 *ip2
){
   
  return ( ip2[0] < ip1[0] ) & ( ip2[1] < ip1[1] );
}
 
RIP_OP2_BOOL(v4r, intersects, Ripaddr_ipv4r_cmp_intersects)

