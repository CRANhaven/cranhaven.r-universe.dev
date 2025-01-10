 
 
#if defined (__unix__) || (defined (__APPLE__)  )
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>  
#endif  
 
#include "Rip.h"

#define __BSWAP_64(x)                        \
    ((((x) & 0xff00000000000000ull) >> 56)   \
   | (((x) & 0x00ff000000000000ull) >> 40)   \
   | (((x) & 0x0000ff0000000000ull) >> 24)   \
   | (((x) & 0x000000ff00000000ull) >> 8)    \
   | (((x) & 0x00000000ff000000ull) << 8)    \
   | (((x) & 0x0000000000ff0000ull) << 24)   \
   | (((x) & 0x000000000000ff00ull) << 40)   \
   | (((x) & 0x00000000000000ffull) << 56))

#ifdef _WIN32  
 
#include <windows.h>
#include <ws2tcpip.h>
 
int Rip_wstart = 0;
 
void Rip_WSAStartup(void){
   
  if( Rip_wstart!=1 ){
     
    WSADATA wsaData;
    int rc;
     
    rc = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (rc != 0) {
      error("WSAStartup failed: %d\n", rc);

    }
    Rip_wstart = 1;
  }
}
 
SEXP Rip_WSACleanup(void){
  int rc = 0;
  if( Rip_wstart==1 ){
     
    rc = WSACleanup();
    if (rc != 0) {
      warning("WSACleanup failed: %d\n", rc);
    }
  }
  return ScalarInteger(rc);
}
#else
 
SEXP Rip_WSAStartup(void){
  error("calling WSAStartup function in a non-Windows environment");
  return R_NilValue;
}
 
SEXP Rip_WSACleanup(void){
  error("calling WSACleanup function in a non-Windows environment");
  return R_NilValue;
}
#endif 

#if defined( __RIP_IDN__ ) && ( defined(__unix__) || defined( _WIN32 ) )

#include <stringprep.h>  
#include <punycode.h>
#include <idna.h>
#ifdef WITH_TLD
# include <tld.h>
#endif

 
SEXP
  Rip_idn_defineGlobalVar_0(
    SEXP rho
){
   
  if( !isEnvironment(rho) ) error("rho is not an environment");
   
  SEXP Rip_idn_IDNA_DEFAULT = ScalarInteger(0);
  setVar(install("IDNA_DEFAULT") , Rip_idn_IDNA_DEFAULT, rho );
   
  SEXP Rip_idn_IDNA_ALLOW_UNASSIGNED = ScalarInteger(IDNA_ALLOW_UNASSIGNED);
 
  setVar(install("IDNA_ALLOW_UNASSIGNED") , Rip_idn_IDNA_ALLOW_UNASSIGNED, rho );
   
  SEXP Rip_idn_IDNA_USE_STD3_ASCII_RULES = ScalarInteger(IDNA_USE_STD3_ASCII_RULES);
  setVar(install("IDNA_USE_STD3_ASCII_RULES") , Rip_idn_IDNA_USE_STD3_ASCII_RULES, rho );
   
  setVar(install("IP_IDN") , ScalarLogical(1), rho );
   
  return ScalarLogical(1);
}

#define RIP_IDN_0(___fn__, ___fname__) \
SEXP Rip_idn_##___fname__##_0( \
  SEXP Rinput, SEXP Rflags \
){ \
  int n=0, i,i1,i2,nprotected=0; \
  RIP_string_GET(Rinput) \
  nprotected++; \
  RIP_int32_GET( Rflags ) \
    \
  n = ( Rinput_n>0 ) & ( Rflags_n >0 ) ? Rinput_n> Rflags_n ? Rinput_n : Rflags_n : 0;  \
   \
  RIP_string_ALLOC(Routput, n) \
  if( n==0 ){UNPROTECT(nprotected); return Routput; }\
   \
  RIP_ITERATE_STEP(n, Rinput_n, Rflags_n){  \
   \
    if( !RIP_string_ISNA(Rinput, i1) ){ \
      SEXP in  = STRING_ELT( Rinput, i1); \
 \
      SEXP out = NULL; \
      if( \
        (out= ___fn__(in, RIP_int32_ELT_GET( Rflags, i2) ))!=NULL \
      ){ \
 \
 \
        SET_STRING_ELT( Routput, i, out); \
        continue; \
      } \
    } \
    RIP_string_NA_SET( Routput, i ) \
  } \
  UNPROTECT(nprotected); \
  return Routput; \
}

 
SEXP
  Rip_idna_encode_0(
      SEXP Rinput
     
    , int flags
){
  const char *input;
  char       *output;
  int         rc;
   
   
  input = translateCharUTF8( Rinput );
 
   
  if(
    (rc = idna_to_ascii_8z(
       input, &output, flags
    ))!= IDNA_SUCCESS
  ){
    warning("%s for '%s'",  idna_strerror(rc), CHAR(Rinput) );
    return 0;
  }
 
   
  SEXP Routput = PROTECT(
     
    mkCharLenCE(output, strlen(output), CE_UTF8)
  );

  free(output);
 
  UNPROTECT(1);
   
  return Routput;
}
 
RIP_IDN_0(Rip_idna_encode_0, idna_encode)

 
SEXP
  Rip_idna_decode_0(
      SEXP Rinput
    , int  flags
){
  SEXP        Rval;
  const char *input;
  char       *output;
  int         rc;
   
   
  input = translateCharUTF8(Rinput);
   
  if(
    (rc = idna_to_unicode_8z8z(
       input, &output, flags
    ))!= IDNA_SUCCESS
  ){
    warning("%s",  idna_strerror(rc) );
    return ScalarString( NA_STRING );
  }
   
  Rval =  PROTECT(
     
    mkCharLenCE(output, strlen(output), CE_UTF8)
     
  );
   
  free(output);
  UNPROTECT(1);
   
  return Rval;
}
 
RIP_IDN_0(Rip_idna_decode_0, idna_decode)

 
SEXP
  Rip_puny_encode_0(
      SEXP Rinput
     
    , int flags
){
  SEXP           Rval;
  const char    *input;
  char           output[BUFSIZ];
  punycode_uint *input_ucs4;
  size_t         ucs4_len, output_len;
  int            rc;
   
   
  input = translateCharUTF8( Rinput );
 
   
  input_ucs4 = stringprep_utf8_to_ucs4 (input, -1, &ucs4_len);
   
  output_len = BUFSIZ - 1;
  rc = punycode_encode (ucs4_len, input_ucs4, NULL, &output_len, output);
   
  free(input_ucs4);
   
  if(rc != PUNYCODE_SUCCESS){
    error("%s for '%s'", punycode_strerror(rc), CHAR(Rinput) );

  }
  output[output_len] = '\0';
   
  Rval = mkChar(reEnc(output, CE_UTF8, getCharCE( Rinput ), 1));
   
  return (Rval);
}
 
RIP_IDN_0(Rip_puny_encode_0, puny_encode)

#else

#define RIP_IDN_MISSING_ERRMSG \
  "IP package was compiled without libidn."
 
SEXP Rip_idn_defineGlobalVar_0(
    SEXP rho
){
   
   
  return ScalarLogical(0);
}
 
SEXP Rip_idn_idna_encode_0( 
  SEXP Rinput, SEXP Rflags 
){ 
  error(
     RIP_IDN_MISSING_ERRMSG  
  );
   
  return R_NilValue;
}
 
SEXP Rip_idn_idna_decode_0( 
  SEXP Rinput, SEXP Rflags 
){ 
  error(
    RIP_IDN_MISSING_ERRMSG  
  );
   
  return R_NilValue;
}
 
#undef RIP_IDN_MISSING_ERRMSG

#endif  

#if 1
 
SEXP 
  Rip_ipv4_gethostbyaddr_0(
    SEXP Rip 
     
){ 
 
#if defined (__unix__) || (defined (__APPLE__)  )  || (defined (_WIN32)  )
  int i, nip=0, nprotected=0; 
#ifdef _WIN32
  Rip_WSAStartup(); 
#endif
    
  
  RIPv4_SLOTS_GET( Rip ) 
  nip = Rip_nip; 
  
    
  RIP_string_ALLOC(Res, nip);  
  nprotected++;
   
   
  RIP_BEGIN 
  for (i=0 ; i <  nip; i++){ 

    if( 
      Rip_ip_idxptr[i]!=NA_INTEGER 
    ){ 
       
      RIP_CHECK_IDX(Rip_ip_idxptr , i, nip) 
       
      struct hostent *hent;
       
      RIPv4_ELT_PTR_DCL(Rip, i) 

      IPv4 ip4n=htonl(Rip_ip_elt_ptr);
       
 
#ifdef _WIN32
      hent = gethostbyaddr((char*) &ip4n, sizeof ip4n, AF_INET);
#else
      hent = gethostbyaddr(&ip4n, sizeof ip4n, AF_INET);
#endif      
       
      if( hent!=NULL){
 
        SET_STRING_ELT( Res, i, mkChar(hent->h_name));
      }
      else{
         
         
        RIP_string_NA_SET(Res, i); 
      }
       
    }else{ 
      RIP_string_NA_SET(Res, i); 
    } 
  } 
   
  RIP_END 
  UNPROTECT( nprotected ); 
  return Res; 
#else
  char errmsg[256];
  sprintf(errmsg, "unavailable '%s' function at line %d in file '%s'.", __func__, __LINE__, __FILE__);
   
  error("%s", errmsg);
  return ScalarLogical(0);
#endif
} 

SEXP Rip_ipv6_gethostbyaddr_0(SEXP Rip ){ 
 
#if defined (__unix__) || (defined (__APPLE__) ) || (defined (_WIN32) )
  int i, nip=0, nprotected=0; 
#ifdef _WIN32
  Rip_WSAStartup(); 
#endif  
  RIPv6_SLOTS_GET( Rip ) 
  nip = Rip_nip; 
  
  RIP_string_ALLOC(Res, nip);  
  nprotected+=1;
   
  RIP_BEGIN 
  for (i=0 ; i <  nip; i++){ 
     
    if( 
      Rip_ip_idxptr[i]!=NA_INTEGER 
    ){ 
       
      RIP_CHECK_IDX(Rip_ip_idxptr , i, nip) 
       
      struct hostent *hent=NULL;
       
      RIPv6_ELT_PTR_DCL(Rip, i) 
 
       
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
          uint64_t ip6n[2]={
            __BSWAP_64( Rip_ip_elt_ptr[0] )
            , __BSWAP_64( Rip_ip_elt_ptr[1] )
          };

#else
          uint64_t ip6n[2]={
             Rip_ip_elt_ptr[0]
            , Rip_ip_elt_ptr[1]
          };
#endif

#ifdef _WIN32
      hent = gethostbyaddr((char*)ip6n, sizeof ip6n , AF_INET6);
#else      
       
      hent = gethostbyaddr(ip6n, sizeof ip6n , AF_INET6);
#endif      
       
      if( hent!=NULL){
 
         
        SET_STRING_ELT( Res, i, mkChar(hent->h_name));
      }
      else{
        RIP_string_NA_SET(Res, i); 
      }
    }else{ 
      RIP_string_NA_SET(Res, i); 
    } 
  } 
   
  RIP_END 
  UNPROTECT( nprotected ); 
  return Res; 
#else
  char errmsg[256];
  sprintf(errmsg, "unavailable '%s' function at line %d in file '%s'.", __func__, __LINE__, __FILE__);
   
  error("%s", errmsg);
  return ScalarLogical(0);
#endif
} 

SEXP Rip_getaddrinfo_0(SEXP Rhostnames ){ 
 
#if defined (__unix__) || (defined (__APPLE__) ) || (defined (_WIN32) )
   
  int i,j, nhosts 
    , nprotected=0
  ; 
   
  SEXP Rhost
    , Ripv4_hptr, Ripv4, Ripv4_ip
    , Ripv6_hptr, Ripv6, Ripv6_ip
  ;
   
  PROTECT_INDEX Ripv4_ip_protidx, Ripv6_ip_protidx;
#ifdef _WIN32
  Rip_WSAStartup(); 
#endif    
  IPv4     *ipv4_ip_ptr;
  uint64_t *ipv6_ip_ptr;
  int nipv4, *ipv4_hptr, ipv4_nacc=0
    , nipv6, *ipv6_hptr, ipv6_nacc=0
  ;
  char errmsg[256];
   
  nhosts = LENGTH( Rhostnames );
   
  nipv6 = nipv4 = (int) ceil( (double) nhosts * 1.6);
   
  PROTECT_WITH_INDEX( Ripv4_ip = allocVector(INTSXP, nipv4 ), &Ripv4_ip_protidx); 
  nprotected++;
  ipv4_ip_ptr = (IPv4 *) INTEGER( Ripv4_ip ); 
   
  PROTECT( Ripv4_hptr = allocVector(INTSXP, nhosts+1 ) ); 
  nprotected++;
  ipv4_hptr = INTEGER(Ripv4_hptr);
  ipv4_hptr[0]=0;
   
   
  PROTECT_WITH_INDEX( Ripv6_ip = allocMatrix(REALSXP, nipv6, 2 ), &Ripv6_ip_protidx); 
  nprotected++;
  ipv6_ip_ptr = (uint64_t *) REAL( Ripv6_ip ); 
   
  PROTECT( Ripv6_hptr = allocVector(INTSXP, nhosts+1 ) ); 
  nprotected++;
  ipv6_hptr = INTEGER(Ripv6_hptr);
  ipv6_hptr[0]=0;

  for ( i=0 ; i<nhosts ; i++ ){
     
    int         rc;
    const char *hostname;
     
     
    ipv4_hptr[i+1] = ipv4_hptr[i];
    ipv6_hptr[i+1] = ipv6_hptr[i];
     
     
    if( ( STRING_ELT( Rhostnames, i) )!=NA_STRING ){
       
      struct addrinfo hints, *res, *resptr;
       
      hostname = translateChar( STRING_ELT( Rhostnames, i) );  

      memset(&hints, 0, sizeof hints);
       
      hints.ai_family   = AF_UNSPEC;    
      hints.ai_socktype = SOCK_STREAM;  
 
#ifdef HAVE_LIBIDN   
Rprintf("LIBIDN\n" );   
      hints.ai_flags |= AI_IDN;
#endif      
       
      if (
        ( rc = getaddrinfo(hostname, NULL, &hints, &res) ) != 0
      ) {

        switch( rc ){
           
          case EAI_NONAME:
#ifdef __USE_GNU
           
          case EAI_NODATA:
#endif
             
            warning("hostname '%s': '%s' (%d)\n", hostname, gai_strerror( rc ), rc);
            
          break;
          default:

            error( "hostname : %s", gai_strerror( rc ) );

          break;
        }     
         
        continue;
      }
       
      for( resptr = res, j = 0; resptr != NULL; resptr = resptr->ai_next, j++ ) {
         
         
        void *addr;
         
         
        if ( resptr->ai_family == AF_INET) {  
           
          if( ipv4_nacc>=nipv4 ){
 
            int nip = (int) ceil( ( (double) nipv4 )*1.5);
 
            REPROTECT( Ripv4_ip = lengthgets(Ripv4_ip, nip), Ripv4_ip_protidx);
            nipv4 = nip;
            ipv4_ip_ptr = (IPv4 *) INTEGER( Ripv4_ip ); 
          }
           
          struct sockaddr_in *ipv4 = (struct sockaddr_in *) resptr->ai_addr;
           
          addr = &(ipv4->sin_addr);
           
          IPv4 ripv4 = ntohl( ipv4->sin_addr.s_addr );
#if 0
 
char ipstringbuff[IPv4_STRING_SZMAX]; 
 
ipv4_raw_output(ripv4, (char*) &ipstringbuff,IP4_STRING_SZMAX);   
Rprintf("      %s\n", ipstringbuff);
 
inet_ntop(AF_INET, addr, ipstringbuff, INET_ADDRSTRLEN);
Rprintf("IPv4: %s %d\n", ipstringbuff, ipv4_nacc);
Rprintf("      %u\n", ipv4->sin_addr);
 
uint32_t nth = ntohl(ipv4->sin_addr.s_addr);
ipv4_raw_output(nth, (char*) &ipstringbuff,IP4_STRING_SZMAX);   
Rprintf("      %s\n", ipstringbuff);
#endif
 
#ifdef RNET_DBG	        
  ipvers = "IPv4";
#endif

          ipv4_ip_ptr[ipv4_nacc] = ripv4;
           
           
          ++ipv4_nacc;
          
        } else {  
           
          if( ipv6_nacc>=nipv6){
 
            int nip = (int) ceil( ((double) nipv6 )*1.6 );
 
            REPROTECT( Ripv6_ip = arraycp(Ripv6_ip, nipv6, 2, nip), Ripv6_ip_protidx);
            nipv6 = nip;
            ipv6_ip_ptr = (uint64_t *) REAL( Ripv6_ip ); 
          }
           
          struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *) resptr->ai_addr;
           
          addr = &(ipv6->sin6_addr);

#if 0  
Rprintf("IPV6: %d %d\n", ipv6_nacc, nipv6);   
char ip6stringbuff[IPv6_STRING_SZMAX];
inet_ntop(AF_INET6, addr, ip6stringbuff, INET6_ADDRSTRLEN);
Rprintf("IPv6: %s\n", ip6stringbuff);  
Rprintf("      %" PRIu64 " %" PRIu64 "\n"
  , ( (IPv6*) (&ipv6->sin6_addr) )->ipv6[0], ( (IPv6*) (&ipv6->sin6_addr) )->ipv6[1]
);
#endif
 
#ifdef RNET_DBG	        
  ipvers = "IPv6";
#endif
           
 
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
          uint64_t ip6h[2]={
            __BSWAP_64( ( (IPv6*) ( addr ) )->ipv6[0] )
            , __BSWAP_64( ( (IPv6*) ( addr ) )->ipv6[1] )
          };

#else
          uint64_t ip6h[2]={
             ( (IPv6*) ( addr ) )->ipv6[0] 
            , ( (IPv6*) ( addr ) )->ipv6[1] 
          };
#endif

          ipv6_ip_ptr[ipv6_nacc]       = ip6h[0];
          ipv6_ip_ptr[ipv6_nacc+nipv6] = ip6h[1];
           
          ++ipv6_nacc;
        }  
         
         
      }  
       
      freeaddrinfo(res);
       
      ipv4_hptr[i+1] = ipv4_nacc;
       
      ipv6_hptr[i+1] = ipv6_nacc;
     
    }  
  }  
   
   
  Rhost = PROTECT(
    NEW_OBJECT(
      PROTECT(
        MAKE_CLASS("host")
      )
    )
  );
  nprotected+=2;
   
  Ripv4 = PROTECT(
    NEW_OBJECT(
      PROTECT(
        MAKE_CLASS("IPv4")
      )
    )
  );
  nprotected+=2;
   
  Ripv6 = PROTECT(
    NEW_OBJECT(
      PROTECT(
        MAKE_CLASS("IPv6")
      )
    )
  );
  nprotected+=2;
   
  Rhost = SET_SLOT(Rhost, host_hostnameSym, duplicate( Rhostnames ) );

  if( ipv4_nacc<nipv4 ){
 
    REPROTECT( Ripv4_ip = lengthgets(Ripv4_ip, ipv4_nacc), Ripv4_ip_protidx);
  }
   
  Ripv4 = SET_SLOT(Ripv4, Rip_ipv4Sym, Ripv4_ip ); 
   
  SET_SLOT(Ripv4, Rip_lenSym, ScalarInteger( ipv4_nacc ) );
   
  Rhost = SET_SLOT(Rhost, Rip_ipv4Sym, Ripv4 );
   
  Rhost = SET_SLOT(Rhost, host_ipv4ptrSym, Ripv4_hptr );

  if( ipv6_nacc<nipv6 ){
 
    REPROTECT( Ripv6_ip = arraycp(Ripv6_ip, nipv6, 2, ipv6_nacc), Ripv6_ip_protidx);
  }
   
  Ripv6 = SET_SLOT(Ripv6, Rip_ipv6Sym, Ripv6_ip ); 
   
  SET_SLOT(Ripv6, Rip_lenSym, ScalarInteger( ipv6_nacc ) );
   
  Rhost = SET_SLOT(Rhost, Rip_ipv6Sym, Ripv6 );
   
  Rhost = SET_SLOT(Rhost, host_ipv6ptrSym, Ripv6_hptr );
   
  UNPROTECT( nprotected ); 
   
  return Rhost;
#else
  char errmsg[256];
  sprintf(errmsg, "unavailable '%s' function at line %d in file '%s'.", __func__, __LINE__, __FILE__);
   
  error("%s", errmsg);
  return R_NilValue;
#endif
}

SEXP Rip_ifaddrs_0(void){ 
  char errmsg[256];
 
#if defined (__unix__) || (defined (__APPLE__)  )
     
    struct ifaddrs * ifAddrStruct=NULL;
    struct ifaddrs * ifa=NULL;
     
    SEXP Rip=NULL,Ripv4=NULL, Ripv4_idSlot=NULL
      , Ripv6=NULL, Ripv6_idSlot=NULL;
    RIPv4_SLOTS_DCL(Ripv4)
    RIPv6_SLOTS_DCL(Ripv6)
     
    int nip=0, nprotected=0,rc=0;
    Ripv4_nipv4 = Ripv6_nipv6 = 0;
     
    RIP_BEGIN 
     
    if ( (rc = getifaddrs(&ifAddrStruct) )== -1) {
        
       error("getifaddrs %s",  strerror(rc) );
        
        
    }
     
    for (ifa = ifAddrStruct; ifa != NULL; ifa = ifa->ifa_next) {
         
        if (!ifa->ifa_addr) {
            continue;
        }
        if (ifa->ifa_addr->sa_family == AF_INET) {  
           
          Ripv4_nipv4++;
           

        } else if (ifa->ifa_addr->sa_family == AF_INET6) {  
           
          Ripv6_nipv6++;
           
        } 
    }
     
    nip = Ripv4_nipv4 + Ripv6_nipv6;
 
     
    Ripv4 = PROTECT(
      NEW_OBJECT(
        PROTECT(
          MAKE_CLASS("IPv4")
        )
      )
    );
    nprotected+=2;
     
    ___RIPv4_SLOTS_ALLOC(Ripv4, nip, Ripv4_nipv4)
     
    PROTECT( Ripv4_idSlot = allocVector(STRSXP, Ripv4_nip ) );
    nprotected++;    
     
    Ripv6 = PROTECT(
      NEW_OBJECT(
        PROTECT(
          MAKE_CLASS("IPv6")
        )
      )
    );
    nprotected+=2;
     
    ___RIPv6_SLOTS_ALLOC(Ripv6, nip, Ripv6_nipv6)
     
    PROTECT( Ripv6_idSlot = allocVector(STRSXP, Ripv6_nip ) );
    nprotected++;
     
    int i=-1;
     
    for (ifa = ifAddrStruct; ifa != NULL; ifa = ifa->ifa_next) {
         
        void *addrptr;     

        if (!ifa->ifa_addr) {
            continue;
        }
        if (ifa->ifa_addr->sa_family == AF_INET) {  
 
           
          i++;
           
          addrptr=&((struct sockaddr_in *)ifa->ifa_addr)->sin_addr;

          RIPv4_ITER_SET(Ripv4, i, ntohl( *(IPv4*) addrptr))
           
          SET_STRING_ELT( Ripv4_idSlot, i, mkChar(ifa->ifa_name));
           
          Ripv6_ip_idxptr[i] = NA_INTEGER;

        } else if (ifa->ifa_addr->sa_family == AF_INET6) {  
 
           
          i++;
           
          addrptr=&((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_addr;

#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
          uint64_t ip6h[2]={
            __BSWAP_64( ( (IPv6*) ( addrptr ) )->ipv6[0] )
            , __BSWAP_64( ( (IPv6*) ( addrptr ) )->ipv6[1] )
          };

#else
          uint64_t ip6h[2]={
             ( (IPv6*) ( addrptr ) )->ipv6[0] 
            , ( (IPv6*) ( addrptr ) )->ipv6[1] 
          };
#endif          

          RIPv6_ITER_SET(Ripv6, i, ip6h)
           
          SET_STRING_ELT( Ripv6_idSlot, i, mkChar(ifa->ifa_name));
           
          Ripv4_ip_idxptr[i] = NA_INTEGER;

        } 
    }
   
  RIPv4_SLOTS_SET(Ripv4)
  Ripv4 = SET_SLOT(Ripv4, Rip_idSym, Ripv4_idSlot );
   
  RIPv6_SLOTS_SET(Ripv6)
  Ripv6 = SET_SLOT(Ripv6, Rip_idSym, Ripv6_idSlot );
   
  Rip = PROTECT(
    NEW_OBJECT(
      PROTECT(
        MAKE_CLASS("IP")
      )
    )
  );
  nprotected+=2;
  Rip = SET_SLOT(Rip, Rip_ipv4Sym, Ripv4 );
  Rip = SET_SLOT(Rip, Rip_ipv6Sym, Ripv6 );
   
  if (ifAddrStruct!=NULL) freeifaddrs(ifAddrStruct);
   
  RIP_END 
   
  UNPROTECT( nprotected ); 
   
  return Rip;
#else
  sprintf(errmsg, "unavailable '%s' function at line %d in file '%s'.", __func__, __LINE__, __FILE__);
   
  error("%s", errmsg);
  return ScalarLogical(0);
#endif
}

#endif
