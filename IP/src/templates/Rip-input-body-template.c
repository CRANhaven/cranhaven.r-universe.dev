 
 
#if defined( ___IP_IPv4_PARSE_VALID_BODY__ )
#pragma message("___IP_IPv4_PARSE_VALID_BODY__")
       
      const __m128i vmone     = _mm_set1_epi8(-1);
      const __m128i vten      = _mm_set1_epi8(10);
      const __m128i vCharDot  = _mm_set1_epi8('.');  
      const __m128i vCharZero = _mm_set1_epi8('0');  
       
      uint ncm = (1 << nc ) -1;
       
if((dbg&1)){Rprintf("v0:\n");Rippaddr_i8x16_Rprintf_0(v0);Rprintf("\n");}
       
    __m128i vdots = _mm_cmpeq_epi8(v0, vCharDot);
 
       
      uint  mdots  = _mm_movemask_epi8( vdots ) & ncm; 
       
      uint fixed = (mdots ==( 
        ( 1 << 3 ) | ( 1 << 7 ) | ( 1 << 11 )
      )) & ( nc==15);
if((dbg&1)){Rprintf("fixed:%d\n", fixed);Rippaddr_i8x16_Rprintf_0(vdots);Rprintf("\n");}
       
      v0 = _mm_sub_epi8( v0, vCharZero);
if((dbg&1)){Rprintf("nc:%d\n", nc);Rippaddr_i8x16_Rprintf_0(v0);Rprintf("\n");}
       
      const int ge0 = _mm_movemask_epi8(
          _mm_cmpgt_epi8(v0, vmone) 
      ) | mdots ;
       
      const int le9 = _mm_movemask_epi8(
          _mm_cmplt_epi8(v0, vten)
      ) | mdots;
if((dbg&1)){Rprintf("ge0:%u le9:%u\n", ge0 & ncm, le9 & ncm);printBits_uint32(ge0 & ncm);printBits_uint32(le9 & ncm );}   
       
      uint mvalid =0;
       
      mvalid  = (nc >= 7) | (nc<=15) ;
if((dbg&1)){Rprintf("mvalid:%u\n", mvalid);}   
       
      mvalid &=  __builtin_popcount( mdots^(mdots>>1) )==6;
if((dbg&1)){Rprintf("mvalid:%u\n", mvalid);}   
       
      mvalid &= ( ( ge0 & le9 ) & ncm )==( ncm );
if((dbg&1)){Rprintf("mvalid:%u\n", mvalid);}     
       
      mvalid |= fixed << 1;

#elif defined( ___IP_IPv4_PARSE_FIXED_BODY__ )
   
  vip = _mm_maddubs_epi16(
    v0
    , _mm_setr_epi8(
        100, 10, 1, 0
      , 100, 10, 1, 0
      , 100, 10, 1, 0
      , 100, 10, 1, 0
    )
  );
if(dbg){Rprintf("vip:\n");Rippaddr_i16x8_Rprintf_0(vip);Rprintf("\n");} 
   
  vip = _mm_add_epi16(
      vip
    , _mm_shuffle_epi8(
      vip
      , _mm_setr_epi8( 
           2,  3, -1, -1 
        ,  6,  7, -1, -1
        , 10, 11, -1, -1
        , 14, 15, -1, -1
      ) 
    )
  );
if(dbg){Rprintf("vip:\n");Rippaddr_i16x8_Rprintf_0(vip);Rprintf("\n");Rippaddr_i8x16_Rprintf_0(vip);Rprintf("\n");} 
   
  gt255  = _mm_movemask_epi8( 
    _mm_cmpgt_epi16(vip, _mm_set1_epi16(255))
  );
   
  gt255 &= ( 1 | ( 1 << 5 ) | ( 1 << 9 )| ( 1 << 13 ));
#if !defined( ___IP_IPv4_PARSE1_FIXED_0_UPDATE__) || (defined( ___IP_IPv4_PARSE1_FIXED_0_UPDATE__) & (___IP_IPv4_PARSE1_FIXED_0_UPDATE__==1))  
   
  if( !gt255 ){
     
    vip = _mm_shuffle_epi8(
      vip
      , _mm_setr_epi8( 
          12,  8,  4,  0
        , -1, -1, -1, -1
        , -1, -1, -1, -1
        , -1, -1, -1, -1
      ) 
    );
if(dbg){Rprintf("vip:\n");Rippaddr_i8x16_Rprintf_0(vip);Rprintf("\n");}    
     
    Rip_ip_idx++;
    Rip_ip_ptr[ Rip_ip_idx ] = _mm_extract_epi32(vip, 0);
    Rip_ip_idxptr[i] = Rip_ip_idx;
     
     
    continue;
  }
#endif

#elif defined( ___IP_IPv4_PARSE_BODY__ )
 
#  if defined(___IP_IPv4_PARSE_LUT__) 
#    pragma message("___IP_IPv4_PARSE_LUT__")
   
  mdots |= ( 1 << nc );
if(dbg){Rprintf("mdots:\n");printBits_uint64(mdots);}
   
  n0 =  __builtin_ffs(mdots) ;
  mdots >>= n0;
   
  n1 =  __builtin_ffs(mdots) ;
  mdots >>= n1;
   
  n2 =  __builtin_ffs(mdots) ;
  mdots >>= n2;
   
  n3 = __builtin_ffs(mdots) ;
   
  n = ( n0 - 2 ) + ( n1 - 2 ) *3 + ( n2 - 2 )*9 + ( n3 - 2 )*27; 
if(dbg){Rprintf("n:%d %d %d %d %d\n", n, n0, n1, n2, n3);}
   
  vShuffle = _mm_loadu_si128( (__m128i const *) &ipv4GatherHiTbl[n*2]); 
if(dbg){Rprintf("vShuffle:\n");Rippaddr_i8x16_Rprintf_0(vShuffle);Rprintf("\n");}   

#  elif defined(___IP_IPv4_PARSE_CSUM__)  

#if 0
   
  n0 = nthset(mdots, 0);
  n1 = nthset(mdots, 1);
  n2 = nthset(mdots, 2);
  n3 = nthset(mdots, 3);
   
  vn = _mm_setr_epi32(
    _pdep(0x1, n0)
    , _pdep(n0, 0x100)
    , _pdep(n0, 0x1000)
    , n3
  );

#endif
   
  mdots |= ( 1 << nc );
   
  n0 =  __builtin_ffs(mdots);
  mdots >>= n0;
if(dbg){Rprintf("n0:%d\n", n0);}
   
  n1 =  __builtin_ffs(mdots);
  mdots >>= n1;
   
  n2 =  __builtin_ffs(mdots);
  mdots >>= n2;
   
  n3 = __builtin_ffs(mdots);
   
  vn = _mm_setr_epi32(
    n0, n1, n2, n3
  );
if(dbg){Rprintf("vn:\n");Rippaddr_i8x16_Rprintf_0(vn);Rprintf("\n");}   
   
  vn = _mm_sub_epi32(
     _mm_set1_epi32( 4 )
    , vn  
  );
if(dbg){Rprintf("vn:\n");Rippaddr_i8x16_Rprintf_0(vn);Rprintf("\n");}   
   
  vn = _mm_mullo_epi32( vn, _mm_set1_epi32(8) );
   
if(dbg){Rprintf("vn:\n");Rippaddr_i8x16_Rprintf_0(vn);Rprintf("\n");}   

  vp = _mm_sllv_epi32(
    _mm_set1_epi32(
      ( 1 << 8 ) | ( 1 << 16 ) | ( 1 << 24 )  
    )
    , vn
  );
if(dbg){Rprintf("vp:\n");Rippaddr_i8x16_Rprintf_0(vp);Rprintf("\n");}   
   
  vShuffle = Rippaddr_i8x16_csum_0(vp);
if(dbg){Rprintf("vShuffle:\n");Rippaddr_i8x16_Rprintf_0(vShuffle);Rprintf("\n");}  
   
  vShuffle = _mm_add_epi8(
    vShuffle
    , _mm_setr_epi8(
        -1, -1, -1, -1
      ,  0,  0,  0,  0
      ,  1,  1,  1,  1
      ,  2,  2,  2,  2
    )
  );
if(dbg){Rprintf("vShuffle:\n");Rippaddr_i8x16_Rprintf_0(vShuffle);Rprintf("\n");}  
   
  vShuffle = _mm_or_si128(
    _mm_cmpeq_epi8(vp, _mm_set1_epi32(0) )
    , vShuffle
  );
if(dbg){Rprintf("vShuffle:\n");Rippaddr_i8x16_Rprintf_0(vShuffle);Rprintf("\n");}   
 
#  else  
   
  n0 =  __builtin_ffs(mdots);
  mdots >>= n0;
if(dbg){Rprintf("n0:%d\n", n0);}
   
  p1 = naccum = n0;
  n1 =  __builtin_ffs(mdots);
  mdots >>= n1;
   
  p2 = naccum +=n1;
  n2 =  __builtin_ffs(mdots);
   
  p3 = naccum +=n2;
  n3 = (nc - naccum)+1;
if(dbg){Rprintf("n3:%d p3:%d\n", n3, p3);}

  n = n3 | ( n2 << 8 ) | ( n1 << 16 ) | ( n0 << 24 );
  p = p3 | ( p2 << 8 ) | ( p1 << 16 ) ;
   
  vn = _mm_set1_epi32(n);
   
  vn = _mm_shuffle_epi8(
    vn
    , _mm_setr_epi8(
         3,  3,  3,  3
      ,  2,  2,  2,  2
      ,  1,  1,  1,  1 
      ,  0,  0,  0,  0

    )
  );
if(dbg){Rprintf("vn:\n");Rippaddr_i8x16_Rprintf_0(vn);Rprintf("\n");}    
   
  vp = _mm_set1_epi32(p);
if(dbg){Rprintf("vp:\n");Rippaddr_i8x16_Rprintf_0(vp);Rprintf("\n");}  
   
  vp = _mm_shuffle_epi8(
    vp
    , _mm_setr_epi8(
         3,  3,  3,  3
      ,  2,  2,  2,  2
      ,  1,  1,  1,  1 
      ,  0,  0,  0,  0
    )
  );
if(dbg){Rprintf("vp:\n");Rippaddr_i8x16_Rprintf_0(vp);Rprintf("\n");}  
if(dbg){Rprintf("idx:\n");Rippaddr_i8x16_Rprintf_0( _mm_set1_epi32(1 | ( 2 << 8) | ( 3 << 16 ) | ( 4 << 24) ) );Rprintf("\n");}  
   
  vShuffle = _mm_sub_epi8(
     _mm_sub_epi8(vn, _mm_set1_epi8(1) )
    , _mm_set1_epi32(
      4 | ( 3 << 8) | ( 2 << 16 ) | ( 1 << 24)
       
    )
  );
if(dbg){Rprintf("vShuffle:\n");Rippaddr_i8x16_Rprintf_0(vShuffle);Rprintf("\n");}  
   
  vShuffle = _mm_blendv_epi8(
    _mm_add_epi8( 
      vShuffle
      , vp
    )
    , _mm_set1_epi8(-1)
    , _mm_cmpgt_epi8( 
         _mm_set1_epi8(0), vShuffle
      )
  );
if(dbg){Rprintf("vShuffle:\n");Rippaddr_i8x16_Rprintf_0(vShuffle);Rprintf("\n");}  

#  endif  

   
  vip = _mm_shuffle_epi8(
    v0
    , vShuffle
  );
if(dbg){Rprintf("vip:\n");Rippaddr_i8x16_Rprintf_0(vip);Rprintf("\n");} 
   
  vip = _mm_maddubs_epi16(
    vip
    , _mm_setr_epi8(
        0, 100, 10, 1
      , 0, 100, 10, 1
      , 0, 100, 10, 1
      , 0, 100, 10, 1
    )
  );
if(dbg){Rprintf("vip:\n");Rippaddr_i16x8_Rprintf_0(vip);Rprintf("\n");} 
   
  vip = _mm_add_epi16(
      vip
    , _mm_shuffle_epi8(
      vip
      , _mm_setr_epi8( 
           2,  3, -1, -1 
        ,  6,  7, -1, -1
        , 10, 11, -1, -1
        , 14, 15, -1, -1
      ) 
    )
  );
if(dbg){Rprintf("vip:\n");Rippaddr_i16x8_Rprintf_0(vip);Rprintf("\n");Rippaddr_i8x16_Rprintf_0(vip);Rprintf("\n");} 

  gt255  = _mm_movemask_epi8( 
    _mm_cmpgt_epi16(vip, _mm_set1_epi16(255))
  );
if(dbg){Rprintf("gt255:\n");printBits_uint64(gt255);}

  if( !gt255 ){
     
    vip = _mm_shuffle_epi8(
      vip
      , _mm_setr_epi8( 
          12,  8,  4,  0
            
        , -1, -1, -1, -1
        , -1, -1, -1, -1
        , -1, -1, -1, -1
      ) 
    );
if(dbg){Rprintf("vip:\n");Rippaddr_i8x16_Rprintf_0(vip);Rprintf("\n");}    
     
    Rip_ip_idx++;
    Rip_ip_ptr[ Rip_ip_idx ] = _mm_extract_epi32(vip, 0);
    Rip_ip_idxptr[i] = Rip_ip_idx;
     
     
#   if defined( ___IP_IPv4_PARSE_BODY_CONTINUE_ )
    continue;
#   endif
  }

#else
  pragma error("missing input body")
#endif
 
