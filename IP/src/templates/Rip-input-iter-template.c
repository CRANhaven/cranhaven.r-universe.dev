 
 
#if defined( ___IP_IPv4_PARSE_ITER_BODY__ )

#  if defined(___IP_IPv4_PARSE_INPUT__)
  SEXP Rip;
#  endif
  int nipstrings=0, i=0; 
  int nprotected=0;
  nipstrings = Rf_length( Ripstrings ); 
  RIPv4_RIP_ALLOC(Rip, nipstrings)
   
  if( Rip_nip<1 ){
    UNPROTECT(nprotected);
    RIPv4_SLOTS_SET( Rip )
    return Rip;
  }
   
  for (i=0 ; i <nipstrings ; i++){    
    __m128i v0;
    int nc=0;
     
    SEXP rs = STRING_ELT(Ripstrings, i); 
     
    if( rs!=NA_STRING ){

      const char *s = CHAR(rs);
if(dbg){Rprintf("\ni:%d %s\n", i, s);}
       
      nc = Rippaddr_ipv4string_loadu_si128(s, &v0);
      
#define ___IP_IPv4_PARSE_VALID_BODY__
#include "Rip-input-body-template.c"        
#undef  ___IP_IPv4_PARSE_VALID_BODY__
       
      __m128i vip;
       
       
      int gt255;

#  if defined(___IP_IPv4_PARSE_LUT__) 
      int n, n0, n1, n2, n3;
      __m128i vShuffle;
#endif

      switch( mvalid ){
         
        case 3 :
        {
#define ___IP_IPv4_PARSE_FIXED_BODY__
#include "Rip-input-body-template.c"        
#undef ___IP_IPv4_PARSE_FIXED_BODY__
        }
        break;
         
        case 1 :
        {
#define ___IP_IPv4_PARSE_BODY__
#define ___IP_IPv4_PARSE_BODY_CONTINUE_
#include "Rip-input-body-template.c"        
#undef ___IP_IPv4_PARSE_BODY__
#undef ___IP_IPv4_PARSE_BODY_CONTINUE_
        }
        break;
         
        default:
          Rip_ip_idxptr[i] = NA_INTEGER; 
      }

    }else{ 
      Rip_ip_idxptr[i] = NA_INTEGER;
    }
  }  
   
  RIPv4_IS_NA_WARN_REPROTECT( Rip, nipstrings, "input IPv4" ) 
  RIPv4_SLOTS_SET( Rip ) 
  RIP_IP_ID_CP(Rip, Ripstrings) 
  UNPROTECT(nprotected); 
  return Rip; 

#else
  pragma error("missing iter body")
#endif
 
