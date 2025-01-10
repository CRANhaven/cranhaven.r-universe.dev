 
 
#include "Rip.h"

#define RIP_IPr_BSEARCH_0(___IPv__, ___IPv_Tb__, ___opname__, ___cmp1__, ___cmp2__) \
SEXP Rip_bsearch_ip##___IPv__##_##___opname__##_ip##___IPv_Tb__##_0( \
    SEXP Rip, SEXP RipTb \
  , SEXP Ridx \
  , SEXP Romatch \
){ \
  SEXP Res; \
  int nprotected=0; \
  RIP##___IPv__##_SLOTS_GET( Rip ) \
  RIP##___IPv_Tb__##_SLOTS_GET( RipTb ) \
  RipTb_nip+=0;\
  int idx_nip   = LENGTH(Ridx); \
  int *idx_ptr  = INTEGER(Ridx); \
  int nomatch  = *INTEGER(Romatch); \
  PROTECT( Res = allocVector(INTSXP, Rip_nip ) ); \
  nprotected++; \
  int *resptr  = INTEGER( Res ); \
  RIP_BEGIN \
  for( int i=0 ; i<Rip_nip; i++ ){ \
  \
 \
     \
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER) ){ resptr[i]= nomatch;i++;} \
    if(i>=Rip_nip) break; \
  \
    RIP##___IPv__##_ELT_PTR_DCL(Rip, i) \
   \
    resptr[i]  = nomatch; \
    int lo  = 0, hi  = idx_nip-1; \
    while ( lo <= hi ){ \
      int mid = lo + ( hi - lo )/2; \
   \
      RIP##___IPv_Tb__##_ELT_PTR_DCL(RipTb, idx_ptr[mid] )   \
  \
      if( \
        ___cmp1__(Rip_ip_elt_ptr, RipTb_ip_elt_ptr ) \
      ){ \
 \
        resptr[i] = idx_ptr[mid]; \
        break; \
      } \
 \
        \
      if( \
            \
          ___cmp2__(Rip_ip_elt_ptr, RipTb_ip_elt_ptr) \
      ){ \
        lo = mid+1; \
      }else{ \
        hi = mid-1; \
      } \
    } \
  } \
  RIP_END \
  resptr = INTEGER( Res ); \
  RIP_Rvec_IDSLOT_CP(Res, Rip ) \
  UNPROTECT(nprotected); \
  return Res; \
}

___RIP_inline
int Rippaddr_ipv4r_diff(IPv4 *ip4r, IPv4 *res){
 
   
 *res = ip4r[0] + ( ip4r[1] - ip4r[0] );
 
  return 1;
}
 
___RIP_inline
int Rippaddr_ipv4_in_ipv4r(IPv4 ip4, IPv4 *ip4r){
   
  return ( 
       ip4 >= ip4r[0]
    && ip4 <= ip4r[1]
  );
}
 
___RIP_inline
int Ripaddr_bsearch_ipv4_cmp_gt(IPv4 ip4, IPv4 *ip4r){
   
  return ( 
       ip4 > ip4r[0]
  );
}
 
___RIP_inline
int Ripaddr_bsearch_ipv4_cmp_le(IPv4 ip4, IPv4 *ip4r){
   
  return ( 
       ip4 <= ip4r[0]
  );
}
 
RIP_IPr_BSEARCH_0(v4, v4r, in, Rippaddr_ipv4_in_ipv4r, Ripaddr_bsearch_ipv4_cmp_gt )
 
 
___RIP_inline
int Rippaddr_ipv4r_in_ipv4r(IPv4* ip4r1, IPv4 *ip4r2){
   
  return ( 
       ip4r1[0] >= ip4r2[0]
    && ip4r1[1] <= ip4r2[1]
  );
}
 
___RIP_inline
int Ripaddr_bsearch_ipv4r_cmp_gt(IPv4 *ip4r1, IPv4 *ip4r2){

  return(
    ip4r1[0] > ip4r2[0]
  );
  
}
 
RIP_IPr_BSEARCH_0(v4r, v4r, in, Rippaddr_ipv4r_in_ipv4r, Ripaddr_bsearch_ipv4r_cmp_gt )
 
 
___RIP_inline
int Rippaddr_ipv6r_diff(IPv6r *ip6r, uint64_t *res){
 
   
  uint64_t diff[2];
  Rippaddr_ipv6_sub_ipv6( ip6r->hi.ipv6, ip6r->lo.ipv6, (uint64_t*) &diff);
  return Rippaddr_ipv6_add_ipv6( ip6r->hi.ipv6, diff, res );
}
 
___RIP_inline
int Rippaddr_ipv6_in_ipv6r(uint64_t* ip6, IPv6r *ip6r){
   
  return ( 
       Ripaddr_ipv6_cmp_ge( ip6, ip6r->lo.ipv6 )
    && Ripaddr_ipv6_cmp_le( ip6, ip6r->hi.ipv6 )
  );
} 
___RIP_inline
int Ripaddr_bsearch_ipv6_cmp_gt( uint64_t *ip6, IPv6r *ip6r){
   
  return(
    Ripaddr_ipv6_cmp_ge( ip6, ip6r->lo.ipv6 )
  );
}
 
RIP_IPr_BSEARCH_0(v6, v6r, in, Rippaddr_ipv6_in_ipv6r, Ripaddr_bsearch_ipv6_cmp_gt )
 
 
___RIP_inline
int Rippaddr_ipv6r_in_ipv6r(IPv6r* ip6r1, IPv6r *ip6r2){
   
  return ( 
       Ripaddr_ipv6_cmp_ge( ip6r1->lo.ipv6, ip6r2->lo.ipv6 )
    && Ripaddr_ipv6_cmp_le( ip6r1->hi.ipv6, ip6r2->hi.ipv6 )
  );
}
 
___RIP_inline
int Ripaddr_bsearch_ipv6r_cmp_gt( IPv6r *ip6r1, IPv6r *ip6r2){
   
  return(
    Ripaddr_ipv6_cmp_ge( ip6r1->lo.ipv6, ip6r2->lo.ipv6 )
  );
}
 
 
RIP_IPr_BSEARCH_0(v6r, v6r, in, Rippaddr_ipv6r_in_ipv6r, Ripaddr_bsearch_ipv6r_cmp_gt )

#define RIP_IPr_BSEARCH_1(___IPv__, ___IPv_Tb__, ___cmp__,  ___opname__, ___suf__) \
SEXP Rip_bsearch_ip##___IPv__##_##___opname__##_ip##___IPv_Tb__##_##___suf__( \
    SEXP Rip, SEXP RipTb \
  , SEXP Ridx \
  , SEXP Romatch \
){ \
  SEXP Res; \
  int nprotected=0,debg=0; debg=0;\
  RIP##___IPv__##_SLOTS_GET( Rip ) \
  RIP##___IPv_Tb__##_SLOTS_GET( RipTb ) \
  RipTb_nip+=0;\
  int idx_nip   = LENGTH(Ridx); \
  int *idx_ptr  = INTEGER(Ridx); \
  int nomatch  = *INTEGER(Romatch); \
  PROTECT( Res = allocVector(INTSXP, Rip_nip ) ); \
  nprotected++; \
  int *resptr  = INTEGER( Res ); \
  RIP_BEGIN \
  for( int i=0 ; i<Rip_nip; i++ ){ \
 \
     \
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER)){ resptr[i]= nomatch;i++;} \
    if(i>=Rip_nip) break; \
  \
  \
    RIP##___IPv__##_ELT_PTR_DCL(Rip, i) \
 \
    resptr[i]  = nomatch; \
    int lo  = 0, num  = idx_nip, pivot; \
    while (num > 0){ \
      int result; \
      pivot  = lo + (num >> 1) ; \
if( debg ) Rprintf("  lo:%d num:%d pivot:%d idx:%d\n", lo, num, pivot, idx_ptr[pivot]); \
      RIP##___IPv_Tb__##_ELT_PTR_DCL(RipTb, idx_ptr[pivot] ) \
 \
      result = ___cmp__(Rip_ip_elt_ptr, RipTb_ip_elt_ptr); \
if( debg ) Rprintf("  cmp:%d\n", result);  \
      if (result == 0){ \
        resptr[i] = idx_ptr[pivot] ; \
        break; \
      } \
      if (result > 0) { \
        lo = pivot+1 ; \
        num--; \
      } \
      num >>= 1; \
if( debg ) Rprintf("  lo:%d num:%d\n", lo, num); \
    } \
  } \
  RIP_END \
  resptr = INTEGER( Res ); \
  RIP_Rvec_IDSLOT_CP(Res, Rip ) \
  UNPROTECT(nprotected); \
  return Res; \
}

___RIP_inline
int Rippaddr_ipv4_cmp_ipv4(IPv4 ip1, IPv4 ip2){
 
   
  if( ip1 < ip2 ) return -1;
  else if( ip1 > ip2 ) return 1;
  else return 0;
}
 
RIP_IPr_BSEARCH_1(v4, v4, Rippaddr_ipv4_cmp_ipv4, in, 1 )
 
RIP_IPr_BSEARCH_1(v4cache, v4cache, Rippaddr_ipv4_cmp_ipv4, in, 1 )

___RIP_inline
int Rippaddr_ipv4_cmp_ipv4r(IPv4 ip4, IPv4 *ip4r){
 
   
  if( Rippaddr_ipv4_in_ipv4r(ip4,ip4r) ) return 0;
 
  return ( ip4 > ip4r[0] ? 1 : -1);
}
 
RIP_IPr_BSEARCH_1(v4, v4r, Rippaddr_ipv4_cmp_ipv4r, in, 1 )
 
 
___RIP_inline
int Rippaddr_ipv4r_cmp_ipv4r(IPv4* ip4r1, IPv4 *ip4r2){
 
#if 0
   
  if( Rippaddr_ipv4r_in_ipv4r(ip4r1,ip4r2) ) return 0;
   
  return ( ip4r1[0] > ip4r2[0] ? 1 : -1);
 
#else
 if( ip4r1[0] < ip4r2[0] ) return -1;
 else if( ip4r1[0] > ip4r2[0] ) return 1;
 else return 0;
#endif
}
 
RIP_IPr_BSEARCH_1(v4r, v4r, Rippaddr_ipv4r_cmp_ipv4r, in, 1 )
 
 
___RIP_inline
int Rippaddr_ipv6_cmp_ipv6(uint64_t *ip1, uint64_t *ip2){
   
  if( Ripaddr_ipv6_cmp_lt( ip1, ip2 ) ) return -1;
  else if( Ripaddr_ipv6_cmp_gt( ip1, ip2 ) ) return 1;
  else return 0;
}
 
RIP_IPr_BSEARCH_1(v6, v6, Rippaddr_ipv6_cmp_ipv6, in, 1 )
 
 
___RIP_inline
int Rippaddr_ipv6_cmp_ipv6r(uint64_t* ip6, IPv6r *ip6r){
 
#if 0
   
  if( 
       Ripaddr_ipv6_cmp_ge( ip6, ip6r->lo.ipv6 )
    && Ripaddr_ipv6_cmp_le( ip6, ip6r->hi.ipv6 )
   ) return 0;
   
  return ( Ripaddr_ipv6_cmp_gt( ip6, ip6r->lo.ipv6 ) ? 1 : -1);
 
#else
 if( Ripaddr_ipv6_cmp_lt( ip6, ip6r->lo.ipv6 ) ) return -1;
 else if( Ripaddr_ipv6_cmp_gt( ip6, ip6r->hi.ipv6 ) ) return 1;
 else return 0;
#endif
}
 
 
RIP_IPr_BSEARCH_1(v6, v6r, Rippaddr_ipv6_cmp_ipv6r, in, 1 )

#ifdef __RIP_AVX2__

#define ___IP_VERSION__      v4
#define ___IP_VERSION_NUM__  40
 
#define ___IP_VAL_SLOTS_GET   RIPv4_SLOTS_GET
#define ___IP_VAL_ELT_PTR_DCL RIPv4_ELT_PTR_DCL
 
#define ___IP_TBL_SLOTS_GET   RIPv4r_SLOTS_GET

#define ___IP_SCALAR_IN( ___x__, ___y__) \
  Rippaddr_ipv4_in_ipv4r( ___x__, ___y__)
 
#define ___IP_SCALAR_GT( ___x__, ___y__) \
  Ripaddr_bsearch_ipv4_cmp_gt( ___x__, ___y__)

#define ___IP_AVX_DIV( ___x__, ___y__ ) \
  _mm256_cvttps_epi32( _mm256_div_ps( _mm256_cvtepi32_ps(___x__), _mm256_cvtepi32_ps(___y__) ) )
  
 
union Um256i32 {
    __m256i v;
    int i[8];
};
 
 
SEXP Rip_bsearch_ipv4_in_ipv4r_2( 
    SEXP Rip
  , SEXP RipTbl 
  , SEXP Ridx 
  , SEXP Romatch 
){
 
#define ___IP_BSEARCH_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_BODY__
}
 
 
SEXP Rip_bsearch_ipv4_in_ipv4r_avx2_0( 
    SEXP Rip
  , SEXP RipTbl 
  , SEXP Ridx 
  , SEXP Romatch 
){
 
#define ___IP_BSEARCH_AVX2_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_AVX2_BODY__
}
 
 
#undef ___IP_VERSION__
#undef ___IP_VERSION_NUM__
 
#undef ___IP_VAL_SLOTS_GET
#undef ___IP_VAL_ELT_PTR_DCL
#undef ___IP_TBL_SLOTS_GET
 
#undef ___IP_SCALAR_IN
#undef ___IP_SCALAR_GT
 
 
#endif  

#define ___IP_VERSION__      v4r
#define ___IP_VERSION_NUM__  41
 
#define ___IP_IP_TYP__       IPv4
#define ___IP_IP_CTYP__       IPv4
#define ___IP_INTVTREE_CTYP__ IPv4r_bsearch_intvTree
 
 
typedef struct IPv4r_bsearch_intvTree {
 
#define ___IP_BSEARCH_INTV_STRUCT_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_STRUCT_BODY__
} IPv4r_bsearch_intvTree;
 
 
#define ___IP_INDEX_VISIT_FN__ Rippaddr_bsearch_intvTree_ipv4r_index_visit_0  
 
#define ___IP_GET__(___ip__, ___tbl__, ___i__) \
  ___ip__ = ___tbl__[ ___i__]
 
#define ___IP_IPr_SLOTS_GET   RIPv4r_SLOTS_GET
 
#define ___IP_LT__(___ip1__, ___ip2__) \
  ___ip1__ < ___ip2__
 
#define ___IP_GT__(___ip1__, ___ip2__) \
  ___ip1__ > ___ip2__
 
 
#if 1
 
void
  ___IP_INDEX_VISIT_FN__(
      IPv4r_bsearch_intvTree *tree
    , int                     lo
    , int                     hi
    , int                     ipIntv_idx[2]  
){
 
#define ___IP_BSEARCH_INTV_INDEX_VISIT_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_INDEX_VISIT_BODY__
}
#endif  
 
 
#if 1
 
SEXP
  Rip_bsearch_intvTree_ipv4r_index_0(
      SEXP RipTbl
    , SEXP Ridx
){
 
#define ___IP_BSEARCH_INTV_INDEX_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_INDEX_BODY__
}
#endif  
 
 
#undef ___IP_INDEX_VISIT_FN__ 
 
#undef ___IP_IPr_SLOTS_GET 
 
 
#define ___IP_MATCH_VISIT_FN__ Rippaddr_bsearch_intvTree_ipv4r_ipv4_in_visit_0  
 
#define ___IP_IPr_GET__(___vname__, ___i__ ) \
  IPv4   ___vname__##_ip_elt[2]; \
  ___vname__##_ip_elt[0] = ___vname__##_ip_lo_ptr[ ___i__ ]; \
  ___vname__##_ip_elt[1] = ___vname__##_ip_hi_ptr[ ___i__ ]; \
  IPv4  *___vname__##_ip_elt_ptr = (IPv4 *) &___vname__##_ip_elt; 
  
 
#define ___IP_GET_LO( ___x__ ) ___x__
#define ___IP_GET_HI( ___x__ ) ___x__
 
int Rippaddr_ipv4_in_ipv4r(IPv4 ip4, IPv4 *ip4r);
 
#define ___IP_MATCH_FN__ Rippaddr_ipv4_in_ipv4r
 
 
#if 1
 
int
  ___IP_MATCH_VISIT_FN__(  
      IPv4            x
    , int             lo
    , int             hi
    , IPv4r_bsearch_intvTree *tree
){
 
#define ___IP_BSEARCH_INTV_MATCH_VISIT_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_MATCH_VISIT_BODY__
}
#endif  
 
 
#define ___IP_VAL_SLOTS_GET RIPv4_SLOTS_GET
#define ___IP_TBL_SLOTS_GET RIPv4r_SLOTS_GET
#define ___IP_VAL_ELT_PTR_DCL RIPv4_ELT_PTR_DCL
 
#define ___IP_INTVTREE_REALLOC Rippaddr_bearch_intvTree_ipv4r_realloc_0
 
___RIP_inline
void
  Rippaddr_bearch_intvTree_ipv4r_realloc_0(
    IPv4r_bsearch_intvTree *tree
){
  if( (*tree->nmatch_acc)==tree->nmatch){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s  realloc\n", tree->depth, "");
#endif
     
    int n = (int) ceil( ( (double) tree->nmatch )*1.6);
     
    if( ( tree->match_ptr = (int *) realloc(tree->match_ptr, n * sizeof(int)) )==NULL){
       
      error("match_ptr realloc");
    }
Rprintf("realloc: %d %d\n", tree->nmatch, n);
    tree->nmatch = n;
  }
  return ;
}
 
#if 1
 
SEXP
  Rip_bsearch_intvTree_ipv4_in_ipv4r_0(
      SEXP Rip
    , SEXP RipTbl
    , SEXP Ridx
    , SEXP Rminmx
    , SEXP Rnomatch
){
 
#define ___IP_BSEARCH_INTV_MATCH_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_MATCH_BODY__
  
}
#endif
 
 
#if 1
 
#undef ___IP_GET_LO
#undef ___IP_GET_HI
#undef ___IP_MATCH_VISIT_FN__
#undef ___IP_MATCH_FN__
 
 
#define ___IP_GET_LO(___x__) \
  ___x__[0]
#define ___IP_GET_HI(___x__) \
  ___x__[1]
 
#define ___IP_MATCH_VISIT_FN__ Rippaddr_bsearch_intvTree_ipv4r_overlap_ipv4r_visit_0  
 
___RIP_inline
int Rippaddr_ipv4r_overlap_ipv4r(IPv4* ip4r1, IPv4 *ip4r2);
 
#define ___IP_MATCH_FN__ Rippaddr_ipv4r_overlap_ipv4r
 
#if 1
 
int
  ___IP_MATCH_VISIT_FN__(  
      IPv4                   *x
    , int                     lo
    , int                     hi
    , IPv4r_bsearch_intvTree *tree
){
 
#define ___IP_BSEARCH_INTV_MATCH_VISIT_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_MATCH_VISIT_BODY__
}
#endif  
 
 
#undef ___IP_VAL_SLOTS_GET
#undef ___IP_VAL_ELT_PTR_DCL
 
#define ___IP_VAL_SLOTS_GET   RIPv4r_SLOTS_GET
#define ___IP_VAL_ELT_PTR_DCL RIPv4r_ELT_PTR_DCL
 
SEXP
  Rip_bsearch_intvTree_ipv4r_overlap_ipv4r_0(
      SEXP Rip
    , SEXP RipTbl
    , SEXP Ridx
    , SEXP Rminmx
    , SEXP Rnomatch
){
 
#define ___IP_BSEARCH_INTV_MATCH_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_MATCH_BODY__
  
}
 
 
#endif  
 
 
#undef ___IP_MATCH_VISIT_FN__
#undef ___IP_IPr_GET__ 
#undef ___IP_GET_LO 
#undef ___IP_GET_HI
#undef ___IP_MATCH_FN__ 
 
#undef ___IP_VAL_SLOTS_GET
#undef ___IP_TBL_SLOTS_GET
#undef ___IP_VAL_ELT_PTR_DCL
#undef ___IP_INTVTREE_REALLOC
 
 
#undef ___IP_VERSION__ 
#undef ___IP_VERSION_NUM__ 
 
#undef ___IP_IP_TYP__ 
#undef ___IP_IP_CTYP__ 
#undef ___IP_INTVTREE_CTYP__ 
#undef ___IP_GET__ 
#undef ___IP_LT__  
#undef ___IP_GT__  

#define ___IP_VERSION__      v6r
#define ___IP_VERSION_NUM__  61
 
#define ___IP_IP_TYP__        IPv6
#define ___IP_IP_CTYP__       uint64_t
#define ___IP_INTVTREE_CTYP__ IPv6r_bsearch_intvTree
 
 
typedef struct IPv6r_bsearch_intvTree {
 
#define ___IP_BSEARCH_INTV_STRUCT_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_STRUCT_BODY__
} IPv6r_bsearch_intvTree;
 
 
#define ___IP_INDEX_VISIT_FN__ Rippaddr_bsearch_intvTree_ipv6r_index_visit_0  
 
#define ___IP_GET__(___ip__, ___tbl__, ___i__) \
  ___ip__.ipv6[0] = ___tbl__[ ___i__ ];   \
  ___ip__.ipv6[1] = ___tbl__[ ___i__ + ___tbl__##_ip_len ];  ; 
 
#define ___IP_IPr_SLOTS_GET   RIPv6r_SLOTS_GET
 
#define ___IP_LT__(___ip1__, ___ip2__) \
  Ripaddr_ipv6_cmp_lt( (uint64_t*) &___ip1__, (uint64_t*) &___ip2__)
 
#define ___IP_GT__(___ip1__, ___ip2__) \
  Ripaddr_ipv6_cmp_gt( (uint64_t*) &___ip1__, (uint64_t*) &___ip2__)

#if 1
 
void
  ___IP_INDEX_VISIT_FN__(
      IPv6r_bsearch_intvTree *tree
    , int                     lo
    , int                     hi
    , int                     *ipIntv_idx  
){
 
#define ___IP_BSEARCH_INTV_INDEX_VISIT_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_INDEX_VISIT_BODY__
}
#endif  
 
 
#if 1
 
SEXP
  Rip_bsearch_intvTree_ipv6r_index_0(
      SEXP RipTbl
    , SEXP Ridx
){
 
#define ___IP_BSEARCH_INTV_INDEX_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_INDEX_BODY__
}
#endif  
 
 
#undef ___IP_INDEX_VISIT_FN__ 
 
#undef ___IP_IPr_SLOTS_GET 
 
 
#define ___IP_MATCH_VISIT_FN__ Rippaddr_bsearch_intvTree_ipv6r_ipv6_in_visit_0  
 
#define ___IP_IPr_GET__(___vname__, ___i__ ) \
  IPv6r   ___vname__##_ip_elt; \
  ___vname__##_ip_elt.lo.ipv6[0] = ___vname__##_ip_lo_ptr[ ___i__ ]; \
  ___vname__##_ip_elt.lo.ipv6[1] = ___vname__##_ip_lo_ptr[ ___i__ + ___vname__##_ip_len ]; \
  ___vname__##_ip_elt.hi.ipv6[0] = ___vname__##_ip_hi_ptr[ ___i__ ]; \
  ___vname__##_ip_elt.hi.ipv6[1] = ___vname__##_ip_hi_ptr[ ___i__ + ___vname__##_ip_len ]; \
  IPv6r  *___vname__##_ip_elt_ptr = (IPv6r *) &___vname__##_ip_elt; 
 
#define ___IP_GET_LO( ___x__ ) ___x__
#define ___IP_GET_HI( ___x__ ) ___x__

 
#undef ___IP_LT__
#undef ___IP_GT__
 
#define ___IP_LT__(___ip1__, ___ip2__) \
  Ripaddr_ipv6_cmp_lt( ___ip1__, (uint64_t*) &___ip2__)
 
#define ___IP_GT__(___ip1__, ___ip2__) \
  Ripaddr_ipv6_cmp_gt( ___ip1__, (uint64_t*) &___ip2__)
 
#define ___IP_MATCH_FN__(___ip__, ___ipr__) \
  Rippaddr_ipv6_in_ipv6r( ___ip__, ___ipr__)
 
#if 1
 
int
  ___IP_MATCH_VISIT_FN__(  
      uint64_t       *x
    , int             lo
    , int             hi
    , IPv6r_bsearch_intvTree *tree
){
 
#define ___IP_BSEARCH_INTV_MATCH_VISIT_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_MATCH_VISIT_BODY__
}
#endif  
 
 
#define ___IP_VAL_SLOTS_GET   RIPv6_SLOTS_GET
#define ___IP_TBL_SLOTS_GET   RIPv6r_SLOTS_GET
#define ___IP_VAL_ELT_PTR_DCL RIPv6_ELT_PTR_DCL
 
#define ___IP_INTVTREE_REALLOC Rippaddr_bearch_intvTree_ipv6r_realloc_0
 
___RIP_inline
void
  Rippaddr_bearch_intvTree_ipv6r_realloc_0(
    IPv6r_bsearch_intvTree *tree
){
  Rippaddr_bearch_intvTree_ipv4r_realloc_0( (IPv4r_bsearch_intvTree*) tree);
}

#if 1
 
SEXP
  Rip_bsearch_intvTree_ipv6_in_ipv6r_0(
      SEXP Rip
    , SEXP RipTbl
    , SEXP Ridx
    , SEXP Rminmx
    , SEXP Rnomatch
){
 
#define ___IP_BSEARCH_INTV_MATCH_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_MATCH_BODY__
  
}
#endif
 
 
#if 1
 
#undef ___IP_GET_LO
#undef ___IP_GET_HI
#undef ___IP_MATCH_VISIT_FN__
#undef ___IP_MATCH_FN__
 
 
___RIP_inline
int Rippaddr_ipv6r_overlap_ipv6r(IPv6r* ip6r1, IPv6r *ip6r2){
   
  return ( 
       Ripaddr_ipv6_cmp_le( ip6r1->lo.ipv6, ip6r2->hi.ipv6 )  
    && Ripaddr_ipv6_cmp_ge( ip6r1->hi.ipv6, ip6r2->lo.ipv6 )  
  );
}
 
#define ___IP_GET_LO( ___x__ ) ( (uint64_t*) &( ___x__->lo ) )
#define ___IP_GET_HI(___x__ ) ( (uint64_t*) &( ___x__->hi ) )
 
#define ___IP_MATCH_VISIT_FN__ Rippaddr_bsearch_intvTree_ipv6r_overlap_ipv6r_visit_0  
 
#define ___IP_MATCH_FN__ Rippaddr_ipv6r_overlap_ipv6r
 
#if 1
 
int
  ___IP_MATCH_VISIT_FN__(  
      IPv6r       *x
    , int             lo
    , int             hi
    , IPv6r_bsearch_intvTree *tree
){
 
#define ___IP_BSEARCH_INTV_MATCH_VISIT_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_MATCH_VISIT_BODY__
}
#endif  
 
 
#undef ___IP_VAL_SLOTS_GET
#undef ___IP_VAL_ELT_PTR_DCL
 
#define ___IP_VAL_SLOTS_GET   RIPv6r_SLOTS_GET
#define ___IP_VAL_ELT_PTR_DCL RIPv6r_ELT_PTR_DCL
 
SEXP
  Rip_bsearch_intvTree_ipv6r_overlap_ipv6r_0(
      SEXP Rip
    , SEXP RipTbl
    , SEXP Ridx
    , SEXP Rminmx
    , SEXP Rnomatch
){
 
#define ___IP_BSEARCH_INTV_MATCH_BODY__ 1
   
  #include "templates/Rip-bsearch-template.c"
 
#undef ___IP_BSEARCH_INTV_MATCH_BODY__
  
}
 
 
#endif  
 
 
#undef ___IP_MATCH_VISIT_FN__
#undef ___IP_IPr_GET__ 
#undef ___IP_GET_LO 
#undef ___IP_GET_HI
#undef ___IP_MATCH_FN__ 
 
#undef ___IP_VAL_SLOTS_GET
#undef ___IP_TBL_SLOTS_GET
#undef ___IP_VAL_ELT_PTR_DCL
#undef ___IP_INTVTREE_REALLOC
 
 
#undef ___IP_VERSION__ 
#undef ___IP_VERSION_NUM__ 
 
#undef ___IP_IP_TYP__ 
#undef ___IP_IP_CTYP__ 
#undef ___IP_INTVTREE_CTYP__ 
#undef ___IP_GET__ 
#undef ___IP_LT__  
#undef ___IP_GT__  

typedef struct IPv4r_intvTree {
     
    int   nip;
    IPv4 *tbl_loPtr;
    IPv4 *tbl_hiPtr;
    int  *idx_ptr;
    int  *minmx_ptr;
     
    int   nmatch;
    int  *nmatch_acc;  
    int  *match_ptr;
     
    int   depth;
} IPv4r_intvTree;
 
#define RIPv4r_ELT_PTR_GET(___vname__, ___i__ )\
  ___vname__##_ip_elt[0] = ___vname__##_ip_lo_ptr[___vname__##_ip_idxptr[___i__]]; \
  ___vname__##_ip_elt[1] = ___vname__##_ip_hi_ptr[___vname__##_ip_idxptr[___i__]]; 
  
 
#define RIPv4r_ELT_PTR_GET_HI(___vname__, ___i__ )\
  ___vname__##_ip_elt[1] = ___vname__##_ip_hi_ptr[___vname__##_ip_idxptr[___i__]]; 
  
 
#if 1
 
void
  ipv4r_bearch_intv_index_0_visit0(
      IPv4r_intvTree *tree,
     int             lo
    , int             hi
     
    , int            ipIntv_idx[2]
){
#ifdef BSEARCH_INTV_DBG
 
#endif

  IPv4 *tbl_ip_lo_ptr, *tbl_ip_hi_ptr, cmin, cmx;
  int  *tbl_ip_idxptr;
   
  int mid, lo1, hi1
    , lipIntv_idx[2], ripIntv_idx[2]
  ;
   
  tbl_ip_lo_ptr = tree->tbl_loPtr;
  tbl_ip_hi_ptr = tree->tbl_hiPtr;
  tbl_ip_idxptr = tree->idx_ptr;
   
   
  mid = lo + ( hi - lo )/2;
   
#ifdef BSEARCH_INTV_DBG
#endif
 
   
  if( (hi1 = mid -1 )>lo ){
 
     
    ipv4r_bearch_intv_index_0_visit0(tree, lo   , hi1, lipIntv_idx);
     
 
  }else{
#ifdef BSEARCH_INTV_DBG
#endif
 
     
    lipIntv_idx[0] = lo ;
    lipIntv_idx[1] = lo ;
     
    if( lo==hi1 ){
      tree->minmx_ptr[ lo  ]            = lipIntv_idx[0];
      tree->minmx_ptr[ lo + tree->nip ] = lipIntv_idx[1];
    }
     
  }

  if( (lo1 = mid + 1 )<hi ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s right %d %d\n", tree->depth, "", lo1, hi); 
#endif 
   
  ipv4r_bearch_intv_index_0_visit0(tree,lo1, hi   , ripIntv_idx);
   
 
  }else{
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s rleaf %d\n", tree->depth, "",  hi);
#endif
     
    ripIntv_idx[0] = hi ;
    ripIntv_idx[1] = hi ;
     
    if( hi==lo1 ){
      tree->minmx_ptr[ hi  ]            = ripIntv_idx[0];
      tree->minmx_ptr[ hi + tree->nip ] = ripIntv_idx[1];
    }
     
  } 

  ipIntv_idx[0] = lipIntv_idx[0];
   
  IPv4 lmx  = tbl_ip_hi_ptr[ tbl_ip_idxptr[ lipIntv_idx[1] ]];
  IPv4 rmx  = tbl_ip_hi_ptr[ tbl_ip_idxptr[ ripIntv_idx[1] ]];
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s ", tree->depth, "");RIP_ipv4_Rprintf_0(lmx);Rprintf("\n%*s ", tree->depth, "");RIP_ipv4_Rprintf_0(rmx);Rprintf("\n");  
#endif
   
  if(
    lmx > rmx
  ){
#ifdef BSEARCH_INTV_DBG 
Rprintf("%*s swap ", tree->depth, "");  
RIP_ipv4_Rprintf_0(lmx);Rprintf(" ");RIP_ipv4_Rprintf_0(rmx);Rprintf("\n"); 
#endif
    ipIntv_idx[1] = lipIntv_idx[1];
    cmx = lmx;
  }
  else{
 
 
    ipIntv_idx[1] = ripIntv_idx[1];
    cmx = rmx;
  }
   
   
  cmin = tbl_ip_lo_ptr[ tbl_ip_idxptr[ ipIntv_idx[0]  ]];
   
   
  IPv4 nmin = tbl_ip_lo_ptr[ tbl_ip_idxptr[ mid ]];
  IPv4 nmx  = tbl_ip_hi_ptr[ tbl_ip_idxptr[ mid ]];
  
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s ", tree->depth, "");RIP_ipv4_Rprintf_0(cmx);Rprintf("\n%*s ", tree->depth, "");RIP_ipv4_Rprintf_0(nmx);Rprintf("\n");
Rprintf("%*s min: ", tree->depth, ""); 
RIP_ipv4_Rprintf_0(cmin);Rprintf(" ");RIP_ipv4_Rprintf_0(nmin);Rprintf("\n");
#endif

   
  if(
    cmin > nmin
  ){
 
    ipIntv_idx[0] = mid;
  }
  if(
    cmx <  nmx
  ){
 
    ipIntv_idx[1] = mid;
  }
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s mx: %d \n", tree->depth, "", ipIntv_idx[1] );
Rprintf("%*s ", tree->depth, "");RIP_ipv4_Rprintf_0(tbl_ip_hi_ptr[ tbl_ip_idxptr[ ipIntv_idx[1] ]]);Rprintf("\n");
#endif
   
  tree->minmx_ptr[ mid  ]            = ipIntv_idx[0];
  tree->minmx_ptr[ mid + tree->nip ] = ipIntv_idx[1];
  
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s exit %d (%d %d) ", tree->depth, "", mid, lo, hi);
RIP_ipv4_Rprintf_0( tbl_ip_lo_ptr[tbl_ip_idxptr[tree->minmx_ptr[ mid ] ]] );Rprintf(" ");RIP_ipv4_Rprintf_0( tbl_ip_hi_ptr[tbl_ip_idxptr[tree->minmx_ptr[ mid + tree->nip ] ]] );Rprintf("\n");
tree->depth--;
#endif

   
  return ;
}
 
#endif

 
#if 1
 
SEXP
  ipv4r_bearch_intv_index_0(
      SEXP RipTbl
    , SEXP Ridx
){
   
  SEXP Rminmx;
  IPv4r_intvTree tree;
  int  *idx_ptr , *minmx_ptr, ipIntv_idx[2]={-1,-1}; 
  int  nprotected=0; 
   
  RIPv4r_SLOTS_GET( RipTbl ) 
   
  idx_ptr    = INTEGER(Ridx); 
   
  PROTECT( Rminmx = allocMatrix(INTSXP, RipTbl_nip, 2 ) ); 
  nprotected++; 
  minmx_ptr  = INTEGER(Rminmx); 
   
  tree.nip       = RipTbl_nip;
  tree.tbl_loPtr = RipTbl_ip_lo_ptr;
  tree.tbl_hiPtr = RipTbl_ip_hi_ptr;
  tree.idx_ptr   = idx_ptr;
  tree.minmx_ptr = minmx_ptr;
  RipTbl_ip_idxptr+=0;  
#ifdef BSEARCH_INTV_DBG
Rprintf("nip:%d %d %p\n", RipTbl_nip, tree.nip, &tree);
#endif  
tree.depth=-1;

  ipv4r_bearch_intv_index_0_visit0(
      &tree, 
     0, RipTbl_nip-1
     
    , ipIntv_idx
  );
   
  UNPROTECT(nprotected);
   
  return Rminmx;
}
#endif
  
 
int
  ipv4r_bearch_intv_ip_in_0_visit0(
      IPv4            x
    , int             lo
    , int             hi
    , IPv4r_intvTree *tree
){
   
  IPv4 *tbl_ip_lo_ptr, *tbl_ip_hi_ptr;
   
  int idx, mid, isleaf, ml=0,mr=0,m=0;
 
#ifdef BSEARCH_INTV_DBG
tree->depth++;
#endif
   
  if( lo>hi ){
 
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s leaf %d\n", tree->depth, "",  tree->depth);
tree->depth--;
#endif
    return 0;
  }
   
  mid    = lo + ( hi - lo )/2;
   
  isleaf = hi==mid;
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s lo:%d hi:%d mid:%d isleaf:%d\n", tree->depth, "", lo, hi, mid, isleaf);
#endif
   
  tbl_ip_lo_ptr = tree->tbl_loPtr;
  tbl_ip_hi_ptr = tree->tbl_hiPtr;
   
   
  int *tbl_ip_idxptr = tree->idx_ptr;
   
  RIPv4r_ELT_PTR_DCL( tbl, mid)
   
  idx = tree->minmx_ptr[ mid + tree->nip ] ;
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s idx:%d\n", tree->depth, "", idx);
#endif
   
  IPv4 mx = tbl_ip_hi_ptr[ tbl_ip_idxptr[ idx ]];
#ifdef BSEARCH_INTV_DBG
Rprintf( "%*s tbl-idx:%d\n", tree->depth, "", tbl_ip_idxptr[ idx ]);  
#endif
   
  if(
    ( x > mx )
  ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s stop\n", tree->depth, "");
tree->depth--;
#endif
    return 0;
  }
   
  if( 
    !isleaf  
  ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s left\n", tree->depth, "");
#endif
    ml = ipv4r_bearch_intv_ip_in_0_visit0(x, lo, mid -1L, tree);
  }
   
  if(
    Rippaddr_ipv4_in_ipv4r(x, tbl_ip_elt_ptr)
  ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s match %d %d\n", tree->depth, "", *tree->nmatch_acc, tree->nmatch);
#endif
     
    if( (*tree->nmatch_acc)==tree->nmatch){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s  realloc\n", tree->depth, "");
#endif
       
      int n = (int) ceil( ( (double) tree->nmatch )*1.6);
       
      if( ( tree->match_ptr = (int *) realloc(tree->match_ptr, n * sizeof(int)) )==NULL){
         
        error("realloc");
      }
Rprintf("realloc: %d %d\n", tree->nmatch, n);
      tree->nmatch = n;
    }
     
    tree->match_ptr[ *tree->nmatch_acc ] = tree->idx_ptr[mid];
     
    (*tree->nmatch_acc)++;
     
    m = 1;
  }
   
  if(
     
    (!isleaf) & (x >= tbl_ip_elt[0]) 
  ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s right\n", tree->depth, "");
#endif
    mr = ipv4r_bearch_intv_ip_in_0_visit0(x, mid+1L, hi, tree);
  }
  else{
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s !right\n", tree->depth, "");
#endif
  }
#ifdef BSEARCH_INTV_DBG
tree->depth--;
#endif
   
  return (ml | mr) | m;
}

 
___RIP_inline
void
  ipv4r_bearch_intv_index_0_realloc_0(
    IPv4r_intvTree *tree
){
  if( (*tree->nmatch_acc)==tree->nmatch){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s  realloc\n", tree->depth, "");
#endif
     
    int n = (int) ceil( ( (double) tree->nmatch )*1.6);
     
    if( ( tree->match_ptr = (int *) realloc(tree->match_ptr, n * sizeof(int)) )==NULL){
       
      error("realloc");
    }
Rprintf("realloc: %d %d\n", tree->nmatch, n);
    tree->nmatch = n;
  }
  return ;
}

 
#if 1
 
SEXP
  ipv4r_bearch_intv_ip_in_0(
      SEXP Rip
    , SEXP RipTbl
    , SEXP Ridx
    , SEXP Rminmx
    , SEXP Rnomatch
){
   
  SEXP Rmatch, Rmatch_ptr; 
  int  nomatch;
  int *nmatch_acc;
  int  nprotected=0; 
#ifdef BSEARCH_INTV_DBG
Rprintf("start:\n");   
#endif
   
  RIPv4_SLOTS_GET( Rip ) 
  RIPv4r_SLOTS_GET( RipTbl ) 
  RipTbl_nip+=0;
   
  int *idx_ptr    =  INTEGER(Ridx); 
  int *minmx_ptr  =  INTEGER(Rminmx); 
  nomatch    = *INTEGER(Rnomatch); 

  IPv4r_intvTree tree;
   
  tree.nip       = RipTbl_nip;
  tree.tbl_loPtr = RipTbl_ip_lo_ptr;
  tree.tbl_hiPtr = RipTbl_ip_hi_ptr;
  tree.idx_ptr   = idx_ptr;
  tree.minmx_ptr = minmx_ptr;
   
  tree.nmatch = (int) ceil( ( (double) Rip_nip )*1.6);;

  PROTECT( Rmatch_ptr = allocVector(INTSXP, Rip_nip+1 ) ); 
  nprotected++; 
  nmatch_acc    = (int*) INTEGER( Rmatch_ptr );
  nmatch_acc[0] = 0;
   
  tree.nmatch_acc = nmatch_acc;
   
  if( ( tree.match_ptr = (int*) malloc( sizeof(int) * tree.nmatch) )==NULL ){
    error("malloc");
  }
   
  tree.depth=-1;
#ifdef BSEARCH_INTV_DBG
Rprintf("iter:%d\n", tree.nmatch);   
#endif
   
  RipTbl_ip_idxptr+=0;  
   
  for( int i=0 ; i<Rip_nip ; i++ ){
     
    int tmp;
     
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER) ){ 

      tmp             = *tree.nmatch_acc++;
      *tree.nmatch_acc = tmp;
      ipv4r_bearch_intv_index_0_realloc_0(&tree);
      tree.match_ptr[ *tree.nmatch_acc ] =  nomatch;
      (*tree.nmatch_acc)++;

      i++;
    }
     
    if( (i>= Rip_nip) ) break;
#ifdef BSEARCH_INTV_DBG
Rprintf("  i:%d\n", i); 
#endif    
     
    tmp             = *tree.nmatch_acc++;
     
   *tree.nmatch_acc = tmp;
     
    RIPv4_ELT_PTR_DCL( Rip, i)
     
    int m;
     
    m = ipv4r_bearch_intv_ip_in_0_visit0(
      Rip_ip_elt_ptr
      , 0, RipTbl_nip-1
      , &tree
    );
     
    if( m==0 ){
 
      ipv4r_bearch_intv_index_0_realloc_0(&tree);
      tree.match_ptr[ *tree.nmatch_acc ] =  nomatch;
      (*tree.nmatch_acc)++;
    }
  }
#ifdef BSEARCH_INTV_DBG
Rprintf("iter:%d\n", tree.nmatch);   
#endif
   
  PROTECT( Rmatch = allocVector(INTSXP, *tree.nmatch_acc ) ); 
  nprotected++; 
  int *midx_ptr  = INTEGER( Rmatch ); 
#ifdef BSEARCH_INTV_DBG
Rprintf("acc:%d\n", *tree.nmatch_acc);  
#endif 
 
  midx_ptr = memcpy( midx_ptr , tree.match_ptr, *tree.nmatch_acc * sizeof(int) );  
 
   
  SEXP Res = duplicate(Rip);
   
  setAttrib(Res, install("ptr"), Rmatch_ptr);
  setAttrib(Res, install("midx"), Rmatch);
   
  UNPROTECT(nprotected);
   
  return Res;
}
#endif

 
#if 1
 
___RIP_inline
int Rippaddr_ipv4r_overlap_ipv4r(IPv4* ip4r1, IPv4 *ip4r2){
   
  return ( 
       ip4r1[0] <= ip4r2[1]
    && ip4r1[1] >= ip4r2[0]
  );
}
 
int
  ipv4r_bearch_intv_ip4r_in_0_visit0(
      IPv4           *x
    , int             lo
    , int             hi
    , IPv4r_intvTree *tree
){
   
  IPv4 *tbl_ip_lo_ptr, *tbl_ip_hi_ptr;
   
  int idx, mid, isleaf, ml=0,mr=0,m=0;
 
#ifdef BSEARCH_INTV_DBG
tree->depth++;
#endif
   
  if( lo>hi ){
 
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s leaf %d\n", tree->depth, "",  tree->depth);
tree->depth--;
#endif
    return 0;
  }
   
  mid    = lo + ( hi - lo )/2;
   
  isleaf = hi==mid;
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s lo:%d hi:%d mid:%d isleaf:%d\n", tree->depth, "", lo, hi, mid, isleaf);
#endif
   
  tbl_ip_lo_ptr = tree->tbl_loPtr;
  tbl_ip_hi_ptr = tree->tbl_hiPtr;
   
   
  int *tbl_ip_idxptr = tree->idx_ptr;
   
  RIPv4r_ELT_PTR_DCL( tbl, mid)
   
  idx = tree->minmx_ptr[ mid ] ;
  IPv4 mn = tbl_ip_lo_ptr[ tbl_ip_idxptr[ idx ]];
   
  idx = tree->minmx_ptr[ mid + tree->nip ] ;
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s idx:%d\n", tree->depth, "", idx);
#endif
  IPv4 mx = tbl_ip_hi_ptr[ tbl_ip_idxptr[ idx ]];
#ifdef BSEARCH_INTV_DBG
Rprintf( "%*s tbl-idx:%d\n", tree->depth, "", tbl_ip_idxptr[ idx ]);  
Rprintf( "%*s ", tree->depth, ""); RIP_ipv4_Rprintf_0(tbl_ip_elt[0]);printf("-");RIP_ipv4_Rprintf_0(tbl_ip_elt[1]);printf("\n");
Rprintf( "%*s ", tree->depth, ""); RIP_ipv4_Rprintf_0(mn);printf("-");RIP_ipv4_Rprintf_0(mx);printf("\n");
#endif
   
  if(
     
    ( RIPv4r_PTR_LO(x) > mx ) | ( RIPv4r_PTR_HI(x) < mn )
  ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s stop\n", tree->depth, "");
tree->depth--;
#endif
    return 0;
  }
   
  if( 
    !isleaf   
  ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s left\n", tree->depth, "");
#endif
    ml = ipv4r_bearch_intv_ip4r_in_0_visit0(x, lo, mid -1L, tree);
  }
#ifdef BSEARCH_INTV_DBG
 
#endif
   
  if(
    Rippaddr_ipv4r_overlap_ipv4r(x, tbl_ip_elt_ptr)
  ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s match %d %d\n", tree->depth, "", *tree->nmatch_acc, tree->nmatch);
#endif
     
    if( (*tree->nmatch_acc)==tree->nmatch){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s  realloc\n", tree->depth, "");
#endif
       
      int n = (int) ceil( ( (double) tree->nmatch )*1.6);
       
      if( ( tree->match_ptr = (int *) realloc(tree->match_ptr, n * sizeof(int)) )==NULL){
         
        error("realloc");
      }
Rprintf("realloc: %d %d\n", tree->nmatch, n);
      tree->nmatch = n;
    }
     
    tree->match_ptr[ *tree->nmatch_acc ] = tree->idx_ptr[mid];
     
    (*tree->nmatch_acc)++;
     
    m = 1;
  }
   
  if(
     
    (!isleaf)  
  ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s right\n", tree->depth, "");
#endif
    mr = ipv4r_bearch_intv_ip4r_in_0_visit0(x, mid+1L, hi, tree);
  }
  else{
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s !right\n", tree->depth, "");
#endif
  }
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s m: %d %d %d \n", tree->depth, "", m, ml, mr);
tree->depth--;
#endif
   
  return ( ml | mr ) | m;
}
#endif  

 
#if 1
 
SEXP
  ipv4r_bearch_intv_ipv4r_in_0(
      SEXP Rip
    , SEXP RipTbl
    , SEXP Ridx
    , SEXP Rminmx
    , SEXP Rnomatch
){
   
  SEXP Rmatch, Rmatch_ptr; 
  int  nomatch;
  int *nmatch_acc;
  int  nprotected=0; 
#ifdef BSEARCH_INTV_DBG
Rprintf("start:\n");   
#endif
   
  RIPv4r_SLOTS_GET( Rip ) 
  RIPv4r_SLOTS_GET( RipTbl ) 
  RipTbl_nip+=0;
   
  int *idx_ptr    =  INTEGER(Ridx); 
  int *minmx_ptr  =  INTEGER(Rminmx); 
  nomatch    = *INTEGER(Rnomatch); 

  IPv4r_intvTree tree;
   
  tree.nip       = RipTbl_nip;
  tree.tbl_loPtr = RipTbl_ip_lo_ptr;
  tree.tbl_hiPtr = RipTbl_ip_hi_ptr;
  tree.idx_ptr   = idx_ptr;
  tree.minmx_ptr = minmx_ptr;
   
  tree.nmatch = (int) ceil( ( (double) Rip_nip )*1.6);;

  PROTECT( Rmatch_ptr = allocVector(INTSXP, Rip_nip+1 ) ); 
  nprotected++; 
  nmatch_acc    = (int*) INTEGER( Rmatch_ptr );
  nmatch_acc[0] = 0;
   
  tree.nmatch_acc = nmatch_acc;
   
  if( ( tree.match_ptr = (int*) malloc( sizeof(int) * tree.nmatch) )==NULL ){
    error("malloc");
  }
   
  tree.depth=-1;
#ifdef BSEARCH_INTV_DBG
Rprintf("iter:%d\n", tree.nmatch);   
#endif
   
  RipTbl_ip_idxptr+=0;  
   
  for( int i=0 ; i<Rip_nip ; i++ ){
     
    int tmp;
     
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER) ){ 

      tmp             = *tree.nmatch_acc++;
      *tree.nmatch_acc = tmp;
      ipv4r_bearch_intv_index_0_realloc_0(&tree);
      tree.match_ptr[ *tree.nmatch_acc ] =  nomatch;
      (*tree.nmatch_acc)++;

      i++;
    }
     
    if( (i>= Rip_nip) ) break;
#ifdef BSEARCH_INTV_DBG
Rprintf("  i:%d\n", i); 
#endif    
 
     
    tmp             = *tree.nmatch_acc++;
     
   *tree.nmatch_acc = tmp;
     
    RIPv4r_ELT_PTR_DCL( Rip, i)
     
    int m;
     
    m = ipv4r_bearch_intv_ip4r_in_0_visit0(
      Rip_ip_elt_ptr
      , 0, RipTbl_nip-1
      , &tree
    );
     
    if( m==0 ){
#ifdef BSEARCH_INTV_DBG
Rprintf("  i:%d nomatch\n", i);  
#endif
      ipv4r_bearch_intv_index_0_realloc_0(&tree);
      tree.match_ptr[ *tree.nmatch_acc ] =  nomatch;
      (*tree.nmatch_acc)++;
    }
  }
#ifdef BSEARCH_INTV_DBG
Rprintf("iter:%d\n", tree.nmatch);   
#endif
   
  PROTECT( Rmatch = allocVector(INTSXP, *tree.nmatch_acc ) ); 
  nprotected++; 
  int *midx_ptr  = INTEGER( Rmatch ); 
#ifdef BSEARCH_INTV_DBG
Rprintf("acc:%d\n", *tree.nmatch_acc);  
#endif 
 
  midx_ptr = memcpy( midx_ptr , tree.match_ptr, *tree.nmatch_acc * sizeof(int) );  
 
  free(tree.match_ptr); 
   
  SEXP Res = duplicate(Rip);
   
  setAttrib(Res, install("ptr"), Rmatch_ptr);
  setAttrib(Res, install("midx"), Rmatch);
   
  UNPROTECT(nprotected);
   
  return Res;
}
#endif

#define RIP_HASH_DEF(___group__, ___IPv__)
  #define RIP_htb_nh RIP_##___group__##_##___IPv__##_htb_nh
 
RIP_HASH_DEF(cache, IPv4)
 
#define K1 RIP_CACHE_NVAL   
#define K2 7  
 
 
int DBLhash1(int key){ 
    return (key % K1 ); 
} 
 
int DBLhash2(int key){ 
    return (K2 - (key % K2)); 
     
} 
 
 
int
  Rip_cache_ipv4_init_0_0(
    void
){
   
  RIP_cache_ipv4_nval  = RIP_CACHE_NVAL;
   
  if (  
     
    ( RIP_cache_ipv4_val = (IPv4 *) malloc(RIP_cache_ipv4_nval * sizeof (int)) )== NULL
     
  ){
    return 1;
  }
   
  RIP_cache_ipv4_val_i = 0;
   
  if (  
     ( RIP_cache_ipv4_htb = (int *) calloc(RIP_cache_ipv4_nval , sizeof (int)) )== NULL
     
  ){
    return 1;
  }
   
  if (  
     ( RIPv4_h_tb = (RIPv4_h *) calloc(RIP_cache_ipv4_nval , sizeof (RIPv4_h)) )== NULL
  ){
    return 1;
  }
   
  RIP_cache_ipv4_htb_shift = 32 - ceil(log2(RIP_cache_ipv4_nval));
  RIP_cache_ipv4_htb_nh    = 0;
  RIP_cache_ipv4_ins_ncoll  = 0;
  RIP_cache_ipv4_lkup_ncoll = 0;
 
Rprintf("nval:%d shift:%d\n", RIP_cache_ipv4_nval, RIP_cache_ipv4_htb_shift);
   
  return 0;
}
 
 
SEXP
  Rip_cache_ipv4_Rsummary_0_0(
    void
){
   
  SEXP Rsummary = PROTECT( allocVector(INTSXP, 4 ) );
  int *summary = INTEGER(Rsummary);
  Rprintf("nval:%d\n", RIP_cache_ipv4_nval) ;
  Rprintf("nh  :%d\n", RIP_cache_ipv4_htb_nh) ;
   
  summary[0] = RIP_cache_ipv4_nval;
  summary[1] = RIP_cache_ipv4_htb_nh;
  summary[2] = RIP_cache_ipv4_ins_ncoll;
  summary[3] = RIP_cache_ipv4_lkup_ncoll;
   
   
  UNPROTECT(1);
  return Rsummary;
}

int modulo(int a,int b,int c){
long long x=1,y=a;  
  while(b > 0){
    if(b%2 == 1){
      x=(x*y)%c;
    }
    y = (y*y)%c;  
    b /= 2;
  }
  return x%c;
}

long long mulmod(long long a,long long b,long long c){
  long long x = 0,y=a%c;
  while(b > 0){
    if(b%2 == 1){
      x = (x+y)%c;
    }
    y = (y*2)%c;
    b /= 2;
  }
  return x%c;
}

int Miller(long long p,int iteration){
  if(p<2){
    return 0;
  }
  if(p!=2 && p%2==0){
    return 0;
  }
  long long s=p-1;
   
  while(s%2==0){
    s/=2;
  }
  for(int i=0;i<iteration;i++){
     
     
    long long a,temp=s;
    GetRNGstate();
    a=unif_rand()*RAND_MAX;
    PutRNGstate();
    a=a%(p-1)+1;
     
    long long mod=modulo(a,temp,p);
    while(temp!=p-1 && mod!=1 && mod!=p-1){
      mod=mulmod(mod,mod,p);  
      temp *= 2;
    }
    if(mod!=p-1 && temp%2==0){
      return 0;
    }
  }
  return 1;
}
 
 
SEXP nextPrime_MillerRabin(SEXP Rx){
  int x = INTEGER(Rx)[0], i;
  if(x%2==0)
    i = x+1;
  else i = x;
  for(;i<2*x;i+=2) 
      if(Miller(i,20)) 
          break;  
  return ScalarInteger(i);
}

#define RIP_h32dblh_HASH_INIT(___hip__, ___htb_sz__, ___RM__) \
  RIP_h32dblh ___hip__; \
  int ___htb_sz__ = INTEGER(___RM__)[0]; \
  ___hip__.M1     = INTEGER(___RM__)[1];  \
  ___hip__.M2     = INTEGER(___RM__)[2]; 

#define RIP_h64dblh_lemire_HASH_INIT(___hip__, ___htb_sz__, ___hparm__) \
  RIP_h64dblh_lemire ___hip__; \
  int ___htb_sz__ = INTEGER(___hparm__)[0]; \
  ___hip__.a0     = 0x65d200ce55b19ad8L;   \
  ___hip__.b0     = 0x4f2162926e40c299L;   \
  ___hip__.c0     = 0x162dd799029970f8L;   \
  ___hip__.M2     = INTEGER(___hparm__)[1]; 

#define RIP_h128dblh_lemire_HASH_INIT(___hip__, ___htb_sz__, ___hparm__) \
  RIP_h128dblh_lemire ___hip__; \
  int ___htb_sz__ = INTEGER(___hparm__)[0]; \
  ___hip__.a0     = 0x65d200ce55b19ad8L;   \
  ___hip__.b0     = 0x4f2162926e40c299L;   \
  ___hip__.c0     = 0x162dd799029970f8L;   \
  ___hip__.a1     = 0x68b665e6872bd1f4L;   \
  ___hip__.b1     = 0xb6cfcf9d79b51db2L;   \
  ___hip__.c1     = 0x7a2b92ae912898c2L;   \
  ___hip__.M2     = INTEGER(___hparm__)[1]; 
  
 
#define RIP_h32dblh_HASH_SET(___hip__, ___Rhtb__, ___Rip__) \
  setAttrib( ___Rhtb__, install("nh"), ScalarInteger(___hip__.h.htb_nh) ); \
  setAttrib( ___Rhtb__, install("M1"), ScalarInteger(___hip__.M1) ); \
  setAttrib( ___Rhtb__, install("M2"), ScalarInteger(___hip__.M2) ); \
  setAttrib( ___Rip__##_ipv4, install("htb"), Rhtb); \
  ___Rip__ = SET_SLOT(___Rip__, Rip_ipv4Sym, ___Rip__##_ipv4 ); 
  
 
#define RIP_h64dblh_lemire_HASH_SET(___hip__, ___Rhtb__, ___Rip__) \
  setAttrib( ___Rhtb__, install("nh"), ScalarInteger(___hip__.h.htb_nh) ); \
   \
  uint64_t *p =  &___hip__.a0  ;  \
  setAttrib( ___Rhtb__, install("a0"), ScalarReal(  *(double*) p ) ); \
  p =  &___hip__.b0  ;  \
  setAttrib( ___Rhtb__, install("b0"), ScalarReal( *(double*) p ) ); \
  p =  &___hip__.c0  ;  \
  setAttrib( ___Rhtb__, install("c0"), ScalarReal( *(double*) p ) ); \
  setAttrib( ___Rhtb__, install("M2"), ScalarInteger(___hip__.M2) ); \
  setAttrib( ___Rip__##_ipr, install("htb"), Rhtb); \
  ___Rip__ = SET_SLOT(___Rip__, Rip_ipv4rSym, ___Rip__##_ipr ); 

#define RIP_h128dblh_lemire_HASH_SET(___hip__, ___Rhtb__, ___Rip__) \
  setAttrib( ___Rhtb__, install("nh"), ScalarInteger(___hip__.h.htb_nh) ); \
   \
  uint64_t *p =  &___hip__.a0  ;  \
  setAttrib( ___Rhtb__, install("a0"), ScalarReal(  *(double*) p ) ); \
  p =  &___hip__.b0  ;  \
  setAttrib( ___Rhtb__, install("b0"), ScalarReal( *(double*) p ) ); \
  p =  &___hip__.c0  ;  \
  setAttrib( ___Rhtb__, install("c0"), ScalarReal( *(double*) p ) ); \
  p =  &___hip__.a1  ;  \
  setAttrib( ___Rhtb__, install("a1"), ScalarReal(  *(double*) p ) ); \
  p =  &___hip__.b1  ;  \
  setAttrib( ___Rhtb__, install("b1"), ScalarReal( *(double*) p ) ); \
  p =  &___hip__.c1  ;  \
  setAttrib( ___Rhtb__, install("c1"), ScalarReal( *(double*) p ) ); \
  setAttrib( ___Rhtb__, install("M2"), ScalarInteger(___hip__.M2) ); \
  setAttrib( ___Rip__##_ipv6, install("htb"), Rhtb); \
  ___Rip__ = SET_SLOT(___Rip__, Rip_ipv6Sym, ___Rip__##_ipv6 ); 

#define RIP_h32dblh_LOOKUP_INIT(___hip__, ___htb_sz__, ___Rhtb__) \
  RIP_h32dblh  ___hip__; \
  int ___htb_sz__ = LENGTH(___Rhtb__); \
  ___hip__.M1     = INTEGER(getAttrib( ___Rhtb__, install("M1")))[0]; \
  ___hip__.M2     = INTEGER(getAttrib( ___Rhtb__, install("M2")))[0]; 
  
 
#define RIP_h64dblh_lemire_LOOKUP_INIT(___hip__, ___htb_sz__, ___Rhtb__) \
  RIP_h64dblh_lemire  ___hip__; \
  int ___htb_sz__ = LENGTH(___Rhtb__); \
  ___hip__.a0     = *(uint64_t *) REAL(getAttrib( ___Rhtb__, install("a0"))); \
  ___hip__.b0     = *(uint64_t *) REAL(getAttrib( ___Rhtb__, install("b0"))); \
  ___hip__.c0     = *(uint64_t *) REAL(getAttrib( ___Rhtb__, install("c0"))); \
  ___hip__.M2     = INTEGER(getAttrib( ___Rhtb__, install("M2")))[0]; 
  
 
#define RIP_h128dblh_lemire_LOOKUP_INIT(___hip__, ___htb_sz__, ___Rhtb__) \
  RIP_h128dblh_lemire  ___hip__; \
  int ___htb_sz__ = LENGTH(___Rhtb__); \
  ___hip__.a0     = *(uint64_t *) REAL(getAttrib( ___Rhtb__, install("a0"))); \
  ___hip__.b0     = *(uint64_t *) REAL(getAttrib( ___Rhtb__, install("b0"))); \
  ___hip__.c0     = *(uint64_t *) REAL(getAttrib( ___Rhtb__, install("c0"))); \
  ___hip__.a1     = *(uint64_t *) REAL(getAttrib( ___Rhtb__, install("a1"))); \
  ___hip__.b1     = *(uint64_t *) REAL(getAttrib( ___Rhtb__, install("b1"))); \
  ___hip__.c1     = *(uint64_t *) REAL(getAttrib( ___Rhtb__, install("c1"))); \
  ___hip__.M2     = INTEGER(getAttrib( ___Rhtb__, install("M2")))[0]; 

___RIP_inline int RIP_h_DBLhash1(RIP_h32dblh  *hip, int key) { 
    return (key % hip->M1); 
} 
 
___RIP_inline int RIP_h_DBLhash2(RIP_h32dblh  *hip, int key){ 
    return (hip->M2 - (key % hip->M2)); 
     
} 
 
 
___RIP_inline int RIP_hfn_h64dblh1_0(RIP_h32dblh  *hip, IPv4* key){ 
   
  return (int)(*(uint64_t*) key % hip->M1);
} 
 
___RIP_inline int RIP_hfn_h64dblh2_0(RIP_h32dblh  *hip, IPv4* key){ 
    return (hip->M2 - (*(uint64_t*) key % hip->M2)); 
     
} 
 
uint32_t reduce(uint32_t x, uint32_t N) {
  return ((uint64_t) x * (uint64_t) N) >> 32 ;
}

___RIP_inline int RIP_hfn_h64dblh1_lemire0(RIP_h64dblh_lemire  *hip, uint64_t key){ 
 
  int lo = (int) key;
  int hi = (int) ( key >> 32 );
  return (int)(
     
    reduce( ( hip->a0 * lo + hip->b0 * hi + hip->c0 ) , hip->h.htb_sz )
  ); 
} 
 
___RIP_inline int RIP_hfn_h64dblh2_lemire0(RIP_h64dblh_lemire  *hip, uint64_t key){ 
    return (hip->M2 - (key % hip->M2)); 
     
} 
 
 
___RIP_inline int RIP_hfn_h128dblh1_lemire0(RIP_h128dblh_lemire  *hip, uint64_t* key){ 
 
  int lo0 = (int)   key[0];
  int hi0 = (int) ( key[0] >> 32 );
  int lo1 = (int)   key[1];
  int hi1 = (int) ( key[1] >> 32 );
  return (int)(
     
    reduce( 
      ( 
          hip->a0 * lo0 + hip->b0 * hi0 
        + hip->a1 * lo1 + hip->b1 * hi1 
        + hip->c0 
      ) 
      , hip->h.htb_sz 
    )
  ); 
} 
 
 
#if 0
 
___RIP_inline uint32_t Rippaddr_ipv6_mod15( uint64_t *a ) {
   
  uint64_t m[2], b[2];
  m[0] = 0;
   
  Rippaddr_ipv6_rshift( a, 16L, b);
  m[1] = 0xFFFF;
  Rippaddr_ipv6_and(a, m, a);
  Rippaddr_ipv6_add_ipv6( a,  b, a);
   
  Rippaddr_ipv6_rshift( a, 8L, b);
  m[1] = 0xFF;
  Rippaddr_ipv6_and(a, m, a);
  Rippaddr_ipv6_add_ipv6( a,  b, a);
   
  Rippaddr_ipv6_rshift( a, 4L, b);
  m[1] = 0xF;
  Rippaddr_ipv6_and(a, m, a);
  Rippaddr_ipv6_add_ipv6( a,  b, a);
   
  m[1] = 15;
  if(
    Ripaddr_ipv6_cmp_lt( a, m)
  ){
    return (int) a[1];
  }
   
  m[1] = 15L*2;
  if(
    Ripaddr_ipv6_cmp_lt( a, m)
  ){
    Rippaddr_ipv6_sub_int64(a, 15L, a);
    return (int) a[1];
  }
   
  Rippaddr_ipv6_sub_int64(a, 15L*2, a);
  return (int) a[1];
}
 
SEXP Rippaddr_ipv6_mod15_call(SEXP Rip){
   
  int nprotected=0;
   
  RIPv6_SLOTS_GET( Rip )
   
  RIPv6_ELT_PTR_DCL( Rip,0 )
   
  int rem = Rippaddr_ipv6_mod15(Rip_ip_elt_ptr);
   
  UNPROTECT(nprotected);
   
  return ScalarInteger(rem);
}
#endif

___RIP_inline int RIP_hfn_h128dblh2_lemire0(RIP_h128dblh_lemire  *hip, uint64_t *key){ 
   
   
  int a = key[0] ;
  a     = ((a<<5) - a);
  int b = key[0] >> 16;
  b     = ((b<<5) - b);
  a    ^= b;

  return ( ( a % K2 ) +1 ); 
} 

___RIP_inline
int
  Rip_h32dblh_csearch_0_0(
      RIP_h32dblh  *hip
    , IPv4          ip
    , int          *hidx
){
   
  int m=-1, nprobes=0;
   
  int  *htb       = hip->h.htb;
   
  IPv4 *iptb      = (IPv4*) hip->h.iptb;

  int  h  = RIP_h_DBLhash1(hip, ip);
 
   
  if(
    ( htb[h]>0 ) && ( m = ( iptb[ htb[h] -1 ] != ip ) )
  ){
     
    int  h0 = h;
    int  h1 = RIP_h_DBLhash2(hip, ip); 
     
    nprobes++; 
     
    do{
      h = (h0 + nprobes * h1) % hip->h.htb_sz; 
      nprobes++; 
       
    }while (
       (  htb[h]>0 ) && ( m = ( iptb[ htb[h] -1 ] != ip ) )
    );
  }
   
  *hidx =h;

  m =  htb[h]>0;

#ifdef RIP_HASH_DBG
  hip->h.ncoll +=nprobes;
#endif
   
  return m;
}

SEXP
  Rip_cache_ipv4_load_0_1(
    SEXP Rip, SEXP Rcache, SEXP Rhash
){
   
  SEXP Res, Reshash;
   
  int nprotected=0, hout=0, *hptr;

  RIPv4_SLOTS_GET( Rip )
   
  RIPv4cache_RIP_ALLOC(Res, Rip_nip)
  Res_nip+=0;
   
  SEXP Res_Rcache = Rcache;
  RIPv4cache_HASH_DCL(Res)
  RIPv4cache_HASH_ENV_GET( Res, Rcache)
  RIPv4cache_HASH_STRUCT_SET( Res, Rcache)

  if( INTEGER(Rhash)[0] ){
    hout=1;
    PROTECT(Reshash = allocVector(INTSXP, Rip_nip ) );nprotected++;
    hptr      = INTEGER(Reshash);
  }

  for( int i=0 ; i<Rip_nip; i++ ){ 
    int rc, hidx;

    if( (Rip_ip_idxptr[i]!=NA_INTEGER) ){
      RIPv4_ELT_PTR_DCL(Rip, i)
   
       
      if(
        ( rc = Rip_h32dblh_csearch_0_0(&Res_hip, Rip_ip_elt_ptr, &hidx) )==0  
      ){
   
         
        if( Res_hip.h.htb_nh >= Res_hip.h.htb_sz ) error("full hash\n");    
         
        Res_hip.h.htb[hidx] = Res_hip.h.htb_nh +1;  
        if( hout ) hptr[i] = hidx;

        Res_ip_idxptr[i] = Res_hip.h.htb[hidx] ;  
         
        ((IPv4*)Res_hip.h.iptb)[Res_hip.h.htb_nh] = Rip_ip_elt_ptr;
         
         
        Res_hip.h.htb_nh++;
      }
      else if( rc==1){
         
         
        Res_ip_idxptr[i] = Res_hip.h.htb[hidx] ; 
        if( hout ) hptr[i] = hidx;
      }
    }else{
      Res_ip_idxptr[i]= NA_INTEGER;  
      if( hout ) hptr[i] = NA_INTEGER;
    }
  }

  RIPv4cache_SLOTS_SET( Res )
  if( hout )  Res = SET_SLOT(Res, install("hash"), Reshash );
   
  UNPROTECT(nprotected);
  return Res;
}

SEXP
  Rip_cache_ipv4_load_0_0(
    SEXP Rip, SEXP Rcache
){
   
  SEXP Rhtb, Rhip, Rh, Res;
  int htb_sz, nh, nprotected=0;

  PROTECT(Rhtb   = findVarInFrame( Rcache, install("htb") ) );
  PROTECT(Rhip   = findVarInFrame( Rcache, install("hip") ) );
  PROTECT(Rh     = findVarInFrame( Rcache, install("h") ) );
  nh = INTEGER(findVarInFrame( Rcache, install("nh") ) )[0];
  nprotected+=3;
  htb_sz = LENGTH(Rhtb);
   
  RIPv4_SLOTS_GET( Rip )
   
  PROTECT(Res = allocVector(INTSXP, Rip_nip ) );nprotected++;
  int *resptr      = INTEGER(Res);

  RIP_h32dblh  hip;
  hip.M1 = INTEGER(Rh)[1];  
  hip.M2 = INTEGER(Rh)[2];
 
   
  hip.h.htb        = INTEGER(Rhtb);
  hip.h.htb_sz     = htb_sz;
  hip.h.htb_nh     = nh;
  hip.h.iptb       = (void*) INTEGER(Rhip);
   
#ifdef RIP_HASH_DBG
  hip.h.ncoll      = 0;
#endif  
  for( int i=0 ; i<Rip_nip; i++ ){ 
    int rc, hidx;
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER) ){ resptr[i]= NA_INTEGER; i++; } 
    if( i>= Rip_nip) break;

    RIPv4_ELT_PTR_DCL(Rip, i)
 
     
    if(
      ( rc = Rip_h32dblh_csearch_0_0(&hip, Rip_ip_elt_ptr, &hidx) )==0  
    ){
 
       
      if( hip.h.htb_nh >= hip.h.htb_sz ) error("full hash\n");    
       
      hip.h.htb[hidx] = hip.h.htb_nh +1;  
       
      resptr[i] = hip.h.htb[hidx] ;  
       
      ((IPv4*)hip.h.iptb)[hip.h.htb_nh] = Rip_ip_elt_ptr;
       
       
      hip.h.htb_nh++;
    }
    else if( rc==1){
      resptr[i] = hip.h.htb[hidx] ;  
    }
  }
#ifdef RIP_HASH_DBG
 
#endif
   
  INTEGER(findVarInFrame( Rcache, install("nh") ) )[0] = hip.h.htb_nh;
   
  UNPROTECT(nprotected);
  return Res;
}

#if 1
___RIP_inline
int
  Rip_h32dblh_search_0_0(
      RIP_h32dblh  *hip
    , IPv4          ip
    , int          *hidx
){
   
  int m=-1, nprobes=0;
   
  int  *htb       = hip->h.htb;
  int  *iptb_idx  = hip->h.iptb_idx;
  IPv4 *iptb      = (IPv4*) hip->h.iptb;
 
   
  int  h  = RIP_h_DBLhash1(hip, ip);

  if(
    ( htb[h]>0 ) && ( m = ( iptb[ 
      iptb_idx[ htb[h] -1 ] 
      ] != ip ) )
  ){
     
    int  h0 = h;
    int  h1 = RIP_h_DBLhash2(hip, ip); 
       
      nprobes++; 
#if 0   
      h = (h0 + nprobes * h1) % hip->h.htb_sz; 

    while (
       (  htb[h]>0 ) && ( m = ( iptb[ 
      iptb_idx[ htb[h] - 1 ] 
      ] != ip ) )
    ){

      nprobes++; 
      h = (h0 + nprobes * h1) % hip->h.htb_sz; 
       
     
    };
#else
    do{
      h = (h0 + nprobes * h1) % hip->h.htb_sz; 
      nprobes++; 
       
    }while (
       (  htb[h]>0 ) && ( m = ( iptb[ 
      iptb_idx[ htb[h] - 1 ] 
      ] != ip ) )
    );
#endif

  }
   
  *hidx =h;

  m =  htb[h]>0;

#ifdef RIP_HASH_DBG
  hip->h.ncoll +=nprobes;
#endif
   
  return m;
}

___RIP_inline int
  RIP_h64dblh_search_0_0(
      RIP_h32dblh  *hip
    , IPv4                *ip  
    , int                 *hidx
){
   
  int m=-1, nprobes=0;
   
   
  int      *htb       = hip->h.htb;
  int      *iptb_idx  = hip->h.iptb_idx;
   
  IPv4 *iptb      = (IPv4*) hip->h.iptb;

  int  h  = RIP_hfn_h64dblh1_0(hip, ip);
 
   
  IPv4 iptb_val[2] = {  
    iptb[ iptb_idx[ htb[h] -1 ] ]
    , iptb[ iptb_idx[ htb[h] -1  ] + hip->h.ip_len] 
  };

  if(
    ( htb[h]>0 ) && ( 
      Ripaddr_ipv4r_cmp_neq(iptb_val, ip)  
    ) 
  ){
     
    int  h0 = h;
    int  h1 = RIP_hfn_h64dblh2_0(hip, ip); 
     
    nprobes++;
     
    do{
      h = (h0 + nprobes * h1) % hip->h.htb_sz; 
      nprobes++; 

      iptb_val[0] = iptb[ iptb_idx[ htb[h] -1 ] ];
      iptb_val[1] = iptb[ iptb_idx[ htb[h] -1  ] + hip->h.ip_len] ;
       
      
    }while (
      (  htb[h]>0 ) && ( 
        Ripaddr_ipv4r_cmp_neq(iptb_val, ip)  
      )
    );
  }
   
 *hidx = h;
  m    =  htb[h]>0;
 
#ifdef RIP_HASH_DBG
  hip->h.ncoll +=nprobes;
#endif
   
  return m;
}

___RIP_inline int
  RIP_h64dblh_lemire_search_0_0(
      RIP_h64dblh_lemire  *hip
    , IPv4                *ip0
    , int                 *hidx
){
   
  int m=-1, nprobes=0;
   
  uint64_t ip = *(uint64_t*)ip0;

  int      *htb       = hip->h.htb;
  int      *iptb_idx  = hip->h.iptb_idx;
   
  IPv4 *iptb      = (IPv4*) hip->h.iptb;

  int  h  = RIP_hfn_h64dblh1_lemire0(hip, ip);

  if( ( htb[h]>0 ) ){
     
    uint64_t iptb_val = ( (uint64_t) iptb[ iptb_idx[ htb[h] -1  ] + hip->h.ip_len] ) << 32 | (uint64_t) iptb[ iptb_idx[ htb[h] -1 ] ];

  if(
    ( iptb_val!=ip )
  ){
     
    int  h0 = h;
    int  h1 = RIP_hfn_h64dblh2_lemire0(hip, ip); 
     
    nprobes++;
     
    do{
      h = (h0 + nprobes * h1) % hip->h.htb_sz; 
      nprobes++; 

      iptb_val = ( (uint64_t) iptb[ iptb_idx[ htb[h] -1 ] + hip->h.ip_len ] ) << 32 | (uint64_t) iptb[ iptb_idx[ htb[h] -1 ] ];

    }while (
      (  htb[h]>0 ) && ( iptb_val!=ip )
    );
  }
  }
   
* hidx = h;
  m    =  htb[h]>0;
 
#ifdef RIP_HASH_DBG
  hip->h.ncoll +=nprobes;
#endif
   
  return m;
}

#if 1
___RIP_inline int
  RIP_h128dblh_lemire_search_0_0(
      RIP_h128dblh_lemire  *hip
    , uint64_t             *ip
    , int                  *hidx
){
   
  int m=-1, nprobes=0;
   
  int      *htb       = hip->h.htb;
  int      *iptb_idx  = hip->h.iptb_idx;
   
  uint64_t *iptb      = (uint64_t*) hip->h.iptb;

  int  h  = RIP_hfn_h128dblh1_lemire0(hip, ip);

  uint64_t iptb_val[2];
  iptb_val[0] = iptb[ iptb_idx[ htb[h] -1  ]  ] ;
  iptb_val[1] = iptb[ iptb_idx[ htb[h] -1  ] + hip->h.ip_len];

  if(
    ( htb[h]>0 ) && ( 
      !Ripaddr_ipv6_cmp_eq( iptb_val, ip )  
    )
  ){
     
    int  h0 = h;
    int  h1 = RIP_hfn_h128dblh2_lemire0(hip, ip); 
     
    nprobes++;
     
    do{
      h = (h0 + nprobes * h1) % hip->h.htb_sz; 
      nprobes++; 

      iptb_val[0] = iptb[ iptb_idx[ htb[h] -1  ]  ] ;
      iptb_val[1] = iptb[ iptb_idx[ htb[h] -1  ] + hip->h.ip_len];

    }while (
      (  htb[h]>0 ) && ( 
        !Ripaddr_ipv6_cmp_eq( iptb_val, ip )  
      )
    );
  }
   
* hidx = h;
  m    =  htb[h]>0;
 
#ifdef RIP_HASH_DBG
  hip->h.ncoll +=nprobes;
#endif
   
  return m;
}
 
#endif

SEXP
  Rip_h_ipv4_hash_0_0(
      SEXP Rip
     
    , SEXP RM
     
     
){
  SEXP Rhtb;
   
  int nprotected=0;
  RIP_h32dblh_HASH_INIT(hip, htb_sz, RM)

  RIPv4_SLOTS_GET( Rip )
   
  if( htb_sz < Rip_nip ) error("htb too small");
  PROTECT(Rhtb = allocVector(INTSXP, htb_sz));nprotected++;
   
  hip.h.htb        = INTEGER(Rhtb);
  memset(hip.h.htb, 0, htb_sz*sizeof(int));  
  hip.h.htb_sz     = htb_sz;
  hip.h.htb_nh     = 0;
  hip.h.iptb       = (void*) Rip_ip_ptr;
  hip.h.iptb_idx   = Rip_ip_idxptr;
#ifdef RIP_HASH_DBG
  hip.h.ncoll      = 0;
#endif
   
   
  for( int i=0 ; i<Rip_nip; i++ ){ 
    int rc, hidx;
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER) ){ i++; } 
    if(i>=Rip_nip) break;
 
    RIPv4_ELT_PTR_DCL(Rip, i)
     
    if(
      ( rc = Rip_h32dblh_search_0_0(&hip, Rip_ip_elt_ptr, &hidx) )==0  
    ){
 
      hip.h.htb[hidx] = i + 1;  
      hip.h.htb_nh++;
    }
     
  }
#ifdef RIP_HASH_DBG
 
#endif
   
  RIP_h32dblh_HASH_SET(hip, Rhtb, Rip)

  UNPROTECT(nprotected);
  return Rhtb;  
}

#define RIP_H_HASH_0(___IPv__,___hfn__ ) \
SEXP Rip_h_ip##___IPv__##_##___hfn__##_hash_0_0(SEXP ___Rip__, SEXP ___hPARMS__){ \
  SEXP Rhtb; \
  int nprotected=0; \
  \
  RIP_##___hfn__##_HASH_INIT(hip, htb_sz, ___hPARMS__) \
  RIP##___IPv__##_SLOTS_GET( ___Rip__ )\
    \
  if( htb_sz < ___Rip__##_nip ) error("htb size too small");\
  PROTECT(Rhtb = allocVector(INTSXP, htb_sz));nprotected++;\
  hip.h.htb        = INTEGER(Rhtb); \
  memset(hip.h.htb, 0, htb_sz*sizeof(int)); \
  hip.h.htb_sz     = htb_sz;\
  hip.h.htb_nh     = 0; \
  hip.h.iptb       = (void*) RIP##___IPv__##_IP_basePtr(___Rip__); \
  hip.h.iptb_idx   = ___Rip__##_ip_idxptr; \
  hip.h.ip_len     = ___Rip__##_ip_len; \
  \
  for( int i=0 ; i<  ___Rip__##_nip; i++ ){  \
    int rc, hidx; \
    while( (i<___Rip__##_nip) && ( ___Rip__##_ip_idxptr[i]==NA_INTEGER) ){ i++; }  \
    if(i>=___Rip__##_nip) break; \
  \
    RIP##___IPv__##_ELT_PTR_DCL(___Rip__, i) \
    if( \
      ( rc = RIP_##___hfn__##_search_0_0(&hip, ___Rip__##_ip_elt_ptr, &hidx) )==0   \
    ){ \
  \
      hip.h.htb[hidx] = i + 1;  \
      hip.h.htb_nh++; \
    } \
      \
  } \
  \
  RIP_##___hfn__##_HASH_SET(hip, Rhtb, ___Rip__) \
  UNPROTECT(nprotected); \
  return Rhtb;  \
} \
 
 
RIP_H_HASH_0(v4r,h64dblh_lemire)
 
 
RIP_H_HASH_0(v6,h128dblh_lemire)

#if 1
 
SEXP
  Rip_h_ipv4r_hash_0_0(
      SEXP Rip
     
    , SEXP RM
     
     
){
  SEXP Rhtb;
   
  int nprotected=0;
  RIP_h64dblh_lemire_HASH_INIT(hip, htb_sz, RM)
  RIPv4r_SLOTS_GET( Rip )
   
  if( htb_sz < Rip_nip ) error("htb too small");
  PROTECT(Rhtb = allocVector(INTSXP, htb_sz));nprotected++;
   
  hip.h.htb        = INTEGER(Rhtb);
  memset(hip.h.htb, 0, htb_sz*sizeof(int));  
  hip.h.htb_sz     = htb_sz;
  hip.h.htb_nh     = 0;
  hip.h.iptb       = (void*) Rip_ip_lo_ptr;
  hip.h.iptb_idx   = Rip_ip_idxptr;
  hip.h.ip_len     = Rip_ip_len;
 
#ifdef RIP_HASH_DBG
  hip.h.ncoll      = 0;
#endif
   
   
  for( int i=0 ; i<Rip_nip; i++ ){ 
    int rc, hidx;
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER) ){ i++; } 
 
    RIPv4r_ELT_PTR_DCL(Rip, i)
     
    if(
      ( rc = RIP_h64dblh_lemire_search_0_0(&hip, Rip_ip_elt_ptr, &hidx) )==0  
    ){
 
      hip.h.htb[hidx] = i + 1;  
      hip.h.htb_nh++;
    }
     
  }

  RIP_h64dblh_lemire_HASH_SET(hip, Rhtb, Rip)

  UNPROTECT(nprotected);
  return Rhtb;  
}
#endif

SEXP
  Rip_h_ipv4_lookup_0_0(
      SEXP Rip
    , SEXP RipTbl

){
  SEXP Rhtb, Res;
   
  int nprotected=0;
   
  RIPv4_SLOTS_GET( RipTbl )
  RipTbl_nip+=0;
  Rhtb   = getAttrib( RipTbl_ipv4, install("htb"));
  RIP_h32dblh_LOOKUP_INIT(hip, htb_sz, Rhtb)

  RIPv4_SLOTS_GET( Rip )
   
   
  PROTECT(Res = allocVector(INTSXP, Rip_nip ) );nprotected++;
  int *resptr      = INTEGER(Res);
  hip.h.htb        = INTEGER(Rhtb);
  hip.h.htb_sz     = htb_sz;
  hip.h.htb_nh     = INTEGER(getAttrib( Rhtb, install("nh")))[0];
  hip.h.iptb       = (void*) RipTbl_ip_ptr;
  hip.h.iptb_idx   = RipTbl_ip_idxptr;
#ifdef RIP_HASH_DBG
  hip.h.ncoll      = 0;
#endif

  for( int i=0 ; i<Rip_nip; i++ ){ 
    int rc, hidx;
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER) ){ resptr[i]= NA_INTEGER; i++; } 
 
    RIPv4_ELT_PTR_DCL(Rip, i)
     
    if(
      ( rc = Rip_h32dblh_search_0_0(&hip, Rip_ip_elt_ptr, &hidx) )==1  
    ){
 
      resptr[i] = hip.h.htb[hidx] ;  
    }else{resptr[i]= NA_INTEGER;}
  }

  UNPROTECT(nprotected);
  return Res;
}
#endif

#define RIP_H_LOOKUP_0(___IPv__,___hfn__ ) \
SEXP Rip_h_ip##___IPv__##_##___hfn__##_lookup_0_0(SEXP ___Rip__, SEXP ___RipTbl__, SEXP ___Romatch__){ \
  SEXP Rhtb, Res; \
  int nprotected=0; \
  \
  RIP##___IPv__##_SLOTS_GET( ___RipTbl__ ) \
  ___RipTbl__##_nip+=0; ___RipTbl__##_ip_lo_ptr+=0;___RipTbl__##_ip_hi_ptr+=0; \
   \
  Rhtb   = getAttrib( RIP##___IPv__##_IP_RipTbl(___RipTbl__), install("htb")); \
  RIP_##___hfn__##_LOOKUP_INIT(hip, htb_sz, Rhtb) \
  RIP##___IPv__##_SLOTS_GET( ___Rip__ ) \
    \
  PROTECT(Res = allocVector(INTSXP, ___Rip__##_nip ) );nprotected++; \
 \
  int *resptr      = INTEGER(Res); \
  hip.h.htb        = INTEGER(Rhtb); \
  hip.h.htb_sz     = htb_sz; \
  hip.h.htb_nh     = INTEGER(getAttrib( Rhtb, install("nh")))[0]; \
  hip.h.iptb       = (void*) RIP##___IPv__##_IP_basePtr(___RipTbl__); \
    \
  hip.h.iptb_idx   = ___RipTbl__##_ip_idxptr; \
  hip.h.ip_len     = ___RipTbl__##_ip_len; \
  int nomatch      = *INTEGER(___Romatch__);   \
 \
  for( int i=0 ; i< ___Rip__##_nip; i++ ){ \
    int rc, hidx; \
    while( (i<___Rip__##_nip) && (___Rip__##_ip_idxptr[i]==NA_INTEGER)  ){ resptr[i]= nomatch; i++; } \
    if(i>=___Rip__##_nip) break; \
  \
    RIP##___IPv__##_ELT_PTR_DCL(___Rip__, i) \
    if( \
      ( rc = RIP_##___hfn__##_search_0_0(&hip, ___Rip__##_ip_elt_ptr, &hidx) )==1    \
    ){ \
   \
      resptr[i] = hip.h.htb[hidx] ;   \
    } else{resptr[i]= nomatch;} \
  } \
  \
  UNPROTECT(nprotected); \
  return Res; \
} \
 
RIP_H_LOOKUP_0(v4r,h64dblh_lemire)
 
RIP_H_LOOKUP_0(v6,h128dblh_lemire)

SEXP
  Rip_h_ipv4r_lookup_0_0(
      SEXP Rip
    , SEXP RipTbl
){
  SEXP Rhtb, Res;
   
  int nprotected=0;
   
  RIPv4r_SLOTS_GET( RipTbl )
  RipTbl_nip+=0;RipTbl_ip_hi_ptr+=0;
  Rhtb   = getAttrib( RipTbl_ipr, install("htb"));
  RIP_h64dblh_lemire_LOOKUP_INIT(hip, htb_sz, Rhtb)

  RIPv4r_SLOTS_GET( Rip )
   
   
  PROTECT(Res = allocVector(INTSXP, Rip_nip ) );nprotected++;
  int *resptr      = INTEGER(Res);
  hip.h.htb        = INTEGER(Rhtb);
  hip.h.htb_sz     = htb_sz;
  hip.h.htb_nh     = INTEGER(getAttrib( Rhtb, install("nh")))[0];
  hip.h.iptb       = (void*) RipTbl_ip_lo_ptr;
   
  hip.h.iptb_idx   = RipTbl_ip_idxptr;
  hip.h.ip_len     = RipTbl_ip_len; 
#ifdef RIP_HASH_DBG
  hip.h.ncoll      = 0;
#endif
   
   
  for( int i=0 ; i<Rip_nip; i++ ){ 
    int rc, hidx;
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER) ){ resptr[i]= NA_INTEGER; i++; } 
 
    RIPv4r_ELT_PTR_DCL(Rip, i)
     
    if(
      ( rc = RIP_h64dblh_lemire_search_0_0(&hip, Rip_ip_elt_ptr, &hidx) )==1  
    ){
 
      resptr[i] = hip.h.htb[hidx] ;  
    }
    else{resptr[i]= NA_INTEGER;} 
  }

  UNPROTECT(nprotected);
  return Res;
}

int
  Rip_cache_ipv4_insertVal_0_0(
      IPv4 *ip
    , int  *idx
){
     
    int nprobe=0;
     
    if(
      (RIP_cache_ipv4_htb_nh)>=( RIP_cache_ipv4_nval - 1 )
    ){
Rprintf("full cache\n");      
      return 1;
    }
     
    IPv4 v = *ip;  
     
    int  h  = DBLhash1(v);
    int  h0 = h;
    int  h1 = DBLhash2(v);
 
     
    while (
         RIP_cache_ipv4_htb[h]>0 
      && RIP_cache_ipv4_val[ 
         RIP_cache_ipv4_htb[h] -1 
      ] != v
          
       
    ){
 
       
      nprobe++;   

      h = (h0 + nprobe * h1) % K1; 
    }
    if( 
      !RIP_cache_ipv4_htb[h] 
       
    ){
 
       
      RIP_cache_ipv4_htb[ h ]                    = RIP_cache_ipv4_val_i+1; 
      RIP_cache_ipv4_val[ RIP_cache_ipv4_val_i ] = v;
     *idx                                        = RIP_cache_ipv4_val_i;

      RIP_cache_ipv4_val_i++;
       
      RIP_cache_ipv4_htb_nh++;
       
      RIP_cache_ipv4_ins_ncoll  +=nprobe;
    }
    else{
 
     *idx                        = RIP_cache_ipv4_htb[ h ] - 1; 
      
      RIP_cache_ipv4_lkup_ncoll += nprobe;
    }
 
     
    return 0;
}
 
int
  Rip_cache_ipv4_insert_0_0(
      IPv4 *ip
    , int   nip
    , int   *idx
){
   
  int rc=0;
   
  if(RIP_cache_ipv4_nval==0){
    rc = Rip_cache_ipv4_init_0_0();
    if(rc) return rc;
  }

  for(int i=0; i<nip; i++){
    rc=0;
    if( ( rc = Rip_cache_ipv4_insertVal_0_0(&ip[i], &idx[i]) ) ) return rc;
  }
 
   
  return 0;
}
 
SEXP
  Rip_cache_ipv4_Rinsert_0_0(
    SEXP Rip
){
   
  SEXP  Ridx;
  IPv4 *ip;
  int   nip, *idx, nprotected=0;
   
  ip  = (IPv4*) INTEGER(Rip);
  nip = LENGTH(Rip);
  PROTECT( Ridx = allocVector(INTSXP, nip ) ); 
  nprotected++;
  idx = INTEGER(Ridx);
   
  if(
    Rip_cache_ipv4_insert_0_0(
        ip   
      , nip  
      , idx  
    )
  )error("cache insert");
   
  UNPROTECT(nprotected);
   
  return Ridx;
}
 
SEXP
  Rip_cache_ipv4_Rfetch_0_0(
    SEXP Ridx
){
   
  SEXP  Rval;
  int  *idx, *val, nip;
  int nprotected=0;
   
  idx = INTEGER(Ridx);
  nip = LENGTH(Ridx);
  PROTECT( Rval = allocVector(INTSXP, nip ) ); 
  nprotected++;
  val = INTEGER(Rval);
  for(int i=0; i < nip; ){
     
     
    if( 
      idx[i]!=NA_INTEGER 
    ){
      val[i] = *(int *) &RIP_cache_ipv4_val[idx[i]];
       
      i++;
    }

  }
   
  UNPROTECT(nprotected);
   
  return Rval;
}

 
