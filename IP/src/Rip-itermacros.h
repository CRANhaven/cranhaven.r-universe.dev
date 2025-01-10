 
#define STRINGIFY2( x) #x
#define STRINGIFY(x) STRINGIFY2(x)

#define __RIP_FNAME__( ___PREFIX__, ___IP_VERS__, ___METHOD_NAME__) \
  ___PREFIX__ ## _ip ## ___IP_VERS__ ## _ ## ___METHOD_NAME__ 
 
#define __RIP_FNAME( ___PREFIX__, ___IP_VERS__, ___METHOD_NAME__) \
  __RIP_FNAME__( ___PREFIX__, ___IP_VERS__, ___METHOD_NAME__)
  
 
#define __IP_FNAME__( ___PREFIX__, ___IP_VERS__, ___METHOD_NAME__) \
  ___PREFIX__ ## _ip ## ___IP_VERS__ ## _ ## ___METHOD_NAME__ ## _2
 
#define __IP_FNAME( ___PREFIX__, ___IP_VERS__, ___METHOD_NAME__) \
  __IP_FNAME__( ___PREFIX__, ___IP_VERS__, ___METHOD_NAME__)

#define RIP_ITER1_DCL  \
  int nip=0,i; \
 
#define RIP_ITER2_DCL  \
  int nip=0,i,i1,i2; \

 
#define RIP_ITER2_NIP_SET(___Rip1__,___Rip2__,___nip__) \
  ___nip__ = ___Rip1__##_nip > ___Rip2__##_nip ? ___Rip1__##_nip :___Rip2__##_nip; \
  ___nip__= (___Rip1__##_nip==0) | (___Rip2__##_nip==0) ? 0 : ___nip__;  \

 
#define RIP_ITERATE_STEP(___nip__,___nip1__,___nip2__) for( \
     i=i1=i2=0;  \
     i < ___nip__ ; \
     i++, i1 = (++i1 == ___nip1__) ? 0 : i1, i2 = (++i2 == ___nip2__) ? 0 : i2 \
  ) \

 
#define RIP_ITERATE_NEXT(___nip__,___nip1__,___nip2__) for( \
     ;  \
     i < ___nip__ ; \
     i++, i1 = (++i1 == ___nip1__) ? 0 : i1, i2 = (++i2 == ___nip2__) ? 0 : i2 \
  ) 

#define RIP_IP_IDSLOT_CP(___Rip_dst__,___Rip_src__) \
  SEXP ___Rip_src__##_Rid=NULL; \
  if( \
       isNull(                      GET_SLOT(___Rip_dst__, Rip_idSym ) ) \
    & !isNull( ___Rip_src__##_Rid = GET_SLOT(___Rip_src__, Rip_idSym ) ) \
  ){ \
    if( LENGTH( ___Rip_src__##_Rid )==___Rip_dst__##_nip )___Rip_dst__ = SET_SLOT(___Rip_dst__, Rip_idSym, duplicate( ___Rip_src__##_Rid ) );\
  }

#define RIP_IP_ID_CP(___Rip_dst__, ___src__) \
{ \
  SEXP ___src__##_Rid=NULL; \
  if( \
       isNull(                  GET_SLOT(___Rip_dst__, Rip_idSym ) ) \
    & !isNull( ___src__##_Rid = getAttrib(___src__, R_NamesSymbol) ) \
  ){ \
    if( LENGTH( ___src__##_Rid )==___Rip_dst__##_nip ) ___Rip_dst__ = SET_SLOT(___Rip_dst__, Rip_idSym, duplicate( ___src__##_Rid ) );\
  } \
}

#define RIP_Rvec_IDSLOT_CP(___dst__,___Rip_src__) \
  SEXP ___Rip_src__##_Rid = NULL; \
  if( \
       isNull(                      getAttrib(___dst__, R_NamesSymbol) ) \
    & !isNull( ___Rip_src__##_Rid = GET_SLOT(___Rip_src__, Rip_idSym ) ) \
  ){ \
    if( LENGTH( ___Rip_src__##_Rid )==LENGTH(___dst__) ) setAttrib(___dst__, R_NamesSymbol, duplicate( ___Rip_src__##_Rid ) );\
  }

#if 0
 
#define RIP_CHECK_IDX(___ip_idxptr, ___i__, ___nip__) \
  if(  ( ___ip_idxptr[___i__] < 0) | ( ___ip_idxptr[___i__] >= ___nip__ )  ){ \
    char errmsg[100]; \
       \
      sprintf( \
        errmsg, "index out-of-bound :" " i:%d idx:%d nip:%d"  \
        , ___i__, ___ip_idxptr[___i__], ___nip__ \
      );  \
       \
       \
      error(errmsg); \
  } \
  if ((___i__+1) % RIP_NINTERRUPT == 0) R_CheckUserInterrupt();
 
#else
 
#define RIP_CHECK_IDX(___ip_idxptr, ___i__, ___nip__) \
  if ((___i__+1) % RIP_NINTERRUPT == 0) R_CheckUserInterrupt();
 
#endif

 
#define RIP_BEGIN 

 
#define RIP_END 

#define RIP_IP_INPUT(___IPv__, ___R_t__,  ___group__, ___fname__, ___fn__) \
SEXP Rip_ip##___IPv__## ___group__##___fname__##_0( \
   SEXP Rvec  \
){ \
  SEXP Rip; \
  int nprotected=0, nip=0, i,dbg=0; \
  RIP_##___R_t__##_GET( Rvec ) \
  nip = Rvec_n; \
 \
if (dbg) Rprintf("  " STRINGIFY(___fname__) " <nip>%d\n", nip); \
    \
   \
  RIP##___IPv__##_RIP_ALLOC(Rip,nip) \
  for (i=0 ; i <nip ; i++){ \
    int valid; \
    if(  \
      RIP_##___R_t__##_ISNA(Rvec,i)   \
    ){ \
      Rip_ip_idxptr[i] = NA_INTEGER; \
        \
      continue; \
    } \
    RIP##___IPv__##_RES_DCL(res) \
      \
    valid = ___fn__( RIP_##___R_t__##_ELT_GET( Rvec, i ), resptr); \
 \
    if(valid){ \
      RIP##___IPv__##_ITER_SET( Rip, i, res)   \
    } \
    else{ \
      Rip_ip_idxptr[i] = NA_INTEGER; \
    } \
  } \
  RIP##___IPv__##_IS_NA_WARN_REPROTECT( Rip, nip, STRINGIFY(___fname__) " IP" STRINGIFY2(___IPv__) ) \
  RIP##___IPv__##_SLOTS_SET( Rip ) \
  RIP_IP_ID_CP(Rip, Rvec)   \
  UNPROTECT(nprotected); \
  return Rip; \
}

#if 0

#define RIP_OP2_ARITH_NUM(___IPv__, ___R_t__,___opname__,  ___fn__) \
SEXP Rip_ip##___IPv__##_op2_arith_##___opname__##_0( \
    SEXP Rip, SEXP Rnum\
){ \
  SEXP Res;  \
  int nprotected=0, nip=0, i,i1,i2, dbg=RNET_ARITH_DBG; \
if (dbg>0) Rprintf("\n<arith> " STRINGIFY(___opname__) "\n");   \
 \
    \
   \
  \
  RIP##___IPv__##_SLOTS_GET( Rip ) \
   \
  RIP_##___R_t__##_GET( Rnum ) \
  nip = ( ( Rip_nip>0 ) & ( Rnum_n >0 ) ) ? Rip_nip> Rnum_n ? Rip_nip : Rnum_n : 0; \
if (dbg>0) Rprintf("alloc nip:%d (%d %d)\n", nip, Rip_nip , Rnum_n);   \
   \
  RIP##___IPv__##_RIP_ALLOC(Res,nip)  \
  if( nip<1 ){UNPROTECT(nprotected); RIP##___IPv__##_SLOTS_SET( Res ) return Res;}; \
   \
  Res_nip +=0;   \
   \
  RIP_BEGIN  \
  RIP_ITERATE_STEP(nip, Rip_nip, Rnum_n){ \
if (dbg>0) Rprintf("  [%d] i1:%d %d" " i2:%d %d\n",  i, i1, Rip##_ip_idxptr[i1]==NA_INTEGER, i2, RIP_##___R_t__##_ISNA(Rnum,i2) );    \
 \
    if( \
      ( Rip##_ip_idxptr[i1]==NA_INTEGER ) || RIP_##___R_t__##_ISNA(Rnum,i2)  \
    ){ \
      Res_ip_idxptr[i] = NA_INTEGER; \
if (dbg>0) Rprintf("  [%d] continue\n", i); \
      continue; \
    } \
      \
    RIP##___IPv__##_ELT_PTR_DCL(Rip, i1) \
    RIP##___IPv__##_RES_DCL(res) \
    int valid = ___fn__( \
       Rip_ip_elt_ptr, RIP_##___R_t__##_ELT_GET( Rnum, i2 ), resptr \
    ); \
   \
    if( valid ){ \
       RIP##___IPv__##_ITER_SET( Res, i, res) \
    } \
    else{ \
      Res_ip_idxptr[i] = NA_INTEGER; \
    \
    } \
   \
  } \
  RIP_END \
if( dbg>0) Rprintf("cp\n"); \
  RIP##___IPv__##_IS_NA_WARN_REPROTECT( Res, nip, STRINGIFY(___opname__) )  \
if( dbg>0) Rprintf("slot\n"); \
  RIP##___IPv__##_SLOTS_SET( Res ) \
if( dbg>0) Rprintf("id\n"); \
  RIP_IP_IDSLOT_CP(Res, Rip ) \
  RIP_IP_ID_CP(Res, Rnum ) \
if( dbg>0) Rprintf("np %d:\n", nprotected); \
  UNPROTECT(nprotected); \
if( dbg>0) Rprintf("exit\n"); \
  return Res; \
} \
 
  \

#else
 
#define RIP_OP2_ARITH_NUM(___IPv__, ___R_t__,___opname__,  ___fn__) \
SEXP Rip_ip##___IPv__##_op2_arith_##___opname__##_0( \
    SEXP Rip, SEXP Rnum\
){ \
  SEXP Res;  \
  int nprotected=0, nip=0, i,i1,i2, dbg=RNET_ARITH_DBG; \
if (dbg>0) Rprintf("\n<arith> " STRINGIFY(___opname__) "\n");   \
 \
    \
   \
  \
  RIP##___IPv__##_SLOTS_GET( Rip ) \
   \
  RIP_##___R_t__##_GET( Rnum ) \
  nip = ( ( Rip_nip>0 ) & ( Rnum_n >0 ) ) ? Rip_nip> Rnum_n ? Rip_nip : Rnum_n : 0; \
if (dbg>0) Rprintf("alloc nip:%d (%d %d)\n", nip, Rip_nip , Rnum_n);   \
   \
  RIP##___IPv__##_RIP_ALLOC(Res,nip)  \
  if( nip<1 ){RIP##___IPv__##_SLOTS_SET( Res )UNPROTECT(nprotected);  return Res;}; \
   \
  Res_nip +=0;   \
   \
  RIP_BEGIN  \
  RIP_ITERATE_STEP(nip, Rip_nip, Rnum_n){ \
if (dbg>0) Rprintf("  [%d] i1:%d %d" " i2:%d %d\n",  i, i1, Rip##_ip_idxptr[i1]==NA_INTEGER, i2, RIP_##___R_t__##_ISNA(Rnum,i2) );    \
 \
    if( \
      ( Rip##_ip_idxptr[i1]!=NA_INTEGER ) & !RIP_##___R_t__##_ISNA(Rnum,i2)  \
    ){ \
      RIP_CHECK_IDX(Rip##_ip_idxptr , i1, nip)  \
      RIP##___IPv__##_ELT_PTR_DCL(Rip, i1) \
      RIP##___IPv__##_RES_DCL(res) \
      int valid = ___fn__( \
         Rip_ip_elt_ptr, RIP_##___R_t__##_ELT_GET( Rnum, i2 ), resptr \
      ); \
     \
      if( valid ){ \
        RIP##___IPv__##_ITER_SET( Res, i, res) \
        continue; \
      } \
    }  \
if (dbg>0) Rprintf("  [%d] NA\n", i); \
      Res_ip_idxptr[i] = NA_INTEGER; \
    \
      \
   \
  } \
  RIP_END \
if( dbg>0) Rprintf("cp\n"); \
  RIP##___IPv__##_IS_NA_WARN_REPROTECT( Res, nip, STRINGIFY(___opname__) )  \
if( dbg>0) Rprintf("slot\n"); \
  RIP##___IPv__##_SLOTS_SET( Res ) \
if( dbg>0) Rprintf("id\n"); \
  RIP_IP_IDSLOT_CP(Res, Rip ) \
  RIP_IP_ID_CP(Res, Rnum ) \
if( dbg>0) Rprintf("np %d:\n", nprotected); \
  UNPROTECT(nprotected); \
if( dbg>0) Rprintf("exit\n"); \
  return Res; \
} \
 
  \
#endif
 
 
#define RIP_OP2_ARITH_NUM_1(___IPv__, ___R_t__,___IPvRes__,___opname__,  ___fn__) \
SEXP Rip_ip##___IPvRes__##_op2_arith_##___IPv__##_##___opname__##_0( \
    SEXP Rip, SEXP Rnum\
){ \
  SEXP Res;  \
  int nprotected=0, nip=0, i,i1,i2, dbg=0; \
if (dbg>0) Rprintf("\n<arith> " STRINGIFY(___opname__) "\n");   \
 \
    \
   \
  \
  RIP##___IPv__##_SLOTS_GET( Rip ) \
   \
  RIP_##___R_t__##_GET( Rnum ) \
  nip = Rip_nip> Rnum_n ? Rip_nip : Rnum_n; \
if (dbg>0) Rprintf("alloc nip:%d %d %d\n", nip, Rip_nip , Rnum_n);   \
   \
  RIP##___IPvRes__##_RIP_ALLOC1_1(Res,nip,Rip)  \
   \
  Res_nip +=0;   \
   \
  RIP_BEGIN  \
  RIP_ITERATE_STEP(nip, Rip_nip, Rnum_n){ \
   \
 \
    if( \
      ( Rip##_ip_idxptr[i1]==NA_INTEGER ) || RIP_##___R_t__##_ISNA(Rnum,i2)  \
    ){ \
      Res_ip_idxptr[i] = NA_INTEGER; \
       \
      continue; \
    } \
      \
    RIP##___IPv__##_ELT_PTR_DCL(Rip, i1) \
    RIP##___IPvRes__##_RES_DCL(res) \
    int valid = ___fn__( \
       Rip_ip_elt_ptr, RIP_##___R_t__##_ELT_GET( Rnum, i2 ), resptr \
    ); \
   \
    if( valid ){ \
       RIP##___IPv__##_ITER_SET( Res, i, res) \
    } \
    else{ \
      Res_ip_idxptr[i] = NA_INTEGER; \
    \
    } \
   \
  } \
  RIP_END \
if( dbg>0) Rprintf("cp\n"); \
   \
if( dbg>0) Rprintf("slot\n"); \
  RIP##___IPvRes__##_SLOTS_SET( Res ) \
if( dbg>0) Rprintf("id\n"); \
  RIP_IP_IDSLOT_CP(Res, Rip ) \
  RIP_IP_ID_CP(Res, Rnum ) \
if( dbg>0) Rprintf("np %d:\n", nprotected); \
  UNPROTECT(nprotected); \
if( dbg>0) Rprintf("exit\n"); \
  return Res; \
} \

#define RIP_OP1_ARITH_IP(___IPv__, ___opname__,  ___fn__) \
SEXP Rip_ip##___IPv__##_op1_arith_##___opname__##_0( \
    SEXP Rip  \
){ \
  SEXP Res; \
  int nprotected=0, nip=0, i, dbg=0;  \
  RIP##___IPv__##_SLOTS_GET( Rip ) \
    \
   \
  nip = Rip_nip; \
    \
  RIP##___IPv__##_RIP_ALLOC(Res,nip) \
  Res_nip +=0;   \
  RIP_BEGIN \
    \
  for (i=0 ; i <  nip; i++){ \
   \
    if( \
      Rip##_ip_idxptr[i]==NA_INTEGER \
    ){ \
      Res_ip_idxptr[i] = NA_INTEGER; \
       \
      continue; \
    } \
    RIP_CHECK_IDX(Rip##_ip_idxptr , i, nip) \
     \
    RIP##___IPv__##_ELT_PTR_DCL(Rip, i) \
     \
    RIP##___IPv__##_RES_DCL(res) \
    int valid = ___fn__( \
       Rip_ip_elt_ptr, resptr \
    ); \
   \
    if( valid ){ \
       RIP##___IPv__##_ITER_SET( Res, i, res) \
    } \
    else{ \
      Res_ip_idxptr[i] = NA_INTEGER; \
    } \
   \
  } \
  RIP_END \
  RIP##___IPv__##_IS_NA_WARN_REPROTECT( Res, nip, STRINGIFY(___opname__) )   \
  RIP##___IPv__##_SLOTS_SET( Res ) \
  RIP_IP_IDSLOT_CP(Res, Rip ) \
  UNPROTECT(nprotected); \
  return Res; \
} \

#define RIP_OP2_ARITH_IP(___IPv__, ___opname__,  ___fn__) \
SEXP Rip_ip##___IPv__##_op2_arith_##___opname__##_0( \
    SEXP Rip, SEXP Rip2  \
){ \
  SEXP Res;  \
  int nprotected=0, nip=0, i,i1,i2, dbg=RNET_ARITH_DBG; \
 \
  RIP##___IPv__##_SLOTS_GET( Rip ) \
  RIP##___IPv__##_SLOTS_GET( Rip2 ) \
    \
  nip = ( ( Rip_nip>0 ) & ( Rip2_nip >0 ) ) ? Rip_nip> Rip2_nip ? Rip_nip : Rip2_nip : 0; \
   \
  RIP##___IPv__##_RIP_ALLOC(Res,nip) \
  if( nip<1 ){UNPROTECT(nprotected); RIP##___IPv__##_SLOTS_SET( Res ) return Res;}; \
   \
  Res_nip +=0;   \
  RIP_BEGIN \
  if( (Rip_nip==Rip2_nip) && ( Rip_nip==RIP##___IPv__##_IP_LEN_GET(Rip) ) && ( RIP##___IPv__##_IP_LEN_GET(Rip)==RIP##___IPv__##_IP_LEN_GET(Rip2) )){ \
 \
    for(i=0; i < Rip_nip; i++ ){ \
        \
      RIP##___IPv__##_ELT_DPTR_DCL(Rip, i) \
      RIP##___IPv__##_ELT_DPTR_DCL(Rip2, i) \
      RIP##___IPv__##_RES_DCL(res) \
      int valid = ___fn__( \
         Rip_ip_elt_ptr, Rip2_ip_elt_ptr, resptr \
      ); \
      if( valid ){ \
         RIP##___IPv__##_ITER_SET( Res, i, res) \
      } \
      else{ \
        Res_ip_idxptr[i] = NA_INTEGER; \
      } \
    } \
  }else{ \
 \
  RIP_ITERATE_STEP(nip, Rip_nip, Rip2_nip){ \
   \
    if( \
      ( Rip##_ip_idxptr[i1]==NA_INTEGER ) || ( Rip2##_ip_idxptr[i2]==NA_INTEGER ) \
    ){ \
      Res_ip_idxptr[i] = NA_INTEGER; \
       \
      continue; \
    } \
    RIP_CHECK_IDX(Rip##_ip_idxptr , i1, nip) \
    RIP_CHECK_IDX(Rip2##_ip_idxptr, i2, nip)  \
    RIP##___IPv__##_ELT_PTR_DCL(Rip, i1) \
    RIP##___IPv__##_ELT_PTR_DCL(Rip2, i2) \
    RIP##___IPv__##_RES_DCL(res) \
    int valid = ___fn__( \
       Rip_ip_elt_ptr, Rip2_ip_elt_ptr, resptr \
    ); \
   \
    if( valid ){ \
       RIP##___IPv__##_ITER_SET( Res, i, res) \
    } \
    else{ \
      Res_ip_idxptr[i] = NA_INTEGER; \
    } \
   \
  } \
  } \
  RIP_END \
  RIP##___IPv__##_IS_NA_WARN_REPROTECT( Res, nip, STRINGIFY(___opname__) )   \
  RIP##___IPv__##_SLOTS_SET( Res ) \
  RIP_IP_IDSLOT_CP(Res, Rip ) \
  RIP_IP_IDSLOT_CP(Res, Rip2 ) \
  UNPROTECT(nprotected); \
  return Res; \
} \
 
 
#define RIP_OP2_ARITH_IP_1(___IPv1__, ___IPv2__, ___IPvRes__, ___opname__,  ___fn__) \
SEXP Rip_ip##___IPvRes__##_op2_arith_##___IPv1__##_##___opname__##_##___IPv2__##_0( \
    SEXP Rip, SEXP Rip2  \
){ \
  SEXP Res;  \
  int nprotected=0, nip=0, i,i1,i2 ;   \
 \
  RIP##___IPv1__##_SLOTS_GET( Rip ) \
  RIP##___IPv2__##_SLOTS_GET( Rip2 ) \
  nip = Rip_nip> Rip2_nip ? Rip_nip : Rip2_nip; \
   \
  RIP##___IPvRes__##_RIP_ALLOC2_1(Res,nip, Rip, Rip2) \
   \
  Res_nip +=0;   \
  RIP_BEGIN \
  RIP_ITERATE_STEP(nip, Rip_nip, Rip2_nip){ \
   \
    if( \
      ( Rip##_ip_idxptr[i1]==NA_INTEGER ) || ( Rip2##_ip_idxptr[i2]==NA_INTEGER ) \
    ){ \
      Res_ip_idxptr[i] = NA_INTEGER; \
       \
      continue; \
    } \
     \
    RIP##___IPv1__##_ELT_DPTR_DCL(Rip, i1) \
    RIP##___IPv2__##_ELT_DPTR_DCL(Rip2, i2) \
    RIP##___IPvRes__##_RES_DCL(res) \
    int valid = ___fn__( \
       Rip_ip_elt_ptr, Rip2_ip_elt_ptr, resptr \
    ); \
   \
    if( valid ){ \
       RIP##___IPvRes__##_ITER_SET( Res, i, res) \
    } \
    else{ \
      Res_ip_idxptr[i] = NA_INTEGER; \
    } \
   \
  } \
  RIP_END \
    \
  RIP##___IPvRes__##_SLOTS_SET( Res ) \
  RIP_IP_IDSLOT_CP(Res, Rip ) \
  RIP_IP_IDSLOT_CP(Res, Rip2 ) \
  UNPROTECT(nprotected); \
  return Res; \
} \

#define RIPv4_IP_LEN_GET(___vname__) \
  LENGTH(___vname__##_ipv4 )
 
#define RIPv4r_IP_LEN_GET(___vname__) \
  LENGTH(___vname__##_ipr )/2
 
#define RIPv6_IP_LEN_GET(___vname__) \
  LENGTH(___vname__##_ipv6 )/2
 
#define RIPv6r_IP_LEN_GET(___vname__) \
  LENGTH(___vname__##_ipv6r )/4
 
 
#define RIP_OP2_BOOL(___IPv__, ___opname__,  ___fn__) \
SEXP Rip_ip##___IPv__##_op2_bool_##___opname__##_0( \
    SEXP Rip1, SEXP Rip2 \
){ \
  SEXP Res; \
  int nprotected=0, nip=0, i,i1,i2, *resptr, dbg=RNET_BOOL_DBG;   \
  int idx1=-1, idx2=-1;  \
   \
  RIP##___IPv__##_SLOTS_GET( Rip1 ) \
  RIP##___IPv__##_SLOTS_GET( Rip2 ) \
  nip = ( (Rip1_nip >0) & (Rip2_nip>0) ) ? Rip1_nip > Rip2_nip ? Rip1_nip : Rip2_nip : 0; \
 \
    \
  PROTECT( Res = allocVector(LGLSXP, nip ) ); \
  nprotected++; \
  if( nip<1 ){UNPROTECT(nprotected); return Res;}; \
  resptr = INTEGER( Res ); \
  RIP_BEGIN \
  if( (Rip1_nip==Rip2_nip) && ( Rip1_nip==RIP##___IPv__##_IP_LEN_GET(Rip1) ) && ( RIP##___IPv__##_IP_LEN_GET(Rip1)==RIP##___IPv__##_IP_LEN_GET(Rip2) ) ){ \
  \
    for(i=0; i < Rip1_nip; i++ ){ \
        \
      RIP##___IPv__##_ELT_DPTR_DCL(Rip1, i) \
      RIP##___IPv__##_ELT_DPTR_DCL(Rip2, i) \
      resptr[i] = ___fn__( \
         Rip1_ip_elt_ptr \
         , Rip2_ip_elt_ptr \
      ); \
        \
    } \
  }else{ \
 \
    RIP_ITERATE_STEP(nip, Rip1_nip, Rip2_nip){ \
      idx1 = (i1 == 0) ? 0 : idx1+1; \
      idx2 = (i2 == 0) ? 0 : idx2+1; \
if(dbg) Rprintf("  [%d] <>%d %d" " <>%d %d\n",  i, i1, Rip1##_ip_idxptr[i1], i2, Rip2##_ip_idxptr[i2] );    \
   \
      if(  \
           ( Rip1_ip_idxptr[i1]==NA_INTEGER )  \
        || ( Rip2_ip_idxptr[i2]==NA_INTEGER ) \
      ){ \
        resptr[i] = NA_INTEGER; \
          \
      } else{ \
        RIP##___IPv__##_ELT_PTR_DCL(Rip1, idx1) \
        RIP##___IPv__##_ELT_PTR_DCL(Rip2, idx2) \
        RIP_CHECK_IDX(Rip1##_ip_idxptr, idx1, nip) \
        RIP_CHECK_IDX(Rip2##_ip_idxptr, idx2, nip)     \
          \
  \
        resptr[i] = ___fn__( \
           Rip1_ip_elt_ptr \
           , Rip2_ip_elt_ptr \
        );  \
          \
      } \
    } \
  } \
    \
  RIP_END \
  RIP_Rvec_IDSLOT_CP(Res, Rip1 ) \
  RIP_Rvec_IDSLOT_CP(Res, Rip2 ) \
  UNPROTECT(nprotected); \
  return Res; \
}
 
 
#define RIP_OP2_BOOL_1(___IPv1__, ___IPv2__, ___opname__,  ___fn__) \
SEXP Rip_ip##___IPv1__##_op2_bool_##___IPv1__##_##___opname__##_##___IPv2__##_0( \
    SEXP Rip1, SEXP Rip2 \
){ \
  SEXP Res; \
  int nprotected=0, nip=0, i,i1,i2, *resptr;   \
  int idx1=-1, idx2=-1;  \
   \
  RIP##___IPv1__##_SLOTS_GET( Rip1 ) \
  RIP##___IPv2__##_SLOTS_GET( Rip2 ) \
  nip = Rip1_nip > Rip2_nip ? Rip1_nip : Rip2_nip; \
 \
    \
  PROTECT( Res = allocVector(LGLSXP, nip ) ); \
  resptr = INTEGER( Res ); \
  nprotected++; \
  RIP_BEGIN \
  RIP_ITERATE_STEP(nip, Rip1_nip, Rip2_nip){ \
    idx1 = (i1 == 0) ? 0 : idx1+1; \
    idx2 = (i2 == 0) ? 0 : idx2+1; \
   \
    \
    if(  \
         ( Rip1_ip_idxptr[i1]==NA_INTEGER )  \
      || ( Rip2_ip_idxptr[i2]==NA_INTEGER ) \
    ){ \
      resptr[i] = NA_INTEGER; \
      continue; \
    } \
    RIP##___IPv1__##_ELT_PTR_DCL(Rip1, idx1) \
    RIP##___IPv2__##_ELT_PTR_DCL(Rip2, idx2)\
       \
      \
  \
    resptr[i] = ___fn__( \
       Rip1_ip_elt_ptr \
       , Rip2_ip_elt_ptr \
    );  \
      \
  } \
    \
  RIP_END \
  RIP_Rvec_IDSLOT_CP(Res, Rip1 ) \
  RIP_Rvec_IDSLOT_CP(Res, Rip2 ) \
  UNPROTECT(nprotected); \
  return Res; \
}

