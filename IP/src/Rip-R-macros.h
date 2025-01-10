
 
#define int32_NA NA_INTEGER
 
#define int64_NA LLONG_MIN
#define NA_INT64 LLONG_MIN
 
#define float64_NA NA_REAL
 
#define string_NA NA_STRING

 
#define RIP_int32_GET( ___Rint__ ) \
  int *___Rint__##_ptr; \
  int ___Rint__##_n    = LENGTH( ___Rint__ ); \
  ___Rint__##_ptr   = INTEGER(___Rint__); \
 
#define RIP_int32_ISNA( ___Rint__, ___i__ ) \
  (___Rint__##_ptr[___i__]==NA_INTEGER )
 
#define RIP_int32_ELT_GET( ___Rint__ , ___i__) \
  ___Rint__##_ptr[___i__] \
  
 
#define RIP_int64_GET( ___Rint__ ) \
  uint64_t *___Rint__##_ptr; \
  int ___Rint__##_n    = LENGTH( ___Rint__ ); \
  ___Rint__##_ptr   = (uint64_t *) REAL(___Rint__); \
 
#define RIP_int64_ISNA( ___Rint__, ___i__ ) \
  (___Rint__##_ptr[___i__]==NA_INT64 )
 
#define RIP_int64_ELT_GET( ___Rint__ , ___i__) \
  ___Rint__##_ptr[___i__] \

 
#define RIP_float64_GET( ___Rfl64__ ) \
  double *___Rfl64__##_ptr; \
  int ___Rfl64__##_n     = LENGTH( ___Rfl64__ ); \
  ___Rfl64__##_ptr   = REAL(___Rfl64__); \
 
#define RIP_float64_ISNA( ___Rfl64__, ___i__ ) \
  (___Rfl64__##_ptr[___i__]==NA_REAL )
 
#define RIP_float64_ELT_GET( ___Rfl64__ , ___i__) \
  ___Rfl64__##_ptr[___i__] \
  
 
#define RIP_string_ALLOC(___Rstring__, ___nip__) \
  SEXP ___Rstring__; \
  PROTECT( ___Rstring__ = allocVector(STRSXP, ___nip__ ) );\
 
#define RIP_string_RES_SET( ___Rstring__, ___i__, ___fn__, ___arg__ ) \
  char ipstringbuff[IP6R_STRING_SZMAX];\
  ___fn__(___arg__, (char*) &ipstringbuff, IP6R_STRING_SZMAX); \
  SET_STRING_ELT( ___Rstring__, i, mkChar(ipstringbuff)); \
 
#define RIP_string_NA_SET( ___Rstring__, ___i__) \
  SET_STRING_ELT( ___Rstring__, i, NA_STRING); \
  
 
#define RIP_string_GET( ___Rstring__ ) \
  int ___Rstring__##_n     = LENGTH( ___Rstring__ ); \
 
#define RIP_string_ISNA( ___Rstring__ , ___i__) \
  (STRING_ELT(___Rstring__, ___i__)==NA_STRING ) \
 
#define RIP_string_ELT_GET( ___Rstring__ , ___i__) \
  CHAR(STRING_ELT(___Rstring__, ___i__)) \
 
