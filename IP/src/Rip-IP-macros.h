 

#define RIPv4_SLOTS_DCL(___vname__) \
  SEXP   ___vname__##_DataSlot=NULL, ___vname__##_ipv4=NULL; \
  IPv4 * ___vname__##_ip_ptr=NULL; \
    \
  int  * ___vname__##_ip_idxptr = NULL; \
  int    ___vname__##_ip_idx    =-1; \
  int    ___vname__##_nip       = 0;  \
  int    ___vname__##_nipv4     =-1; \
  
 
#define RIPv4r_SLOTS_DCL(___vname__) \
  SEXP  ___vname__##_DataSlot, ___vname__##_ipv4r; \
  IPv4 *___vname__##_ip_hi_ptr=NULL; \
  IPv4 *___vname__##_ip_lo_ptr=NULL; \
  PROTECT_INDEX   ___vname__##_ip_protidx; \
  int  *___vname__##_ip_idxptr; \
  int   ___vname__##_ip_idx=-1; \
 
 
#define RIPv6_SLOTS_DCL(___vname__) \
  SEXP      ___vname__##_DataSlot=NULL, ___vname__##_ipv6=NULL; \
  uint64_t *___vname__##_ip_hi_ptr=NULL; \
  uint64_t *___vname__##_ip_lo_ptr=NULL; \
  int       ___vname__##_ip_protidx = 0; \
  int      *___vname__##_ip_idxptr=NULL; \
  int       ___vname__##_ip_idx = -1; \
  int       ___vname__##_nip    =  0; \
  int       ___vname__##_nipv6   = -1; \
  
 
#define RIPv6r_SLOTS_DCL(___vname__) \
  SEXP      ___vname__##_DataSlot, ___vname__##_ipv6r; \
  uint64_t *___vname__##_ip_hi_ptr=NULL; \
  uint64_t *___vname__##_ip_lo_ptr=NULL; \
  int       ___vname__##_ip_protidx; \
  int      *___vname__##_ip_idxptr; \
  int       ___vname__##_ip_idx  =-1; 
  
 
#define RIP_IP_SLOTS_DCL(___vname__) \
  SEXP ___vname__##_ipv4; \
  SEXP ___vname__##_ipv6; \
  SEXP ___vname__##_ipv;
  
 
#define RIP_IPr_SLOTS_DCL(___vname__) \
  SEXP ___vname__##_ipv4r; \
  SEXP ___vname__##_ipv6r; \
  SEXP ___vname__##_ipv;
  
 
#define ___RIPv4_SLOTS_ALLOC(___vname__, ___nip__, ___nipv4__) \
    \
 \
  ___vname__##_nip     = ___nip__; \
  PROTECT( ___vname__##_DataSlot = allocVector(INTSXP, ___nip__ ) ); \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
    \
  PROTECT( ___vname__##_ipv4 = allocVector(INTSXP, ___nipv4__ ));  \
   \
  ___vname__##_ip_ptr = (IPv4 *) INTEGER( ___vname__##_ipv4 ); \
  nprotected+=2; \

 
#define ___RIPv6_SLOTS_ALLOC(___vname__, ___nip__, ___nipv6__) \
  ___vname__##_nip     = ___nip__; \
  \
  PROTECT( ___vname__##_DataSlot = allocVector(INTSXP, ___nip__ ) ); \
 \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  \
  PROTECT_WITH_INDEX( ___vname__##_ipv6 = allocMatrix(REALSXP, ___nipv6__, 2 ), &___vname__##_ip_protidx); \
    \
  \
  ___vname__##_ip_hi_ptr = (uint64_t *) REAL( ___vname__##_ipv6 ); \
   \
  ___vname__##_ip_lo_ptr = (uint64_t *) REAL( ___vname__##_ipv6 ) + ___nipv6__; \
    \
  nprotected+=2; \
    
 
#define RIPv4_SLOTS_ALLOC_REF(___vname__, ___nip__,  ___src__) \
 \
  int ___src__##_noref = ( REFCNT(___src__)==0 ) & (___nip__==LENGTH(___src__)); \
  \
  ___vname__##_nip     = ___nip__; \
   \
  PROTECT( ___vname__##_DataSlot = ___src__##_noref ? GET_SLOT(___src__, Rip_dataSlotSym ): allocVector(INTSXP, ___nip__ ) );  \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  ___vname__##_nipv4 =  (___nip__==LENGTH(___src__)) ? *INTEGER(GET_SLOT(___src__, Rip_lenSym ) ) : ___nip__; \
  PROTECT( ___vname__##_ipv4 = allocVector(INTSXP, (___nip__==LENGTH(___src__)) ? ___vname__##_nipv4 :  ___nip__ ));   \
     \
  ___vname__##_ip_ptr = (IPv4 *) INTEGER( ___vname__##_ipv4 ); \
  nprotected+=2; \
  
 
#define RIPv4r_SLOTS_ALLOC_REF(___vname__, ___nip__, ___src__) \
  int ___src__##_noref =  ( REFCNT(___src__)==0 ) & (___nip__==LENGTH(___src__)); \
  int       ___vname__##_nip     = ___nip__; \
    \
  ___vname__##_ip_idxptr =  ___src__##_noref ? GET_SLOT(___src__, Rip_dataSlotSym )                : INTEGER( ___vname__##_DataSlot ); \
  PROTECT_WITH_INDEX( ___vname__##_ipv4r = ( ___src__##_noref & ( *INTEGER(GET_SLOT(___src__, Rip_lenSym ) ) ==___nip__ ) )  ? GET_SLOT(___src__, Rip_ipv4rSymSym ) : allocMatrix(INTSXP, ___nip__ , 2), &___vname__##_ip_protidx );  \
  ___vname__##_ip_lo_ptr = (IPv4 *) INTEGER( ___vname__##_ipv4r ); \
  ___vname__##_ip_hi_ptr = (IPv4 *) INTEGER( ___vname__##_ipv4r ) + ___nip__; \
  nprotected+=2; \
  
 
#define RIPv6_SLOTS_ALLOC_REF(___vname__, ___nip__, ___src__) \
  int ___src__##_noref =  ( REFCNT(___src__)==0 ) & (___nip__==LENGTH(___src__)); \
  \
  PROTECT( ___vname__##_DataSlot = ___src__##_noref ? GET_SLOT(___src__, Rip_dataSlotSym )    : allocVector(INTSXP, ___nip__ ) ); \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  ___vname__##_nipv6 = (___nip__==LENGTH(___src__)) ? *INTEGER(GET_SLOT(___src__, Rip_lenSym ) ) : ___nip__; \
  \
    \
    \
  \
  PROTECT_WITH_INDEX( ___vname__##_ipv6 = ( ___src__##_noref  ) ? GET_SLOT(___src__, Rip_ipv6Sym ) : allocMatrix(REALSXP, ___vname__##_nipv6, 2 ), &___vname__##_ip_protidx);   \
   \
  \
  ___vname__##_ip_hi_ptr = (uint64_t *) REAL( ___vname__##_ipv6 ); \
  ___vname__##_ip_lo_ptr = (uint64_t *) REAL( ___vname__##_ipv6 ) +  ___vname__##_nipv6; \
    \
  nprotected+=2; \
  
 
#define RIPv6r_SLOTS_ALLOC_REF(___vname__, ___nip__, ___src__) \
  int ___src__##_noref =  ( REFCNT(___src__)==0 ) & (___nip__==LENGTH(___src__)); \
  int       ___vname__##_nip     = ___nip__; \
  int       ___vname__##_ip_len     = ___nip__; \
  PROTECT( ___vname__##_DataSlot =  ___src__##_noref ? GET_SLOT(___src__, Rip_dataSlotSym )    : allocVector(INTSXP, ___nip__ ) ); \
 \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  \
  PROTECT_WITH_INDEX( ___vname__##_ipv6r = ___src__##_noref ? GET_SLOT(___src__, Rip_ipv6rSym ) : allocMatrix(REALSXP, ___nip__, 4 ), &___vname__##_ip_protidx); \
    \
  \
  ___vname__##_ip_lo_ptr = (uint64_t *) REAL( ___vname__##_ipv6r ); \
   \
  ___vname__##_ip_hi_ptr = (uint64_t *) REAL( ___vname__##_ipv6r ) + 2*___nip__; \
  nprotected+=2; \

 
#define RIPv4_SLOTS_ALLOC(___vname__, ___nip__) \
  SEXP   ___vname__##_DataSlot, ___vname__##_ipv4; \
  IPv4 * ___vname__##_ip_ptr; \
  PROTECT_INDEX    ___vname__##_ip_protidx;  \
  int  * ___vname__##_ip_idxptr; \
  int    ___vname__##_ip_idx=-1; \
  int    ___vname__##_nip     = ___nip__; \
  int    ___vname__##_nipv4     = ___nip__; ___vname__##_nipv4+=0; \
  PROTECT( ___vname__##_DataSlot = allocVector(INTSXP, ___nip__ ) ); \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  PROTECT_WITH_INDEX( ___vname__##_ipv4 = allocVector(INTSXP, ___nip__ ), &___vname__##_ip_protidx);  \
    \
  ___vname__##_ip_ptr = (IPv4 *) INTEGER( ___vname__##_ipv4 ); \
  nprotected+=2;   \
    \
  
 
#define RIPv4cache_SLOTS_ALLOC(___vname__, ___nip__) \
    \
  SEXP   ___vname__##_DataSlot; \
  int  * ___vname__##_ip_idxptr; \
  int    ___vname__##_ip_idx=-1;   \
  int    ___vname__##_nip     = ___nip__; \
   \
  PROTECT( ___vname__##_DataSlot = allocVector(INTSXP, ___nip__ ) ); \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  nprotected+=1;  \
  
 
#define RIPv4_RIP_ALLOC(___vname__, ___nip__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv4")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
  RIPv4_SLOTS_ALLOC(___vname__, ___nip__) \
  
#define RIPv4cache_RIP_ALLOC(___vname__, ___nip__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv4")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
  RIPv4cache_SLOTS_ALLOC(___vname__, ___nip__) \
  
#define RIPv4cache_RIP_ALLOC1_1(___vname__, ___nip__, ___src__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv4")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
  RIPv4cache_SLOTS_ALLOC(___vname__, ___nip__) \
  RIPv4cache_HASH_GET(___vname__, ___src__)   \
  SEXP ___vname__##_Rcache         = PROTECT(GET_SLOT(___src__, install("cache") )); \
  nprotected+=1; \

  
#define RIPv4cache_RIP_ALLOC2_1(___vname__, ___nip__, ___src1__, ___src2__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv4")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
  RIPv4cache_SLOTS_ALLOC(___vname__, ___nip__) \
   \
  RIPv4cache_HASH_DCL(___vname__)  \
  SEXP ___vname__##_Rcache; \
  int cset= 0; \
  if( isS4(___src1__) ){ \
    if( !isNull(GET_SLOT(___src1__, install("cache") )) ){ \
      RIPv4cache_HASH_SLOT_GET(___vname__, ___src1__) \
      RIPv4cache_CACHE_STRUCT_SET(___vname__, ___src1__) \
      ___vname__##_Rcache         = PROTECT(GET_SLOT(___src1__, install("cache") )); \
      nprotected++; \
      cset = 1; \
    } \
  } \
  if( !cset && isS4(___src2__) ) { \
    if( !isNull(GET_SLOT(___src2__, install("cache") )) ){ \
      RIPv4cache_HASH_SLOT_GET(___vname__, ___src2__) \
      RIPv4cache_CACHE_STRUCT_SET(___vname__, ___src2__) \
      ___vname__##_Rcache         = PROTECT(GET_SLOT(___src1__, install("cache") )); \
      nprotected++; \
      cset = 1; \
    } \
  } \
  if( !cset ){ \
    error("no cache found");\
  }  \
  
 
#define RIPv4_SLOTS_TMP_ALLOC(___vname__, ___nip__) \
  SEXP   ___vname__##_DataSlot, ___vname__##_ipv4; \
  IPv4 * ___vname__##_ip_ptr; \
   \
  int  * ___vname__##_ip_idxptr; \
  int    ___vname__##_ip_idx=-1; \
  PROTECT( ___vname__##_DataSlot = allocVector(INTSXP, ___nip__ ) ); \
  nprotected++; \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
    \
   \
  ___vname__##_ip_ptr =  R_Calloc( ___nip__ , IPv4 ) ; \
  
 
#define RIPv4r_SLOTS_ALLOC(___vname__, ___nip__) \
  SEXP  ___vname__##_DataSlot, ___vname__##_ipv4r; \
  IPv4 *___vname__##_ip_hi_ptr; \
  IPv4 *___vname__##_ip_lo_ptr; \
  PROTECT_INDEX   ___vname__##_ip_protidx; \
  int  *___vname__##_ip_idxptr; \
  int   ___vname__##_ip_idx=-1; \
  int       ___vname__##_nip     = ___nip__; \
  PROTECT( ___vname__##_DataSlot = allocVector(INTSXP, ___nip__ ) ); \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  PROTECT_WITH_INDEX( ___vname__##_ipv4r = allocMatrix(INTSXP, ___nip__ , 2), &___vname__##_ip_protidx );   \
  ___vname__##_ip_hi_ptr = (IPv4 *) INTEGER( ___vname__##_ipv4r ) + ___nip__; \
  ___vname__##_ip_lo_ptr = (IPv4 *) INTEGER( ___vname__##_ipv4r ); \
    \
  nprotected+=2; \
  
 
#define RIPv4r_RIP_ALLOC(___vname__, ___nip__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv4r")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
  RIPv4r_SLOTS_ALLOC(___vname__, ___nip__) \
    
 
#define RIPv4r_SLOTS_TMP_ALLOC(___vname__, ___nip__) \
  SEXP  ___vname__##_DataSlot, ___vname__##_ipv4r; \
  IPv4 *___vname__##_ip_hi_ptr; \
  IPv4 *___vname__##_ip_lo_ptr; \
    \
  int  *___vname__##_ip_idxptr; \
  int   ___vname__##_ip_idx=-1; \
  PROTECT( ___vname__##_DataSlot = allocVector(INTSXP, ___nip__ ) ); \
  nprotected++; \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  IPv4 *___vname__##ipv4r_ipv4r  = malloc( 2*___nip__ * sizeof(IPv4) ); \
  ___vname__##_ip_hi_ptr = ___vname__##ipv4r_ipv4r + ___nip__; \
  ___vname__##_ip_lo_ptr = ___vname__##ipv4r_ipv4r; \

 
#define RIPv6_SLOTS_ALLOC(___vname__, ___nip__) \
  SEXP      ___vname__##_DataSlot, ___vname__##_ipv6; \
  uint64_t *___vname__##_ip_hi_ptr=NULL; \
  uint64_t *___vname__##_ip_lo_ptr=NULL; \
  int       ___vname__##_ip_protidx=0; \
  int      *___vname__##_ip_idxptr; \
  int       ___vname__##_ip_idx=-1;  \
  int       ___vname__##_nip     = ___nip__; \
  int       ___vname__##_nipv6   = -1; \
  PROTECT( ___vname__##_DataSlot = allocVector(INTSXP, ___nip__ ) ); \
 \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  \
  PROTECT_WITH_INDEX( ___vname__##_ipv6 = allocMatrix(REALSXP, ___nip__, 2 ), &___vname__##_ip_protidx);   \
               \
   ___vname__##_nipv6 = ___nip__;   \
  \
  ___vname__##_ip_hi_ptr = (uint64_t *) REAL( ___vname__##_ipv6 ); \
  ___vname__##_ip_lo_ptr = (uint64_t *) REAL( ___vname__##_ipv6 ) + ___vname__##_nipv6; \
    \
  nprotected+=2; \
    
 
#define RIPv6_RIP_ALLOC(___vname__, ___nip__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv6")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
  RIPv6_SLOTS_ALLOC(___vname__, ___nip__) \
  
 
#define RIPv6r_SLOTS_ALLOC(___vname__, ___nip__) \
  SEXP      ___vname__##_DataSlot, ___vname__##_ipv6r; \
  uint64_t *___vname__##_ip_hi_ptr; \
  uint64_t *___vname__##_ip_lo_ptr; \
  int       ___vname__##_ip_protidx; \
  int      *___vname__##_ip_idxptr; \
  int       ___vname__##_ip_idx  =-1; \
  int       ___vname__##_nip     = ___nip__; \
  int       ___vname__##_ip_len     = ___nip__; \
  PROTECT( ___vname__##_DataSlot = allocVector(INTSXP, ___nip__ ) ); \
 \
  ___vname__##_ip_idxptr = INTEGER( ___vname__##_DataSlot ); \
  \
  PROTECT_WITH_INDEX( ___vname__##_ipv6r = allocMatrix(REALSXP, ___nip__, 4 ), &___vname__##_ip_protidx); \
    \
  \
  ___vname__##_ip_lo_ptr = (uint64_t *) REAL( ___vname__##_ipv6r ); \
   \
  ___vname__##_ip_hi_ptr = (uint64_t *) REAL( ___vname__##_ipv6r ) + 2*___nip__; \
  nprotected+=2; \
  
 
#define RIPv6r_RIP_ALLOC(___vname__, ___nip__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv6r")); \
  PROTECT( ___vname__ = NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
  RIPv6r_SLOTS_ALLOC(___vname__, ___nip__) \

#define RIPv4_RIP_ALLOC_REF(___vname__, ___nip__, ___src__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv4")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
  RIPv4_SLOTS_DCL(___vname__) \
  RIPv4_SLOTS_ALLOC_REF(___vname__, ___nip__, ___src__)   \
   \
  
 
#define RIPv6_RIP_ALLOC_REF(___vname__, ___nip__, ___src__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv6")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
  RIPv6_SLOTS_DCL(___vname__) \
  RIPv6_SLOTS_ALLOC_REF(___vname__, ___nip__, ___src__)   \
   \
   \
  
 
#define RIPv4r_RIP_ALLOC_REF(___vname__, ___nip__, ___src__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv4r")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
   \
  RIPv4r_SLOTS_ALLOC(___vname__, ___nip__) \
  
 
#define RIPv6r_RIP_ALLOC_REF(___vname__, ___nip__, ___src__) \
  SEXP ___vname__##_kl; \
  PROTECT( ___vname__##_kl = MAKE_CLASS("IPv6r")); \
  ___vname__ = PROTECT(NEW_OBJECT( ___vname__##_kl )); \
  nprotected+=2; \
   \
  RIPv6r_SLOTS_ALLOC(___vname__, ___nip__)\
  
 
#define RIPv4_SLOTS_GET(___vname__) \
 \
  SEXP   ___vname__##_DataSlot, ___vname__##_ipv4; \
  int    ___vname__##_nip ; \
  int   *___vname__##_ip_idxptr; \
  IPv4  *___vname__##_ip_ptr; \
   \
  ___vname__##_DataSlot    =  PROTECT(GET_SLOT(___vname__, Rip_dataSlotSym ));  \
   \
    \
  ___vname__##_nip         =  LENGTH( ___vname__##_DataSlot ); \
  ___vname__##_ip_idxptr   =  INTEGER( ___vname__##_DataSlot ); \
    \
  ___vname__##_ipv4        = PROTECT( GET_SLOT(___vname__, Rip_ipv4Sym ));  \
    \
   \
  ___vname__##_ip_ptr      =  ( !isNull( ___vname__##_ipv4 ) ) ? (IPv4 *) INTEGER( ___vname__##_ipv4 )  : NULL ;\
  nprotected+=2; \
 
#if 0
 
#define RIPv4cache_SLOTS_GET(___vname__) \
 \
  SEXP   ___vname__##_DataSlot; \
  int    ___vname__##_nip ; \
  int   *___vname__##_ip_idxptr; \
   \
   \
  ___vname__##_DataSlot    =  PROTECT(GET_SLOT(___vname__, Rip_dataSlotSym ));  \
   \
    \
  ___vname__##_nip         =  LENGTH( ___vname__##_DataSlot ); \
  ___vname__##_ip_idxptr   =  INTEGER( ___vname__##_DataSlot ); \
  nprotected+=1; \
 
#else
 
#define RIPv4cache_SLOTS_GET(___vname__) \
  SEXP   ___vname__##_DataSlot; \
  int   *___vname__##_ip_idxptr; \
  int    ___vname__##_nip ; \
  ___vname__##_DataSlot    =  PROTECT(GET_SLOT(___vname__, Rip_dataSlotSym ));  \
  ___vname__##_ip_idxptr   =  INTEGER( ___vname__##_DataSlot ); \
  ___vname__##_nip         =  LENGTH( ___vname__##_DataSlot ); \
  RIPv4cache_HASH_GET(___vname__, ___vname__) \
  nprotected+=1; \
 
#endif

#define RIPv4cache_HASH_DCL(___vname__) \
  SEXP  ___vname__##_Rhtb, ___vname__##_Rhip, ___vname__##_Rh; \
  RIP_h32dblh ___vname__##_hip; \
  
#define RIPv4cache_HASH_ENV_GET(___vname__, ___src__) \
  PROTECT(___vname__##_Rhtb   = findVarInFrame( ___src__, install("htb") ) ); \
  PROTECT(___vname__##_Rhip   = findVarInFrame( ___src__, install("hip") ) ); \
  PROTECT(___vname__##_Rh     = findVarInFrame( ___src__, install("h") ) ); \
  nprotected+=3;   \
  
#define RIPv4cache_HASH_SLOT_GET(___vname__, ___src__) \
  PROTECT(___vname__##_Rhtb   = findVarInFrame( GET_SLOT(___src__, install("cache") ), install("htb") ) ); \
  PROTECT(___vname__##_Rhip   = findVarInFrame( GET_SLOT(___src__, install("cache") ), install("hip") ) ); \
  PROTECT(___vname__##_Rh     = findVarInFrame( GET_SLOT(___src__, install("cache") ), install("h") ) ); \
  nprotected+=3;   \

#define RIPv4cache_HASH_STRUCT_SET(___vname__, ___src__) \
  ___vname__##_hip.M1           = INTEGER(___vname__##_Rh)[1]; \
  ___vname__##_hip.M2           = INTEGER(___vname__##_Rh)[2]; \
  ___vname__##_hip.h.htb        = INTEGER(___vname__##_Rhtb); \
  ___vname__##_hip.h.htb_sz     = LENGTH(___vname__##_Rhtb); \
  ___vname__##_hip.h.htb_nh     = INTEGER(findVarInFrame(___src__, install("nh") ) )[0]; \
  ___vname__##_hip.h.iptb       = (void*) INTEGER(___vname__##_Rhip); \

#define RIPv4cache_CACHE_STRUCT_SET(___vname__, ___src__) \
  ___vname__##_hip.M1           = INTEGER(___vname__##_Rh)[1]; \
  ___vname__##_hip.M2           = INTEGER(___vname__##_Rh)[2]; \
  ___vname__##_hip.h.htb        = INTEGER(___vname__##_Rhtb); \
  ___vname__##_hip.h.htb_sz     = LENGTH(___vname__##_Rhtb); \
  ___vname__##_hip.h.htb_nh     = INTEGER(findVarInFrame(GET_SLOT(___src__, install("cache") ), install("nh") ) )[0]; \
  ___vname__##_hip.h.iptb       = (void*) INTEGER(___vname__##_Rhip); \
  
#define RIPv4cache_HASH_GET(___vname__, ___src__) \
  RIPv4cache_HASH_DCL(___vname__)  \
  RIPv4cache_HASH_SLOT_GET(___vname__, ___src__) \
  RIPv4cache_CACHE_STRUCT_SET(___vname__, ___src__) \
  
 
#define RIPv4r_SLOTS_GET(___vname__) \
  SEXP   ___vname__##_DataSlot, ___vname__##_ipr; \
  int    ___vname__##_nip, ___vname__##_ip_len ; \
  int   *___vname__##_ip_idxptr; \
  IPv4  *___vname__##_ip_hi_ptr; \
  IPv4  *___vname__##_ip_lo_ptr; \
    \
  ___vname__##_DataSlot    =  PROTECT(GET_SLOT(___vname__, Rip_dataSlotSym )); \
   \
  ___vname__##_nip        =  LENGTH( ___vname__##_DataSlot ); \
  ___vname__##_ip_idxptr  =  INTEGER( ___vname__##_DataSlot ); \
  ___vname__##_ip_len     = *INTEGER(GET_SLOT(___vname__, Rip_lenSym )); \
  ___vname__##_ipr        =  PROTECT(GET_SLOT(___vname__, Rip_iprSym )); \
  ___vname__##_ip_hi_ptr  =  ( !isNull( ___vname__##_ipr) ) ? (IPv4 *) INTEGER( ___vname__##_ipr )+___vname__##_ip_len  : NULL; \
  ___vname__##_ip_lo_ptr  =  ( !isNull( ___vname__##_ipr ) ) ? (IPv4 *) INTEGER( ___vname__##_ipr )  : NULL; \
  nprotected+=2;\

 
#define RIPv4r_IP_RipTbl(___vname__) \
  ___vname__##_ipr \

 
#define RIPv4r_IP_basePtr(___vname__) \
  ___vname__##_ip_lo_ptr \

 
#define RIPv6_SLOTS_GET(___vname__) \
  SEXP      ___vname__##_DataSlot, ___vname__##_ipv6; \
  int       ___vname__##_nip, ___vname__##_ip_len ; \
  int      *___vname__##_ip_idxptr; \
  uint64_t *___vname__##_ip_hi_ptr; \
  uint64_t *___vname__##_ip_lo_ptr; \
   \
  ___vname__##_DataSlot    =  PROTECT(GET_SLOT(___vname__, Rip_dataSlotSym )); \
   \
  ___vname__##_nip         =  LENGTH( ___vname__##_DataSlot ); \
  ___vname__##_ip_idxptr   =  INTEGER( ___vname__##_DataSlot ); \
  ___vname__##_ip_len      = *INTEGER(GET_SLOT(___vname__, Rip_lenSym )); \
  ___vname__##_ipv6        =  PROTECT(GET_SLOT(___vname__, Rip_ipv6Sym )); \
  ___vname__##_ip_hi_ptr   =  ( !isNull( ___vname__##_ipv6 ) ) ? (uint64_t *) REAL( ___vname__##_ipv6 )  : NULL; \
  ___vname__##_ip_lo_ptr   =  ( !isNull( ___vname__##_ipv6 ) ) ? (uint64_t *) REAL( ___vname__##_ipv6 )+___vname__##_ip_len  : NULL; \
  nprotected+=2;

 
#define RIPv6_IP_RipTbl(___vname__) \
  ___vname__##_ipv6 
  
 
#define RIPv6_IP_basePtr(___vname__) \
  ___vname__##_ip_hi_ptr \
  
 
#define RIPv6r_SLOTS_GET(___vname__) \
  SEXP      ___vname__##_DataSlot, ___vname__##_ipv6r; \
  int       ___vname__##_nip, ___vname__##_ip_len ; \
  int      *___vname__##_ip_idxptr; \
  uint64_t *___vname__##_ip_hi_ptr; \
  uint64_t *___vname__##_ip_lo_ptr; \
  ___vname__##_DataSlot   =  PROTECT(GET_SLOT(___vname__, Rip_dataSlotSym )); \
  ___vname__##_nip        =  LENGTH( ___vname__##_DataSlot ); \
  ___vname__##_ip_idxptr  =  INTEGER( ___vname__##_DataSlot ); \
  ___vname__##_ip_len     = *INTEGER(GET_SLOT(___vname__, Rip_lenSym ));  \
  ___vname__##_ipv6r      =  PROTECT(GET_SLOT(___vname__, Rip_iprSym )); \
    \
  ___vname__##_ip_lo_ptr  =  ( !isNull( ___vname__##_ipv6r ) ) ? (uint64_t *) REAL( ___vname__##_ipv6r )  : NULL; \
  ___vname__##_ip_hi_ptr  =  ( !isNull( ___vname__##_ipv6r ) ) ? (uint64_t *) REAL( ___vname__##_ipv6r )+2*___vname__##_ip_len  : NULL; \
  nprotected+=2;\
  
 
#define RIP_IP_SLOTS_GET(___vname__) \
  RIP_IP_SLOTS_DCL(___vname__) \
  ___vname__##_ipv4 =  PROTECT(GET_SLOT(___vname__, Rip_ipv4Sym )); \
  ___vname__##_ipv6 =  PROTECT(GET_SLOT(___vname__, Rip_ipv6Sym )); \
  ___vname__##_ipv = PROTECT(GET_SLOT(___vname__, Rip_dataSlotSym )); \
  nprotected+=3;
  
 
#define RIP_IPr_SLOTS_GET(___vname__) \
  RIP_IP_SLOTS_DCL(___vname__) \
  ___vname__##_ipv4r =  PROTECT(GET_SLOT(___vname__, Rip_iprSym )); \
  ___vname__##_ipv6r =  PROTECT(GET_SLOT(___vname__, Rip_iprSym )); \
  ___vname__##_ipv = PROTECT(GET_SLOT(___vname__, Rip_dataSlotSym )); \
  nprotected+=3;

#define RIPv4_RES_DCL(___res__ ) \
  IPv4  ___res__; \
  IPv4 *___res__##ptr= &___res__; \
  
 
#define RIPv4cache_RES_DCL(___res__ ) \
  IPv4  ___res__; \
  IPv4 *___res__##ptr= &___res__; \
  
 
#define RIPv4r_RES_DCL(___res__ ) \
  IPv4r  ___res__; \
  IPv4r *___res__##ptr= (IPv4r *) &___res__; \
  
 
#define RIPv6_RES_DCL(___res__ ) \
  uint64_t  ___res__[2]; \
  uint64_t *___res__##ptr= (uint64_t *) &___res__; \
  
 
#define RIPv6r_RES_DCL(___res__ ) \
  IPv6r  ___res__; \
  IPv6r *___res__##ptr= (IPv6r *) &___res__; \
  
 
#define RIPv4_ELT_PTR_DCL(___vname__, ___i__ ) \
  IPv4 ___vname__##_ip_elt_ptr= ___vname__##_ip_ptr[___vname__##_ip_idxptr[___i__]]; 
  \

 
#define RIPv4_ELT_DPTR_DCL(___vname__, ___i__ ) \
  IPv4 ___vname__##_ip_elt_ptr= ___vname__##_ip_ptr[ ___i__ ]; 
 
#define RIPv4cache_ELT_DPTR_DCL(___vname__, ___i__ )  \
  RIPv4cache_ELT_PTR_DCL(___vname__, ___i__ )
 
#define RIPv4r_ELT_DPTR_DCL(___vname__, ___i__ ) \
  IPv4   ___vname__##_ip_elt[2]; \
  ___vname__##_ip_elt[0] = ___vname__##_ip_lo_ptr[ ___i__ ]; \
  ___vname__##_ip_elt[1] = ___vname__##_ip_hi_ptr[ ___i__ ]; \
  IPv4  *___vname__##_ip_elt_ptr = (IPv4 *) &___vname__##_ip_elt; 
 
#define RIPv6_ELT_DPTR_DCL(___vname__, ___i__ ) \
  uint64_t   ___vname__##_ip_elt[2]; \
  ___vname__##_ip_elt[0] = ___vname__##_ip_hi_ptr[ ___i__ ]; \
  ___vname__##_ip_elt[1] = ___vname__##_ip_lo_ptr[ ___i__]; \
  uint64_t  *___vname__##_ip_elt_ptr = (uint64_t *) &___vname__##_ip_elt; 
 
#define RIPv6r_ELT_DPTR_DCL(___vname__, ___i__ ) \
  IPv6r   ___vname__##_ip_elt; \
  ___vname__##_ip_elt.lo.ipv6[0] = ___vname__##_ip_lo_ptr[ ___i__ ]; \
  ___vname__##_ip_elt.lo.ipv6[1] = ___vname__##_ip_lo_ptr[ ___i__ +___vname__##_ip_len]; \
  ___vname__##_ip_elt.hi.ipv6[0] = ___vname__##_ip_hi_ptr[ ___i__ ]; \
  ___vname__##_ip_elt.hi.ipv6[1] = ___vname__##_ip_hi_ptr[ ___i__ +___vname__##_ip_len]; \
  IPv6r  *___vname__##_ip_elt_ptr = (IPv6r *) &___vname__##_ip_elt; 

 
#if 0
 
#define RIPv4cache_ELT_PTR_DCL(___vname__, ___i__ ) \
  if( ___vname__##_ip_idxptr[___i__]>= RIP_CACHE_NVAL ) error("index out-of-bound:", ___vname__##_ip_idxptr[___i__]); \
  IPv4 ___vname__##_ip_elt_ptr = RIP_cache_ipv4_val[___vname__##_ip_idxptr[___i__]];
 
#else
 
#define RIPv4cache_ELT_PTR_DCL(___vname__, ___i__ )  \
  IPv4 ___vname__##_ip_elt_ptr = ( (IPv4*) ___vname__##_hip.h.iptb)[___vname__##_ip_idxptr[___i__] -1 ]; \
 
#endif

 
#define RIPv4r_ELT_PTR_DCL(___vname__, ___i__ ) \
  IPv4   ___vname__##_ip_elt[2]; \
  ___vname__##_ip_elt[0] = ___vname__##_ip_lo_ptr[___vname__##_ip_idxptr[___i__]]; \
  ___vname__##_ip_elt[1] = ___vname__##_ip_hi_ptr[___vname__##_ip_idxptr[___i__]]; \
  IPv4  *___vname__##_ip_elt_ptr = (IPv4 *) &___vname__##_ip_elt; \

 
#define RIPv4r_VAL_DGET(___vname__, ___suff__, ___i__ ) \
  IPv4   ___vname__##___suff__##_ip_elt[2]; \
  ___vname__##___suff__##_ip_elt[0] = ___vname__##_ip_lo_ptr[___vname__##_ip_idxptr[___i__]]; \
  ___vname__##___suff__##_ip_elt[1] = ___vname__##_ip_hi_ptr[___vname__##_ip_idxptr[___i__]]; 

#define RIPv4r_PTR_LO(___vname__) \
  ___vname__[0]
 
#define RIPv4r_PTR_HI(___vname__) \
  ___vname__[1]

 
#define RIPv6_ELT_PTR_DCL(___vname__, ___i__ ) \
  uint64_t   ___vname__##_ip_elt[2]; \
  ___vname__##_ip_elt[0] = ___vname__##_ip_hi_ptr[___vname__##_ip_idxptr[___i__]]; \
  ___vname__##_ip_elt[1] = ___vname__##_ip_lo_ptr[___vname__##_ip_idxptr[___i__]]; \
  uint64_t  *___vname__##_ip_elt_ptr = (uint64_t *) &___vname__##_ip_elt; \
  \
 \

#define RIPv6r_ELT_PTR_DCL(___vname__, ___i__ ) \
  IPv6r   ___vname__##_ip_elt; \
  ___vname__##_ip_elt.lo.ipv6[0] = ___vname__##_ip_lo_ptr[___vname__##_ip_idxptr[___i__]]; \
  ___vname__##_ip_elt.lo.ipv6[1] = ___vname__##_ip_lo_ptr[___vname__##_ip_idxptr[___i__]+___vname__##_ip_len]; \
  ___vname__##_ip_elt.hi.ipv6[0] = ___vname__##_ip_hi_ptr[___vname__##_ip_idxptr[___i__]]; \
  ___vname__##_ip_elt.hi.ipv6[1] = ___vname__##_ip_hi_ptr[___vname__##_ip_idxptr[___i__]+___vname__##_ip_len]; \
  IPv6r  *___vname__##_ip_elt_ptr = (IPv6r *) &___vname__##_ip_elt; \

 
#define RIPv6r_ELT_PTR_DCL_1(___vname__, ___i__ ) \
  IPv6r   ___vname__##_ip_elt; \
  ___vname__##_ip_elt.lo.ipv6[0] = ___vname__##_ip_lo_ptr[___i__]; \
  ___vname__##_ip_elt.lo.ipv6[1] = ___vname__##_ip_lo_ptr[___i__+___vname__##_ip_len]; \
  ___vname__##_ip_elt.hi.ipv6[0] = ___vname__##_ip_hi_ptr[___i__]; \
  ___vname__##_ip_elt.hi.ipv6[1] = ___vname__##_ip_hi_ptr[___i__+___vname__##_ip_len]; \
  IPv6r  *___vname__##_ip_elt_ptr = (IPv6r *) &___vname__##_ip_elt; \

#define RIPv4_ITER_SET(___vname__, ___i__, ___ipv4__)  \
  ___vname__##_ip_idx++; \
  ___vname__##_ip_ptr[___vname__##_ip_idx] = (IPv4) ___ipv4__; \
  ___vname__##_ip_idxptr[___i__]            = ___vname__##_ip_idx; \
  
 
#if 0
 
#define RIPv4cache_ITER_SET(___vname__, ___i__, ___ipv4__)  \
    \
  ___vname__##_ip_idx++;\
  ___vname__##_ip_ptr[___vname__##_ip_idx] = (IPv4) ___ipv4__; \
  ___vname__##_ip_idxptr[___i__]            = ___vname__##_ip_idx;  \

#else
 
#define RIPv4cache_ITER_SET(___vname__, ___i__, ___ipv4__)  \
  int hidx, rc; \
  rc = Rip_h32dblh_csearch_0_0(&___vname__##_hip, ___ipv4__, &hidx) ; \
  switch( rc ){ \
    case 0 : \
      ___vname__##_hip.h.htb_nh++; \
      if( ___vname__##_hip.h.htb_nh >= ___vname__##_hip.h.htb_sz ) error("full hash\n"); \
      ___vname__##_hip.h.htb[hidx] = ___vname__##_hip.h.htb_nh +1; \
      ((IPv4*)___vname__##_hip.h.iptb)[___vname__##_hip.h.htb_nh] = ___ipv4__; \
    case 1 : \
      ___vname__##_ip_idx++; \
      ___vname__##_ip_idxptr[___i__]  = ___vname__##_hip.h.htb[hidx]; \
      break; \
    default: error("hash update"); \
    break;\
  }

#endif 
  
 
#define RIPv4r_ITER_SET(___vname__, ___i__, ___ipv4r__)  \
  ___vname__##_ip_idx++; \
  ___vname__##_ip_lo_ptr[___vname__##_ip_idx ] = ___ipv4r__.lo; \
  ___vname__##_ip_hi_ptr[___vname__##_ip_idx ] = ___ipv4r__.hi; \
  ___vname__##_ip_idxptr[___i__]               = ___vname__##_ip_idx; \
  \
  
 
#define RIPv6_ITER_SET(___vname__, ___i__, ___ipv6__)  \
  ___vname__##_ip_idx++; \
  ___vname__##_ip_hi_ptr[___vname__##_ip_idx ] = ___ipv6__[0]; \
  ___vname__##_ip_lo_ptr[___vname__##_ip_idx ] = ___ipv6__[1]; \
  ___vname__##_ip_idxptr[___i__]               = ___vname__##_ip_idx; \
  \

 
#define RIPv6r_ITER_SET(___vname__, ___i__, ___ipv6__)  \
 \
  ___vname__##_ip_idx++; \
  ___vname__##_ip_lo_ptr[___vname__##_ip_idx                   ]    = ___ipv6__.lo.ipv6[0]; \
  ___vname__##_ip_lo_ptr[___vname__##_ip_idx +___vname__##_ip_len ] = ___ipv6__.lo.ipv6[1]; \
  ___vname__##_ip_hi_ptr[___vname__##_ip_idx                   ]    = ___ipv6__.hi.ipv6[0]; \
  ___vname__##_ip_hi_ptr[___vname__##_ip_idx +___vname__##_ip_len ] = ___ipv6__.hi.ipv6[1]; \
  ___vname__##_ip_idxptr[___i__                                ]    = ___vname__##_ip_idx; \
 \
  
 
#define RIPv4_IS_NA_WARN_REPROTECT(___vname__, ___nip__, ___opname__) \
{ \
  int len = ___vname__##_ip_idx+1; \
  \
    \
    \
   \
  if( (len)!= ___nip__ ){   \
     warning("%d NA introduced during " ___opname__ " operation", ___nip__ - ___vname__##_ip_idx - 1 ); \
      \
      \
      \
  \
     \
if(dbg>0)Rprintf("  cp:%d %d\n",len, ___vname__##_nipv4);  \
    if( len!=___vname__##_nipv4 ) REPROTECT(___vname__##_ipv4 = lengthgets( ___vname__##_ipv4, len ), ___vname__##_ip_protidx); \
  } \
}
  
 
#define RIPv4cache_IS_NA_WARN_REPROTECT(___vname__, ___nip__, ___opname__) \
  int len = ___vname__##_ip_idx+1; \
  if( (len)!= ___nip__ ){ \
     warning("%d NA introduced during " ___opname__ " operation", ___nip__ - ___vname__##_ip_idx - 1 ); \
if(dbg>0)Rprintf("  cp:%d %d\n",len, ___vname__##_nipv4);  \
    if( len!=___vname__##_nipv4 ) lengthgets( ___vname__##_ipv4, len ); \
  }
  
#define RIPv4r_IS_NA_WARN_REPROTECT(___vname__, ___nip__, ___opname__) \
  int len = ___vname__##_ip_idx+1; \
    \
  if( (len)!= ___nip__ ){ warning("%d NA introduced during " ___opname__ " operation", ___nip__ - len ); \
      \
      \
    REPROTECT(___vname__##_ipv4r = arraycp(___vname__##_ipv4r, ___vname__##_nip, 2, len), ___vname__##_ip_protidx); \
     \
  } \
  
 
#define RIPv6_IS_NA_WARN_REPROTECT(___vname__, ___nip__, ___opname__) \
{ \
  int len = ___vname__##_ip_idx+1; \
  \
    \
  \
  if( (len)!= ___nip__ ){  warning("%d NA introduced during " ___opname__ " operation", ___nip__ - len ); \
      \
       \
      \
      \
    if( len!=___vname__##_nipv6 ){ \
  \
       \
      REPROTECT(___vname__##_ipv6 = arraycp(___vname__##_ipv6, ___vname__##_nip, 2, len), ___vname__##_ip_protidx);  \
    } \
  } \
}
  
 
#define RIPv6r_IS_NA_WARN_REPROTECT(___vname__, ___nip__, ___opname__) \
{ \
  \
  int len = ___vname__##_ip_idx+1; \
  \
    \
  \
  if( (len)!= ___nip__ ){ warning("%d NA introduced during " ___opname__ " operation", ___nip__ - len ); \
        \
      \
      \
     \
    REPROTECT(___vname__##_ipv6r = arraycp(___vname__##_ipv6r, ___vname__##_nip, 4, len), ___vname__##_ip_protidx); \
  } \
}
  
 
#define RIPv4_SLOTS_SET(___vname__) \
  ___vname__ = SET_SLOT(___vname__, Rip_dataSlotSym, ___vname__##_DataSlot ); \
  ___vname__ = SET_SLOT(___vname__, Rip_lenSym, ScalarInteger( ___vname__##_ip_idx+1 ) ); \
  ___vname__ = SET_SLOT(___vname__, Rip_ipv4Sym, ___vname__##_ipv4 );  
      \

#if 0
 
#define RIPv4cache_SLOTS_SET(___vname__) \
  ___vname__ = SET_SLOT(___vname__, Rip_dataSlotSym, ___vname__##_DataSlot ); \
  ___vname__ = SET_SLOT(___vname__, Rip_lenSym, ScalarInteger( ___vname__##_ip_idx+1 ) ); \
   if( ___vname__##_ip_idx >=0 ){ \
    ___vname__ = SET_SLOT(___vname__, Rip_ipv4Sym, ___vname__##_ipv4 );  \
  } \
  
#else
 
#define RIPv4cache_SLOTS_SET(___vname__) \
  ___vname__ = SET_SLOT(___vname__, Rip_dataSlotSym, ___vname__##_DataSlot ); \
  ___vname__ = SET_SLOT(___vname__, Rip_lenSym, ScalarInteger( ___vname__##_ip_idx+1 ) ); \
  INTEGER(findVarInFrame( ___vname__##_Rcache, install("nh") ) )[0] = ___vname__##_hip.h.htb_nh; \
  ___vname__ = SET_SLOT(___vname__, install("cache"), ___vname__##_Rcache ); \

#endif
  
 
#define RIPv4_SLOTS_TMP_SET(___vname__,  ___nip__,  ___opname__) \
  int len = ___vname__##_ip_idx+1; \
Rprintf("  <set>len:%d %d \n", len, ___nip__);  \
  if( (len)!= ___nip__ ){ \
    warning("%d NA introduced during " ___opname__ " operation", ___nip__ - len ); \
  } \
  ___vname__ = SET_SLOT(___vname__, Rip_dataSlotSym, ___vname__##_DataSlot ); \
  ___vname__ = SET_SLOT(___vname__, Rip_lenSym, ScalarInteger( ___vname__##_ip_idx+1 ) ); \
    PROTECT( ___vname__##_ipv4 = allocVector(INTSXP, len ) ); \
    nprotected++; \
    memcpy( INTEGER( ___vname__##_ipv4 ),  ___vname__##_ip_ptr, len * sizeof(IPv4)); \
  if( ___vname__##_ip_idx >=0 ){ \
Rprintf("  <set-ipv4>\n");   \
    ___vname__ = SET_SLOT(___vname__, Rip_ipv4Sym, ___vname__##_ipv4 );   \
  } \
  R_Free( ___vname__##_ip_ptr );
  
 
#define RIPv4r_SLOTS_SET(___vname__) \
  ___vname__ = SET_SLOT(___vname__, Rip_dataSlotSym, ___vname__##_DataSlot ); \
  ___vname__ = SET_SLOT(___vname__, Rip_lenSym, ScalarInteger( ___vname__##_ip_idx+1 ) ); \
  ___vname__ = SET_SLOT(___vname__, Rip_iprSym, ___vname__##_ipv4r );   

 
#define RIPv4r_SLOTS_TMP_SET(___vname__,  ___nip__,  ___opname__) \
  int len = ___vname__##_ip_idx+1; \
 \
  if( (len)!= ___nip__ ){ \
    warning("%d NA introduced during " ___opname__ " operation", ___nip__ - len ); \
  } \
  PROTECT( ___vname__##_ipv4r = allocVector(INTSXP, 2*len ) ); \
  nprotected++; \
  memcpy( INTEGER( ___vname__##_ipv4r )      ,  ___vname__##_ip_lo_ptr, len * sizeof(IPv4)); \
  memcpy( INTEGER( ___vname__##_ipv4r ) + len,  ___vname__##_ip_hi_ptr, len * sizeof(IPv4)); \
  ___vname__ = SET_SLOT(___vname__, Rip_dataSlotSym, ___vname__##_DataSlot ); \
  ___vname__ = SET_SLOT(___vname__, Rip_lenSym, ScalarInteger( len ) ); \
  if( ___vname__##_ip_idx >=0 ){ \
    ___vname__ = SET_SLOT(___vname__, Rip_iprSym, ___vname__##_ipv4r );   \
  } \
  free( ___vname__##ipv4r_ipv4r );
  
 
#define RIPv6_SLOTS_SET(___vname__) \
  ___vname__ = SET_SLOT(___vname__, Rip_dataSlotSym, ___vname__##_DataSlot ); \
  \
  ___vname__ = SET_SLOT(___vname__, Rip_lenSym, ScalarInteger( ___vname__##_ip_idx+1 ) ); \
 \
  ___vname__ = SET_SLOT(___vname__, Rip_ipv6Sym, ___vname__##_ipv6 );  
  
 
#define RIPv6r_SLOTS_SET(___vname__) \
  ___vname__ = SET_SLOT(___vname__, Rip_dataSlotSym, ___vname__##_DataSlot ); \
  ___vname__ = SET_SLOT(___vname__, Rip_lenSym, ScalarInteger( ___vname__##_ip_idx+1 ) ); \
  ___vname__ = SET_SLOT(___vname__, Rip_iprSym, ___vname__##_ipv6r ); \
   \
 

