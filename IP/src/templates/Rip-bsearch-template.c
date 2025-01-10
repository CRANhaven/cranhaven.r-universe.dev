

#if defined( ___IP_BSEARCH_BODY_MATCH__ )

  int mid = lo + ( hi - lo )/2; 
   
  RIPv4r_ELT_PTR_DCL(RipTbl, mid ) 
   
  if( 
    ___IP_SCALAR_IN(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr ) 
  ){ 
    resptr[i] = idx_ptr[mid]; 
 
#if defined(___IP_AVX2_CTXT__)
    lo=hi+1;  
#endif
 
#if defined(___IP_BSEARCH_MATCH_CONTINUE__)
    continue;
#else 
    break; 
#endif
  } 
  if( 
    ___IP_SCALAR_GT(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr) 
  ){ 
    lo = mid+1; 
  }else{ 
    hi = mid-1; 
  } 

#elif defined( ___IP_BSEARCH_BODY_SSE2_MATCH__ )

  __m256 v4n = _mm_set1_ps( (float) n );
   
  __m256i v4qidx = _mm256_cvttps_epi32(
      _mm256_div_ps(_mm256_mul_ps( (v4n), (v4seq)), (v4nqtllm1) )
    );
#if __DBG
Ripaddr_mm256i_i32_Rprintf_0(qidx);Rprintf("\n");
#endif
        
     
    v4qidx = _mm_add_epi32( v4lo, v4qidx);
    
 
#if defined( ___IP_BSEARCH_BODY_AVX2x2_MATCH__ )
    qidxHi = _mm_add_epi32( vlo, qidxHi);
#endif  

    __m256i v4idx = v4qidx;
 
     
    __m256i tbl_vlo = _mm_i32gather_epi32( 
      (int const *)  RipTbl_ip_lo_ptr
      , v4idx
      , 4 
    );
    __m256i tbl_vhi = _mm_i32gather_epi32( 
      (int const *)  RipTbl_ip_hi_ptr
      , v4idx
      , 4 
    );
#if __DBG
Rippaddr_ipv4rx8_Rprintf_0(tbl_vlo, tbl_vhi);Rprintf("\n");
#endif

     
    __mmask8 gt   = _mm256_u32x8_cmp_gt_mask( ip_vip, tbl_vlo );
     
    __mmask8 lt   = _mm256_u32x8_cmp_lt_mask( ip_vip, tbl_vhi );
     
    __mmask8 eqLo = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vlo );
     
    __mmask8 eqHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vhi );
 
     
    __mmask8 ge = gt | eqLo;
    __mmask8 le = lt | eqHi;
#if __DBG
 Rprintf("ge: %d le: %d\n", ge, le);
#endif

   
  if( ( ge==0 ) || ( le==0 ) ) break;
   
  __mmask8 eq = eqLo | eqHi;

   
  if( !eq ){ 
     
    int lo0= lo;
     
     
    lo  += ( ( n * ( 31 - __builtin_clz( ge ) ) ) / nqtllm1 )  ;  
     
    vlo  = _mm_set1_epi32( 
      lo
    );
     
    hi = ( lo0 +  ( n * (  __builtin_ctz( le ) ) ) / nqtllm1 ) ;  

  }else{
#if __DBG
  Rprintf("m\n");
#endif

    int midx = lo + ( n * ( __builtin_ffs( eqLo>0 ? eqLo : eqHi ) - 1 ) / nqtllm1 );

#if __DBG
  Rprintf("midx:%d %d\n", midx, vidx[__builtin_ffs( eqLo>0 ? eqLo : eqHi ) - 1] );
#endif
    resptr[i] = idx_ptr[midx];
     
    lo=hi+1;
    break;
  }  

#elif defined( ___IP_BSEARCH_BODY_AVX2_MATCH__ )

#if defined( ___IP_BSEARCH_BODY_AVX2x2_MATCH__ )
  const nqtllm1 = 15;
#else
  const nqtllm1 = 7;
#endif  
  
   
  __m256 vn = _mm256_set1_ps( (float) n );
   
  __m256i qidx = _mm256_cvttps_epi32(
      _mm256_div_ps(_mm256_mul_ps( (vn), (vseq)), (vfifteen) )
    );
#if __DBG
Ripaddr_mm256i_i32_Rprintf_0(qidx);Rprintf("\n");
#endif

 
#if defined( ___IP_BSEARCH_BODY_AVX2x2_MATCH__ )
  __m256i qidxHi = _mm256_cvttps_epi32(
      _mm256_div_ps(_mm256_mul_ps( (vn), (vseqHi)), (vfifteen) )
  );
#if __DBG
Ripaddr_mm256i_i32_Rprintf_0(qidxHi);Rprintf("\n");
#endif

#endif  
        
     
    qidx = _mm256_add_epi32( vlo, qidx);
    
 
#if defined( ___IP_BSEARCH_BODY_AVX2x2_MATCH__ )
    qidxHi = _mm256_add_epi32( vlo, qidxHi);
#endif  

    __m256i vidx = qidx;
 
     
    __m256i tbl_vlo = _mm256_i32gather_epi32( 
      (int const *)  RipTbl_ip_lo_ptr
      , vidx
      , 4 
    );
    __m256i tbl_vhi = _mm256_i32gather_epi32( 
      (int const *)  RipTbl_ip_hi_ptr
      , vidx
      , 4 
    );
#if __DBG
Rippaddr_ipv4rx8_Rprintf_0(tbl_vlo, tbl_vhi);Rprintf("\n");
#endif

 
#if defined( ___IP_BSEARCH_BODY_AVX2x2_MATCH__ )

    __m256i vidxHi = qidxHi;
   
     
    __m256i tbl_vloHi = _mm256_i32gather_epi32( 
      (int const *)  RipTbl_ip_lo_ptr
      , vidxHi
      , 4 
    );
    __m256i tbl_vhiHi = _mm256_i32gather_epi32( 
      (int const *)  RipTbl_ip_hi_ptr
      , vidxHi
      , 4 
    );
#if __DBG
 Rippaddr_ipv4rx8_Rprintf_0(tbl_vloHi, tbl_vhiHi);Rprintf("\n");
#endif

#endif  

     
    __mmask8 gt   = _mm256_u32x8_cmp_gt_mask( ip_vip, tbl_vlo );
     
    __mmask8 lt   = _mm256_u32x8_cmp_lt_mask( ip_vip, tbl_vhi );
     
    __mmask8 eqLo = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vlo );
     
    __mmask8 eqHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vhi );
    
 
#if defined( ___IP_BSEARCH_BODY_AVX2x2_MATCH__ )
     
    __mmask8 gtHi   = _mm256_u32x8_cmp_gt_mask( ip_vip, tbl_vloHi );
     
    __mmask8 ltHi   = _mm256_u32x8_cmp_lt_mask( ip_vip, tbl_vhiHi );
     
    __mmask8 eqLoHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vloHi );
     
    __mmask8 eqHiHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vhiHi );
    
     
    gt |= gtHi >> 8 ;
    lt |= ltHi >> 8 ;
    eqLo |= eqLoHi >> 8 ;
    eqHi |= eqHiHi >> 8 ;
    
#endif  
    
     
    __mmask8 ge = gt | eqLo;
    __mmask8 le = lt | eqHi;
#if __DBG
 Rprintf("ge: %d le: %d\n", ge, le);
#endif

   
  if( ( ge==0 ) || ( le==0 ) ) break;
   
  __mmask8 eq = eqLo | eqHi;

   
  if( !eq ){ 
     
    int lo0= lo;
     
     
    lo  += ( ( n * ( 31 - __builtin_clz( ge ) ) ) / nqtllm1 )  ;  
     
    vlo  = _mm256_set1_epi32( 
      lo
    );
     
    hi = ( lo0 +  ( n * (  __builtin_ctz( le ) ) ) / nqtllm1 ) ;  

  }else{
#if __DBG
  Rprintf("m\n");
#endif

    int midx = lo + ( n * ( __builtin_ffs( eqLo>0 ? eqLo : eqHi ) - 1 ) / nqtllm1 );

#if __DBG
  Rprintf("midx:%d %d\n", midx, vidx[__builtin_ffs( eqLo>0 ? eqLo : eqHi ) - 1] );
#endif
    resptr[i] = idx_ptr[midx];
     
    lo=hi+1;
    break;
  }  
 
 
#elif defined( ___IP_BSEARCH_BODY__ )
 
   
  SEXP Res; 
  int nprotected=0; 
   
  ___IP_VAL_SLOTS_GET( Rip ) 
   
  ___IP_TBL_SLOTS_GET( RipTbl ) 
  RipTbl_nip+=0;
   
  int  idx_nip  =  LENGTH(Ridx); 
  int *idx_ptr  =  INTEGER(Ridx); 
  int  nomatch  = *INTEGER(Romatch); 
   
  PROTECT( Res = allocVector(INTSXP, Rip_nip ) ); 
  nprotected++; 
  int *resptr  = INTEGER( Res ); 
   
  for( int i=0 ; i<Rip_nip; i++ ){ 
 
     
    resptr[i]= nomatch;
     
    if( (Rip_ip_idxptr[i]!=NA_INTEGER) ){
      ___IP_VAL_ELT_PTR_DCL( Rip, i)
       
      int lo  = 0, hi  = idx_nip-1; 
       
      while ( lo <= hi ){ 
         
        #define ___IP_BSEARCH_BODY_MATCH__
        #include "Rip-bsearch-template.c"
        #undef ___IP_BSEARCH_BODY_MATCH__
      }  
    }
  }  
  RIP_END 
  resptr = INTEGER( Res ); 
  RIP_Rvec_IDSLOT_CP(Res, Rip ) 
  UNPROTECT(nprotected); 
  return Res; 

#elif defined( ___IP_BSEARCH_AVX2_BODY__ )
 

  SEXP Res; 
  int nprotected=0; 
   
  ___IP_VAL_SLOTS_GET( Rip ) 
   
  ___IP_TBL_SLOTS_GET( RipTbl ) 
  RipTbl_nip+=0;
   
  int  idx_nip  =  LENGTH(Ridx); 
  int *idx_ptr  =  INTEGER(Ridx); 
  int  nomatch  = *INTEGER(Romatch); 
   
  PROTECT( Res = allocVector(INTSXP, Rip_nip ) ); 
  nprotected++; 
  int *resptr  = INTEGER( Res ); 
   
  for( int i=0 ; i<Rip_nip; i++ ){ 
 
     
    resptr[i]= nomatch;
     
    if( (Rip_ip_idxptr[i]!=NA_INTEGER) ){
      ___IP_VAL_ELT_PTR_DCL( Rip, i)
#if __DBG
RIP_ipv4_Rprintf_0(Rip_ip_elt_ptr);Rprintf("\n");
#endif

      __m256i ip_vip = _mm256_set1_epi32( Rip_ip_elt_ptr );
       
      int lo  = 0, hi  = idx_nip-1, n=-1; 
 
 
#if 1 
      {
        #define ___IP_BSEARCH_MATCH_CONTINUE__
        #define ___IP_BSEARCH_BODY_MATCH__
        #include "Rip-bsearch-template.c"
        #undef ___IP_BSEARCH_BODY_MATCH__  
        #undef ___IP_BSEARCH_MATCH_CONTINUE__     
      }
#if 1
      if( lo <= hi ){
        #define ___IP_BSEARCH_MATCH_CONTINUE__
        #define ___IP_BSEARCH_BODY_MATCH__
        #include "Rip-bsearch-template.c"
        #undef ___IP_BSEARCH_BODY_MATCH__  
        #undef ___IP_BSEARCH_MATCH_CONTINUE__    
      }
#endif

#elif 1
      {
        int mid = lo + ( hi - lo )/2; 
         
        RIPv4r_ELT_PTR_DCL(RipTbl, mid )
        if( 
          Rippaddr_ipv4_in_ipv4r(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr ) 
        ){ 
          resptr[i] = idx_ptr[mid]; 
          continue; 
        } 
        if( 
          Ripaddr_bsearch_ipv4_cmp_gt(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr) 
        ){ 
          lo = mid+1; 
        }else{ 
          hi = mid-1; 
        } 
      } 
#if 1
       
      if( lo <= hi ){
 
        int mid = lo + ( hi - lo )/2; 
         
        RIPv4r_ELT_PTR_DCL(RipTbl, mid )
        if( 
          Rippaddr_ipv4_in_ipv4r(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr ) 
        ){ 
          resptr[i] = idx_ptr[mid]; 
          continue; 
        } 
        if( 
          Ripaddr_bsearch_ipv4_cmp_gt(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr) 
        ){ 
          lo = mid+1; 
        }else{ 
          hi = mid-1; 
        } 
      }else continue;
#endif

#elif 0

       
      while ( ( hi - lo)>6 ){
         
        int mid = lo + ( hi - lo )/2; 
#if __DBG
Rprintf("  %d %d %d %d\n", lo, hi, mid, idx_ptr[mid]);     
#endif
        RIPv4r_ELT_PTR_DCL(RipTbl, idx_ptr[mid] )   
         
        if( 
          Rippaddr_ipv4_in_ipv4r(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr ) 
        ){ 
          resptr[i] = idx_ptr[mid]; 
           
          break; 
        } 
        if( 
          Ripaddr_bsearch_ipv4_cmp_gt(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr) 
        ){ 
          lo = mid+1; 
        }else{ 
          hi = mid-1; 
        } 
      } 
    
#endif

      const __m256 vseven  = _mm256_set1_ps( 7. );
      const __m256 vseq  = _mm256_set_ps( 7., 6., 5., 4., 3., 2., 1., 0. );
       
      __m256i vlo = _mm256_set1_epi32( lo );
 
#if 0
      const __m256i voneI32  = _mm256_set1_epi32( 1 );
      const __m256 vfifteen  = _mm256_set1_ps( 15. );
      const __m256 vseqHi  = _mm256_set_ps( 15., 14., 13., 12., 11., 10., 9., 8. );
       
      while( 
        (n = hi - lo) >= 15 
      ){
        
#if __DBG
Rprintf("lo-hi#AVXx2:%d %d\n", lo, hi);
#endif

#if 0
         
        int mid = ( n + 1 ) / 2;
         
        __m256 vnLo = _mm256_set1_ps( (float) mid );
        __m256 vnHi = _mm256_set1_ps( (float) ( n - ( mid + 1 ) ) );
        
         
        __m256i qidx = _mm256_cvttps_epi32(
            _mm256_div_ps(_mm256_mul_ps( (vnLo), (vseq)), (vseven) )
          );
        __m256i qidxHi = _mm256_cvttps_epi32(
            _mm256_div_ps(_mm256_mul_ps( (vnHi), (vseq)), (vseven) )
        );

        qidx = _mm256_add_epi32( vlo, qidx);
#if __DBG
Ripaddr_mm256i_i32_Rprintf_0(qidx);Rprintf("\n");
#endif
         
        qidxHi = _mm256_add_epi32( 
            _mm256_add_epi32( vlo, voneI32 )
          , _mm256_add_epi32( _mm256_cvttps_epi32(vnLo), qidxHi )
        );
#if __DBG
Ripaddr_mm256i_i32_Rprintf_0(qidxHi);Rprintf("\n");
#endif

#else  
        __m256 vn = _mm256_set1_ps( (float) n );
         
        __m256i qidx = _mm256_cvttps_epi32(
            _mm256_div_ps(_mm256_mul_ps( (vn), (vseq)), (vfifteen) )
          );
        __m256i qidxHi = _mm256_cvttps_epi32(
            _mm256_div_ps(_mm256_mul_ps( (vn), (vseqHi)), (vfifteen) )
        );
#if __DBG
Ripaddr_mm256i_i32_Rprintf_0(qidx);Rprintf("\n");
Ripaddr_mm256i_i32_Rprintf_0(qidxHi);Rprintf("\n");
#endif
        
         
        qidx = _mm256_add_epi32( vlo, qidx);
        qidxHi = _mm256_add_epi32( vlo, qidxHi);
#endif

         
        __m256i vidx = _mm256_i32gather_epi32( (int const *)  idx_ptr, qidx, 4 );

        __m256i tbl_vlo = _mm256_i32gather_epi32( 
          (int const *)  RipTbl_ip_lo_ptr
          , vidx
          , 4 
        );
        __m256i tbl_vhi = _mm256_i32gather_epi32( 
          (int const *)  RipTbl_ip_hi_ptr
          , vidx
          , 4 
        );
#if __DBG
Rippaddr_ipv4rx8_Rprintf_0(tbl_vlo, tbl_vhi);Rprintf("\n");
#endif

         
        __m256i vidxHi = _mm256_i32gather_epi32( (int const *)  idx_ptr, qidxHi, 4 );

        __m256i tbl_vloHi = _mm256_i32gather_epi32( 
          (int const *)  RipTbl_ip_lo_ptr
          , vidxHi
          , 4 
        );
        __m256i tbl_vhiHi = _mm256_i32gather_epi32( 
          (int const *)  RipTbl_ip_hi_ptr
          , vidxHi
          , 4 
        );
#if __DBG
Rippaddr_ipv4rx8_Rprintf_0(tbl_vloHi, tbl_vhiHi);Rprintf("\n");
#endif

         
        __mmask8 gt   = _mm256_u32x8_cmp_gt_mask( ip_vip, tbl_vlo );
         
        __mmask8 lt   = _mm256_u32x8_cmp_lt_mask( ip_vip, tbl_vhi );
         
        __mmask8 eqLo = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vlo );
         
        __mmask8 eqHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vhi );
         
         
        __mmask8 gtHi   = _mm256_u32x8_cmp_gt_mask( ip_vip, tbl_vloHi );
         
        __mmask8 ltHi   = _mm256_u32x8_cmp_lt_mask( ip_vip, tbl_vhiHi );
         
        __mmask8 eqLoHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vloHi );
         
        __mmask8 eqHiHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vhiHi );
        
         
        gt |= gtHi >> 8 ;
        lt |= ltHi >> 8 ;
        eqLo |= eqLoHi >> 8 ;
        eqHi |= eqHiHi >> 8 ;
        
         
        __mmask8 ge = gt | eqLo;
        __mmask8 le = lt | eqHi;
#if __DBG
Rprintf("ge: %d le: %d\n", ge, le);
#endif

         
        if( ( ge==0 ) || ( le==0 ) ) break;
         
        __mmask8 eq = eqLo | eqHi;
        
           
          if( !eq ){ 
             
            int lo0= lo;
             
             
            lo  += ( ( n * ( 31 - __builtin_clz( ge ) ) ) / 15 )  ;  
             
            vlo  = _mm256_set1_epi32( 
              lo
            );
             
            hi = ( lo0 +  ( n * (  __builtin_ctz( le ) ) ) / 15 ) ;  

          }else{
#if __DBG
Rprintf("m\n");
#endif

            int midx = lo + ( n * ( __builtin_ffs( eqLo>0 ? eqLo : eqHi ) - 1 ) / 15 );

#if __DBG
Rprintf("midx:%d %d\n", midx, vidx[__builtin_ffs( eqLo>0 ? eqLo : eqHi ) - 1] );
#endif
            resptr[i] = idx_ptr[midx];
             
            lo=hi+1;
            break;
          }
        {
          int mid = lo + ( hi - lo )/2; 
           
          RIPv4r_ELT_PTR_DCL(RipTbl, mid ) 
          if( 
            Rippaddr_ipv4_in_ipv4r(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr ) 
          ){ 
            resptr[i] = idx_ptr[mid]; 
            lo=hi+1;
            break; 
          } 
          if( 
            Ripaddr_bsearch_ipv4_cmp_gt(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr) 
          ){ 
            lo = mid+1; 
          }else{ 
            hi = mid-1; 
          } 
          vlo  = _mm256_set1_epi32(lo);
        } 
 
      }
      
       
      if( 
        (n = hi - lo) >= 7 
      ){
#else
       
      while( 
#if __AVX2_STEP      
        (n = hi - lo) >=  4096 * __AVX2_STEP 
#else
        (n = hi - lo) >= 7  
#endif
      ){
#endif

#if __DBG
Rprintf("\nlo-hi#AVX#0:%d %d %d\n", lo, hi, n);
#endif

        __m256 vn = _mm256_set1_ps( (float) n );

          __m256i qidx = _mm256_cvttps_epi32(
               
              _mm256_div_ps(_mm256_mul_ps( (vn), (vseq)), (vseven) )
            );
           
          qidx = _mm256_add_epi32( vlo, qidx);

          __m256i vidx = qidx;
 
           
          __m256i tbl_vlo = _mm256_i32gather_epi32( 
            (int const *)  RipTbl_ip_lo_ptr
            , vidx
            , 4 
          );
          __m256i tbl_vhi = _mm256_i32gather_epi32( 
            (int const *)  RipTbl_ip_hi_ptr
            , vidx
            , 4 
          );

          __mmask8 gt = _mm256_u32x8_cmp_gt_mask( ip_vip, tbl_vlo );
           
          __mmask8 lt = _mm256_u32x8_cmp_lt_mask( ip_vip, tbl_vhi );
           
          __mmask8 eqLo = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vlo );
           
          __mmask8 eqHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vhi );
           
          __mmask8 ge = gt | eqLo;
          __mmask8 le = lt | eqHi;
           
          if( ( ge==0 ) || ( le==0 ) ) break;
           
           
          __mmask8 eq = eqLo | eqHi;

          if( !eq ){ 
             
            int lo0= lo;

            lo  += ( ( n * ( 31 - __builtin_clz( ge ) ) ) / 7 ) ;  
             
            vlo  = _mm256_set1_epi32( 
              lo
            );

            hi = ( lo0 +  ( n * (  __builtin_ctz( le ) ) ) / 7 ) ;  

          }else{
#if __DBG
Rprintf("m\n");
#endif

            int midx = lo + ( n * ( __builtin_ffs( eqLo>0 ? eqLo : eqHi ) - 1 ) / 7 );

            resptr[i] = idx_ptr[midx];
             
            lo=hi+1;
             
            break;
             
          }
#if 0
          {
            #define ___IP_AVX2_CTXT__
            #define ___IP_BSEARCH_BODY_MATCH__
            #include "Rip-bsearch-template.c"
            #undef ___IP_BSEARCH_BODY_MATCH__  
            #undef ___IP_AVX2_CTXT__     
          }
#elif 0        
        {
          int mid = lo + ( hi - lo )/2; 
            
          RIPv4r_ELT_PTR_DCL(RipTbl, mid ) 
          if( 
            Rippaddr_ipv4_in_ipv4r(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr ) 
          ){ 
            resptr[i] = idx_ptr[mid]; 
              lo=hi+1;
            break; 
          } 
          if( 
            Ripaddr_bsearch_ipv4_cmp_gt(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr) 
          ){ 
            lo = mid+1; 
          }else{ 
            hi = mid-1; 
          } 
          vlo  = _mm256_set1_epi32(lo);
        } 
#endif

      }  

 
#if __AVX2_STEP
       
      const __m256 vfifteen  = _mm256_set1_ps( 15. );
      const __m256 vseqHi  = _mm256_set_ps( 15., 14., 13., 12., 11., 10., 9., 8. );
       
      while( 
        (n = hi - lo) >= 15 
      ){
#if __DBG
Rprintf("lo-hi#AVXx2:%d %d\n", lo, hi);
#endif

        __m256 vn = _mm256_set1_ps( (float) n );
         
        __m256i qidx = _mm256_cvttps_epi32(
            _mm256_div_ps(_mm256_mul_ps( (vn), (vseq)), (vfifteen) )
          );
        __m256i qidxHi = _mm256_cvttps_epi32(
            _mm256_div_ps(_mm256_mul_ps( (vn), (vseqHi)), (vfifteen) )
        );
#if __DBG
Ripaddr_mm256i_i32_Rprintf_0(qidx);Rprintf("\n");
Ripaddr_mm256i_i32_Rprintf_0(qidxHi);Rprintf("\n");
#endif
        
         
        qidx = _mm256_add_epi32( vlo, qidx);
        qidxHi = _mm256_add_epi32( vlo, qidxHi);

        __m256i vidx = qidx;
 
         
        __m256i tbl_vlo = _mm256_i32gather_epi32( 
          (int const *)  RipTbl_ip_lo_ptr
          , vidx
          , 4 
        );
        __m256i tbl_vhi = _mm256_i32gather_epi32( 
          (int const *)  RipTbl_ip_hi_ptr
          , vidx
          , 4 
        );
#if __DBG
Rippaddr_ipv4rx8_Rprintf_0(tbl_vlo, tbl_vhi);Rprintf("\n");
#endif

        __m256i vidxHi = qidxHi;
 
         
        __m256i tbl_vloHi = _mm256_i32gather_epi32( 
          (int const *)  RipTbl_ip_lo_ptr
          , vidxHi
          , 4 
        );
        __m256i tbl_vhiHi = _mm256_i32gather_epi32( 
          (int const *)  RipTbl_ip_hi_ptr
          , vidxHi
          , 4 
        );
#if __DBG
Rippaddr_ipv4rx8_Rprintf_0(tbl_vloHi, tbl_vhiHi);Rprintf("\n");
#endif

         
        __mmask8 gt   = _mm256_u32x8_cmp_gt_mask( ip_vip, tbl_vlo );
         
        __mmask8 lt   = _mm256_u32x8_cmp_lt_mask( ip_vip, tbl_vhi );
         
        __mmask8 eqLo = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vlo );
         
        __mmask8 eqHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vhi );
         
         
        __mmask8 gtHi   = _mm256_u32x8_cmp_gt_mask( ip_vip, tbl_vloHi );
         
        __mmask8 ltHi   = _mm256_u32x8_cmp_lt_mask( ip_vip, tbl_vhiHi );
         
        __mmask8 eqLoHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vloHi );
         
        __mmask8 eqHiHi = _mm256_i32x8_cmp_eq_mask( ip_vip, tbl_vhiHi );
        
         
        gt |= gtHi >> 8 ;
        lt |= ltHi >> 8 ;
        eqLo |= eqLoHi >> 8 ;
        eqHi |= eqHiHi >> 8 ;
        
         
        __mmask8 ge = gt | eqLo;
        __mmask8 le = lt | eqHi;
#if __DBG
Rprintf("ge: %d le: %d\n", ge, le);
#endif

         
        if( ( ge==0 ) || ( le==0 ) ) break;
         
        __mmask8 eq = eqLo | eqHi;
        
           
          if( !eq ){ 
             
            int lo0= lo;
             
             
            lo  += ( ( n * ( 31 - __builtin_clz( ge ) ) ) / 15 )  ;  
             
            vlo  = _mm256_set1_epi32( 
              lo
            );
             
            hi = ( lo0 +  ( n * (  __builtin_ctz( le ) ) ) / 15 ) ;  

          }else{
#if __DBG
Rprintf("m\n");
#endif

            int midx = lo + ( n * ( __builtin_ffs( eqLo>0 ? eqLo : eqHi ) - 1 ) / 15 );

#if __DBG
Rprintf("midx:%d %d\n", midx, vidx[__builtin_ffs( eqLo>0 ? eqLo : eqHi ) - 1] );
#endif
            resptr[i] = idx_ptr[midx];
             
            lo=hi+1;
            break;
          }
#if 0         
        {
          int mid = lo + ( hi - lo )/2; 
            
          RIPv4r_ELT_PTR_DCL(RipTbl, mid ) 
          if( 
            Rippaddr_ipv4_in_ipv4r(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr ) 
          ){ 
            resptr[i] = idx_ptr[mid]; 
              lo=hi+1;
            break; 
          } 
          if( 
            Ripaddr_bsearch_ipv4_cmp_gt(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr) 
          ){ 
            lo = mid+1; 
          }else{ 
            hi = mid-1; 
          } 
          vlo  = _mm256_set1_epi32(lo);
        } 
#endif

 
      }
#endif  
      
       
      while ( lo <= hi ){
#if __DBG
Rprintf("last ");     
#endif
 
#if 1 
          {
            #define ___IP_BSEARCH_BODY_MATCH__
            #include "Rip-bsearch-template.c"
            #undef ___IP_BSEARCH_BODY_MATCH__      
          }
#elif 0  
 
        int mid = lo + ( hi - lo )/2; 
#if __DBG
#endif
Rprintf("  %d %d %d %d\n", lo, hi, mid, idx_ptr[mid]);     
         
        RIPv4r_ELT_PTR_DCL(RipTbl, mid )
    
        if( 
          Rippaddr_ipv4_in_ipv4r(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr ) 
        ){ 
   
          resptr[i] = idx_ptr[mid]; 
           
          break; 
        } 
   
          
        if( 
          Ripaddr_bsearch_ipv4_cmp_gt(Rip_ip_elt_ptr, RipTbl_ip_elt_ptr) 
        ){ 
          lo = mid+1; 
        }else{ 
          hi = mid-1; 
        } 
#endif
      } 
    }

  } 
   
  resptr = INTEGER( Res ); 
  RIP_Rvec_IDSLOT_CP(Res, Rip ) 
  UNPROTECT(nprotected); 
  return Res; 

#elif defined( ___IP_BSEARCH_INTV_STRUCT_BODY__ )
 

    int   nip;
    ___IP_IP_CTYP__ *tbl_loPtr;
    ___IP_IP_CTYP__ *tbl_hiPtr;
    int  *ip_idxPtr;
    int  *minmx_ptr;
     
    int   nmatch;
    int  *nmatch_acc;  
    int  *match_ptr;
     
#ifdef BSEARCH_INTV_DBG
#endif
     
    int   depth;

#elif defined( ___IP_BSEARCH_INTV_INDEX_VISIT_BODY__ )

#ifdef BSEARCH_INTV_DBG
 
#endif

  ___IP_IP_CTYP__ 
     *tbl_loPtr, *tbl_hiPtr
  ;
#if ___IP_VERSION_NUM__==61
  int tbl_loPtr_ip_len = tree->nip;  
  int tbl_hiPtr_ip_len = tree->nip;  
#endif
  ___IP_IP_TYP__ 
      cmin, cmx
    , lmx , rmx
    , nmin, nmx
     
  ;
   
  int  *ip_idxPtr;
   
  int mid, lo1, hi1
    , lipIntv_idx[2]={-1,-1}, ripIntv_idx[2]={-1,-1}
  ;

  tbl_loPtr = tree->tbl_loPtr;
  tbl_hiPtr = tree->tbl_hiPtr;
  ip_idxPtr = tree->ip_idxPtr;
   
  mid = lo + ( hi - lo )/2;

#ifdef BSEARCH_INTV_DBG
#endif

  if( (hi1 = mid -1 )>lo ){
#ifdef BSEARCH_INTV_DBG 
#endif
 
     
    ___IP_INDEX_VISIT_FN__(tree, lo   
      , mid -1  
      , lipIntv_idx
    );
    
 
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
#endif
 
     
    ___IP_INDEX_VISIT_FN__(tree
      , mid+1  
      , hi   , ripIntv_idx);

 
  }else{
#ifdef BSEARCH_INTV_DBG
#endif
 
     
    ripIntv_idx[0] = hi ;
    ripIntv_idx[1] = hi ;
     
    if( hi==lo1 ){
      tree->minmx_ptr[ hi  ]            = ripIntv_idx[0];
      tree->minmx_ptr[ hi + tree->nip ] = ripIntv_idx[1];
       
    }
     
  }
#ifdef BSEARCH_INTV_DBG
#endif

  ipIntv_idx[0] = lipIntv_idx[0];

  ___IP_GET__( lmx, tbl_hiPtr, lipIntv_idx[1]  );  
  ___IP_GET__( rmx, tbl_hiPtr, ripIntv_idx[1]  );  
  
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s ", tree->depth*2, "");RIP_ipv4_Rprintf_0(lmx);Rprintf("\n%*s ", tree->depth*2, "");RIP_ipv4_Rprintf_0(rmx);Rprintf("\n");  
#endif

   
  if(  
    ___IP_GT__( lmx , rmx )
  ){
#ifdef BSEARCH_INTV_DBG  
#endif

    ipIntv_idx[1] = lipIntv_idx[1];
    cmx = lmx;
  }
  else{

    ipIntv_idx[1] = ripIntv_idx[1];
    cmx = rmx;
  }

  ___IP_GET__( cmin, tbl_loPtr, ipIntv_idx[0] );  

  ___IP_GET__( nmin, tbl_loPtr, mid  );  
  ___IP_GET__( nmx,  tbl_hiPtr, mid  );  
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s ", tree->depth, "");RIP_ipv4_Rprintf_0(cmx);Rprintf("\n%*s ", tree->depth, "");RIP_ipv4_Rprintf_0(nmx);Rprintf("\n");
#endif

  if(  
    ___IP_GT__( cmin , nmin )
  ){
 
    ipIntv_idx[0] = mid;
  }
  if(  
    ___IP_LT__( cmx , nmx )
  ){

    ipIntv_idx[1] = mid;
  }
  
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s mx: %d \n", tree->depth*2, "", ipIntv_idx[1] );
Rprintf("%*s ", tree->depth*2, "");RIP_ipv4_Rprintf_0(tbl_ip_hi_ptr[ tbl_ip_idxptr[ ipIntv_idx[1] ]]);Rprintf("\n");
#endif

   
  tree->minmx_ptr[ mid  ]            = ipIntv_idx[0];
  tree->minmx_ptr[ mid + tree->nip ] = ipIntv_idx[1];

#ifdef BSEARCH_INTV_DBG
Rprintf("%*s exit %d (%d %d)\n", tree->depth*2, "", mid, lo, hi);
#endif

  return ;

#elif defined( ___IP_BSEARCH_INTV_INDEX_BODY__ )

  SEXP Rminmx;
  ___IP_INTVTREE_CTYP__ tree;
  int  *idx_ptr , *minmx_ptr, ipIntv_idx[2]={-1,-1}; 
  int  nprotected=0; 
   
  ___IP_IPr_SLOTS_GET( RipTbl ) 
   
  idx_ptr    = INTEGER(Ridx); 
   
  PROTECT( Rminmx = allocMatrix(INTSXP, RipTbl_nip, 2 ) ); 
  nprotected++; 
  minmx_ptr  = INTEGER(Rminmx); 
   
  tree.nip       = RipTbl_nip;
  tree.tbl_loPtr = RipTbl_ip_lo_ptr;
  tree.tbl_hiPtr = RipTbl_ip_hi_ptr;
  tree.ip_idxPtr = idx_ptr;
  tree.minmx_ptr = minmx_ptr;
  RipTbl_ip_idxptr+=0;  
#ifdef BSEARCH_INTV_DBG
Rprintf("nip:%d %d %p\n", RipTbl_nip, tree.nip, &tree);
#endif  
tree.depth=-1;
   
  ___IP_INDEX_VISIT_FN__(
      &tree, 
     0, RipTbl_nip-1
    , ipIntv_idx
  );
   
  UNPROTECT(nprotected);
   
  return Rminmx;

#elif defined( ___IP_BSEARCH_INTV_MATCH_VISIT_BODY__ )
 

#pragma message("VISIT BODY")

   
  ___IP_IP_CTYP__ 
    *tbl_ip_lo_ptr, *tbl_ip_hi_ptr  
  ;
#if ___IP_VERSION_NUM__==61
  int tbl_ip_len           = tree->nip;  
  int tbl_ip_lo_ptr_ip_len = tree->nip;  
  int tbl_ip_hi_ptr_ip_len = tree->nip;  
#endif
   
  ___IP_IP_TYP__ 
    mn, mx
  ;
   
  int 
     *tbl_ip_idxptr
    , idx, mid, isleaf, ml=0,mr=0,m=0
  ;
 
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
   
  tbl_ip_idxptr = tree->ip_idxPtr;
   
  idx = tree->minmx_ptr[ mid ] ;

  ___IP_GET__( mn, tbl_ip_lo_ptr,   idx  );
   
  idx = tree->minmx_ptr[ mid + tree->nip ] ;
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s idx:%d\n", tree->depth, "", idx);
#endif

  ___IP_GET__( mx, tbl_ip_hi_ptr,  idx  );
#ifdef BSEARCH_INTV_DBG
 
Rprintf( "%*s tbl-idx:%d\n", tree->depth, "",  idx );  
 
 
#endif
  
   
  ___IP_IPr_GET__( tbl, mid)
  
#if 0  
  RIP_ipv6r_Rprintf_0(x);Rprintf(" ");RIP_ipv6r_Rprintf_0(___IP_GET_LO(x));Rprintf("\n");
  RIP_ipv6r_Rprintf_0(tbl_ip_elt_ptr);Rprintf("\n");
  RIP_ipv6_Rprintf_0(&mn);Rprintf("\n");
  RIP_ipv6_Rprintf_0(&mx);Rprintf("\n");
  Rprintf("cond: %d %d\n", ( ___IP_GT__( ___IP_GET_LO(x), mx ) ) , ( ___IP_LT__( ___IP_GET_LO(x), mn ) ) );
#endif

   
  if(  
     
    ( ___IP_GT__( ___IP_GET_LO(x), mx ) ) || ( ___IP_LT__( ___IP_GET_HI(x), mn ) )
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
    ml = ___IP_MATCH_VISIT_FN__(x, lo, mid -1L, tree);
  }
  
   
  if(
    ___IP_MATCH_FN__(x, tbl_ip_elt_ptr)  
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
         
        Rf_error("matchPtr realloc");
      }
Rprintf("realloc: %d %d\n", tree->nmatch, n);
      tree->nmatch = n;
    }
     
    tree->match_ptr[ *tree->nmatch_acc ] = tbl_ip_idxptr[ mid ];  
     
    (*tree->nmatch_acc)++;
     
    m = 1;
  }
  
   
  if(
     
     (!isleaf)  
  ){
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s right\n", tree->depth, "");
#endif
    mr = ___IP_MATCH_VISIT_FN__(x, mid+1L, hi, tree);
  }
  else{
#ifdef BSEARCH_INTV_DBG
Rprintf("%*s !right\n", tree->depth, "");
#endif
  }
#ifdef BSEARCH_INTV_DBG
tree->depth--;
#endif

   
  return ( ml | mr ) | m;

#elif defined( ___IP_BSEARCH_INTV_MATCH_BODY__ )
 
   
  SEXP Rmatch, Rmatch_ptr; 
  int  nomatch;
  int *nmatch_acc;
  int  nprotected=0; 
#ifdef BSEARCH_INTV_DBG
Rprintf("start:\n");   
#endif
   
  ___IP_VAL_SLOTS_GET( Rip ) 
   
  ___IP_TBL_SLOTS_GET( RipTbl ) 
   
  RipTbl_nip+=0;
   
  int *idx_ptr    =  INTEGER(Ridx); 
  int *minmx_ptr  =  INTEGER(Rminmx); 
  nomatch    = *INTEGER(Rnomatch); 

  ___IP_INTVTREE_CTYP__ tree;
   
  tree.nip       = RipTbl_nip;
  tree.tbl_loPtr = RipTbl_ip_lo_ptr;
  tree.tbl_hiPtr = RipTbl_ip_hi_ptr;
  tree.ip_idxPtr    = idx_ptr;
  tree.minmx_ptr = minmx_ptr;
   
  tree.nmatch = (int) ceil( ( (double) Rip_nip )*1.6);

  PROTECT( Rmatch_ptr = allocVector(INTSXP, Rip_nip+1 ) ); 
  nprotected++; 
  nmatch_acc    = (int*) INTEGER( Rmatch_ptr );
  nmatch_acc[0] = 0;
   
  tree.nmatch_acc = nmatch_acc;
   
  if( ( tree.match_ptr = (int*) malloc( sizeof(int) * tree.nmatch) )==NULL ){
    error("malloc");
  }
#ifdef BSEARCH_INTV_DBG
   
  tree.depth=-1;
Rprintf("iter:%d\n", tree.nmatch);   
#endif
   
  RipTbl_ip_idxptr+=0;  
   
  for( int i=0 ; i<Rip_nip ; i++ ){
     
    int tmp;
     
    while( (i<Rip_nip) && (Rip_ip_idxptr[i]==NA_INTEGER) ){ 

      tmp             = *tree.nmatch_acc++;
      *tree.nmatch_acc = tmp;
       
      ___IP_INTVTREE_REALLOC(&tree);
       
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
     
    ___IP_VAL_ELT_PTR_DCL( Rip, i)
     
    int m;
     
    m = ___IP_MATCH_VISIT_FN__(
        Rip_ip_elt_ptr
      , 0, RipTbl_nip-1
      , &tree
    );
     
    if( m==0 ){
 
       
      ___IP_INTVTREE_REALLOC(&tree);
       
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

#else 
 
 
#pragma error("undefined");
 
 
#endif  
 
