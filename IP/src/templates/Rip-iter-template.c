 
 
#define ___RIP_MACRO_CAT2__(  ___IP_VERS__, ___MACRO_NAME__ ) \
   RIP## ___IP_VERS__ ## _ ## ___MACRO_NAME__ 
 
#define ___RIP_MACRO_CAT2( ___IP_VERS__, ___MACRO_NAME__ ) \
  ___RIP_MACRO_CAT2__( ___IP_VERS__, ___MACRO_NAME__ )

#if defined( ___IP_OP2_ARITH_BODY__)

#define ___MAKE_INDEX(___a__, ___b__, ___c__, ___d__, ___e__, ___f__, ___g__, ___h__) \
  ___a__ | ( ___b__ << 8 ) | ( ___c__ << 16 ) | ( ___d__ << 24 ) | ( ___e__ << 32 ) | ( ___f__ << 40 ) | ( ___g__ << 48 ) | ( ___h__ << 56 )

const int64_t mask_permTbl_Lo64x4[] = {
    ___MAKE_INDEX(0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(0L, 1L, 0L, 0L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(2L, 3L, 0L, 0L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(0L, 1L, 2L, 3L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(4L, 5L, 0L, 0L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(0L, 1L, 4L, 5L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(2L, 3L, 4L, 5L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(0L, 1L, 2L, 3L, 4L, 5L, 0L, 0L)
  , ___MAKE_INDEX(6L, 7L, 0L, 0L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(0L, 1L, 6L, 7L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(2L, 3L, 6L, 7L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(0L, 1L, 2L, 3L, 6L, 7L, 0L, 0L)
  , ___MAKE_INDEX(4L, 5L, 6L, 7L, 0L, 0L, 0L, 0L)
  , ___MAKE_INDEX(0L, 1L, 4L, 5L, 6L, 7L, 0L, 0L)
  , ___MAKE_INDEX(2L, 3L, 4L, 5L, 6L, 7L, 0L, 0L)
  , ___MAKE_INDEX(0L, 1L, 2L, 3L, 4L, 5L, 6L, 7L)
};
#undef ___MAKE_INDEX
 
#endif
 
 
#define RIP_NEXT_ALIGN(___ptr__, ___ty__, ___a__) \
  (___ty__*) ( ( (uintptr_t)  ___ptr__ + (___a__ - 1) ) & (uintptr_t) ~(___a__ - 1) )

#define RIPv4_LOAD(___ip1__,___ip2__, ___SUFF__, ___i__ ) \
    __m256i Rip1_##___SUFF__##_vip = _mm256_loadu_si256( (__m256i const *) & ___ip1__##_ip_ptr[___i__] ); \
    __m256i Rip2_##___SUFF__##_vip = _mm256_loadu_si256( (__m256i const *) & ___ip2__##_ip_ptr[___i__] ); 

#define RIPv4_LOAD_IDX(___ip1__,___ip2__, ___SUFF__, ___IDX1__, ___IDX2__) \
    __m256i Rip1_##___SUFF__##_vip = _mm256_i32gather_epi32( (int const *)  ___ip1__##_ip_ptr, ___IDX1__, 4 ); \
    __m256i Rip2_##___SUFF__##_vip = _mm256_i32gather_epi32( (int const *)  ___ip2__##_ip_ptr, ___IDX2__, 4 ); 

 
#define RIPv4_LOAD_IDX_MASK(___ip1__,___ip2__, ___SUFF__, ___IDX1__, ___IDX2__, ___SRC__, ___M__ ) \
    __m256i Rip1_##___SUFF__##_vip = _mm256_mask_i32gather_epi32( ___SRC__, (int const *)  ___ip1__##_ip_ptr, ___IDX1__, ___M__ , 4 ); \
    __m256i Rip2_##___SUFF__##_vip = _mm256_mask_i32gather_epi32( ___SRC__, (int const *)  ___ip2__##_ip_ptr, ___IDX2__, ___M__ , 4 ); 

#define RIPv4r_LOAD(___ip1__,___ip2__, ___SUFF__, ___i__ ) \
    __m256i Rip1_##___SUFF__##_vlo = _mm256_loadu_si256( (__m256i const *) &( ___ip1__##_ip_lo_ptr[___i__] )); \
    __m256i Rip1_##___SUFF__##_vhi = _mm256_loadu_si256( (__m256i const *) & ___ip1__##_ip_hi_ptr[___i__] ); \
    __m256i Rip2_##___SUFF__##_vlo = _mm256_loadu_si256( (__m256i const *) & ___ip2__##_ip_lo_ptr[___i__] ); \
    __m256i Rip2_##___SUFF__##_vhi = _mm256_loadu_si256( (__m256i const *) & ___ip2__##_ip_hi_ptr[___i__] ); 

#define RIPv4r_LOAD_IDX(___ip1__,___ip2__, ___SUFF__, ___IDX1__, ___IDX2__ ) \
    __m256i Rip1_##___SUFF__##_vlo = _mm256_i32gather_epi32( (int const *)  ___ip1__##_ip_lo_ptr, ___IDX1__, 4  ); \
    __m256i Rip1_##___SUFF__##_vhi = _mm256_i32gather_epi32( (int const *)  ___ip1__##_ip_hi_ptr, ___IDX1__, 4  ); \
    __m256i Rip2_##___SUFF__##_vlo = _mm256_i32gather_epi32( (int const *)  ___ip2__##_ip_lo_ptr, ___IDX2__, 4  ); \
    __m256i Rip2_##___SUFF__##_vhi = _mm256_i32gather_epi32( (int const *)  ___ip2__##_ip_hi_ptr, ___IDX2__, 4  ); 
    
 
#define RIPv4r_LOAD_IDX_MASK(___ip1__,___ip2__, ___SUFF__, ___IDX1__, ___IDX2__,  ___SRC__, ___M__  ) \
    __m256i Rip1_##___SUFF__##_vlo = _mm256_mask_i32gather_epi32( ___SRC__, (int const *)  ___ip1__##_ip_lo_ptr, ___IDX1__, ___M__ , 4  ); \
    __m256i Rip1_##___SUFF__##_vhi = _mm256_mask_i32gather_epi32( ___SRC__, (int const *)  ___ip1__##_ip_hi_ptr, ___IDX1__, ___M__ , 4  ); \
    __m256i Rip2_##___SUFF__##_vlo = _mm256_mask_i32gather_epi32( ___SRC__, (int const *)  ___ip2__##_ip_lo_ptr, ___IDX2__, ___M__ , 4  ); \
    __m256i Rip2_##___SUFF__##_vhi = _mm256_mask_i32gather_epi32( ___SRC__, (int const *)  ___ip2__##_ip_hi_ptr, ___IDX2__, ___M__ , 4  ); 

#define RIPv6_LOAD(___ip1__,___ip2__, ___SUFF__, ___i__ ) \
    __m256i Rip1_##___SUFF__##_vlo = _mm256_loadu_si256( (__m256i const *) &( ___ip1__##_ip_lo_ptr[___i__] )); \
    __m256i Rip1_##___SUFF__##_vhi = _mm256_loadu_si256( (__m256i const *) & ___ip1__##_ip_hi_ptr[___i__] ); \
    __m256i Rip2_##___SUFF__##_vlo = _mm256_loadu_si256( (__m256i const *) & ___ip2__##_ip_lo_ptr[___i__] ); \
    __m256i Rip2_##___SUFF__##_vhi = _mm256_loadu_si256( (__m256i const *) & ___ip2__##_ip_hi_ptr[___i__] ); 

#define RIPv6_LOAD_IDX(___ip1__,___ip2__, ___SUFF__, ___IDX1__, ___IDX2__ ) \
    __m256i Rip1_##___SUFF__##_vlo = _mm256_i32gather_epi64( (const long long int *)  ___ip1__##_ip_lo_ptr, ___IDX1__, 8 ); \
    __m256i Rip1_##___SUFF__##_vhi = _mm256_i32gather_epi64( (const long long int *)  ___ip1__##_ip_hi_ptr, ___IDX1__, 8  ); \
    __m256i Rip2_##___SUFF__##_vlo = _mm256_i32gather_epi64( (const long long int *)  ___ip2__##_ip_lo_ptr, ___IDX2__, 8  ); \
    __m256i Rip2_##___SUFF__##_vhi = _mm256_i32gather_epi64( (const long long int *)  ___ip2__##_ip_hi_ptr, ___IDX2__, 8  ); 

 
#define RIPv6_LOAD_IDX_MASK(___ip1__,___ip2__, ___SUFF__, ___IDX1__, ___IDX2__,  ___SRC__, ___M__ ) \
    __m256i Rip1_##___SUFF__##_vlo = _mm256_mask_i32gather_epi64( ___SRC__, (const long long int *)  ___ip1__##_ip_lo_ptr, ___IDX1__, ___M__, 8 ); \
    __m256i Rip1_##___SUFF__##_vhi = _mm256_mask_i32gather_epi64( ___SRC__, (const long long int *)  ___ip1__##_ip_hi_ptr, ___IDX1__, ___M__, 8  ); \
    __m256i Rip2_##___SUFF__##_vlo = _mm256_mask_i32gather_epi64( ___SRC__, (const long long int *)  ___ip2__##_ip_lo_ptr, ___IDX2__, ___M__, 8  ); \
    __m256i Rip2_##___SUFF__##_vhi = _mm256_mask_i32gather_epi64( ___SRC__, (const long long int *)  ___ip2__##_ip_hi_ptr, ___IDX2__, ___M__, 8  ); 

#define RIPv6r_LOAD(___ip1__,___ip2__, ___SUFF__, ___i__ ) \
    __m256i Rip1_##___SUFF__##_vlo_lo = _mm256_loadu_si256( (__m256i const *) & ___ip1__##_ip_lo_ptr[___i__ + ___ip1__##_ip_len ] ); \
    __m256i Rip1_##___SUFF__##_vlo_hi = _mm256_loadu_si256( (__m256i const *) & ___ip1__##_ip_lo_ptr[___i__ ] ); \
    __m256i Rip1_##___SUFF__##_vhi_lo = _mm256_loadu_si256( (__m256i const *) & ___ip1__##_ip_hi_ptr[___i__ + ___ip1__##_ip_len] ); \
    __m256i Rip1_##___SUFF__##_vhi_hi = _mm256_loadu_si256( (__m256i const *) & ___ip1__##_ip_hi_ptr[___i__ ] ); \
    __m256i Rip2_##___SUFF__##_vlo_lo = _mm256_loadu_si256( (__m256i const *) & ___ip2__##_ip_lo_ptr[___i__ + ___ip2__##_ip_len ] ); \
    __m256i Rip2_##___SUFF__##_vlo_hi = _mm256_loadu_si256( (__m256i const *) & ___ip2__##_ip_lo_ptr[___i__ ] ); \
    __m256i Rip2_##___SUFF__##_vhi_lo = _mm256_loadu_si256( (__m256i const *) & ___ip2__##_ip_hi_ptr[___i__ + ___ip2__##_ip_len] ); \
    __m256i Rip2_##___SUFF__##_vhi_hi = _mm256_loadu_si256( (__m256i const *) & ___ip2__##_ip_hi_ptr[___i__ ] ); 

#define RIPv6r_LOAD_IDX(___ip1__,___ip2__, ___SUFF__, ___IDX1__, ___IDX2__ ) \
    __m256i Rip1_##___SUFF__##_vlo_lo = _mm256_i32gather_epi64( (const long long int*) & ___ip1__##_ip_lo_ptr[___ip1__##_ip_len ], ___IDX1__, 8  ); \
    __m256i Rip1_##___SUFF__##_vlo_hi = _mm256_i32gather_epi64( (const long long int*)  ___ip1__##_ip_lo_ptr, ___IDX1__ , 8 ); \
    __m256i Rip1_##___SUFF__##_vhi_lo = _mm256_i32gather_epi64( (const long long int*) & ___ip1__##_ip_hi_ptr[ ___ip1__##_ip_len], ___IDX1__ , 8); \
    __m256i Rip1_##___SUFF__##_vhi_hi = _mm256_i32gather_epi64( (const long long int*)  ___ip1__##_ip_hi_ptr, ___IDX1__, 8  ); \
    __m256i Rip2_##___SUFF__##_vlo_lo = _mm256_i32gather_epi64( (const long long int*) & ___ip2__##_ip_lo_ptr[ ___ip2__##_ip_len ], ___IDX2__, 8 ); \
    __m256i Rip2_##___SUFF__##_vlo_hi = _mm256_i32gather_epi64( (const long long int*)  ___ip2__##_ip_lo_ptr, ___IDX2__, 8  ); \
    __m256i Rip2_##___SUFF__##_vhi_lo = _mm256_i32gather_epi64( (const long long int*) & ___ip2__##_ip_hi_ptr[ ___ip2__##_ip_len], ___IDX2__, 8 ); \
    __m256i Rip2_##___SUFF__##_vhi_hi = _mm256_i32gather_epi64( (const long long int*)  ___ip2__##_ip_hi_ptr, ___IDX2__, 8  ); 
    
 
#define RIPv6r_LOAD_IDX_MASK(___ip1__,___ip2__, ___SUFF__, ___IDX1__, ___IDX2__,  ___SRC__ , ___M__) \
    __m256i Rip1_##___SUFF__##_vlo_lo = _mm256_mask_i32gather_epi64(  ___SRC__, (const long long int*) & ___ip1__##_ip_lo_ptr[___ip1__##_ip_len ], ___IDX1__, ___M__, 8  ); \
    __m256i Rip1_##___SUFF__##_vlo_hi = _mm256_mask_i32gather_epi64(  ___SRC__, (const long long int*)  ___ip1__##_ip_lo_ptr, ___IDX1__ , ___M__, 8 ); \
    __m256i Rip1_##___SUFF__##_vhi_lo = _mm256_mask_i32gather_epi64(  ___SRC__, (const long long int*) & ___ip1__##_ip_hi_ptr[ ___ip1__##_ip_len], ___IDX1__ , ___M__, 8); \
    __m256i Rip1_##___SUFF__##_vhi_hi = _mm256_mask_i32gather_epi64(  ___SRC__, (const long long int*)  ___ip1__##_ip_hi_ptr, ___IDX1__, ___M__, 8  ); \
    __m256i Rip2_##___SUFF__##_vlo_lo = _mm256_mask_i32gather_epi64(  ___SRC__, (const long long int*) & ___ip2__##_ip_lo_ptr[ ___ip2__##_ip_len ], ___IDX2__, ___M__, 8 ); \
    __m256i Rip2_##___SUFF__##_vlo_hi = _mm256_mask_i32gather_epi64(  ___SRC__, (const long long int*)  ___ip2__##_ip_lo_ptr, ___IDX2__, ___M__, 8  ); \
    __m256i Rip2_##___SUFF__##_vhi_lo = _mm256_mask_i32gather_epi64(  ___SRC__, (const long long int*) & ___ip2__##_ip_hi_ptr[ ___ip2__##_ip_len], ___IDX2__, ___M__, 8 ); \
    __m256i Rip2_##___SUFF__##_vhi_hi = _mm256_mask_i32gather_epi64(  ___SRC__, (const long long int*)  ___ip2__##_ip_hi_ptr, ___IDX2__, ___M__, 8  ); 

#if 1
 
#define ___BITMASK_UNPACK_CONST__ \
  const unsigned long long bitmask_bool_selmask = 0x8080808080808080;  \
  const __m256i byte_unpack_shuffle = _mm256_set_epi8( \
       15, 15,  15,  15, \
       14, 14,  14,  14, \
        5,  5,   5,   5, \
        4,  4,   4,   4, \
       11, 11,  11,  11, \
       10, 10,  10,  10, \
        1,  1,   1,   1, \
        0,  0,   0,   0 \
  );
  
 
#define ___IP_SIMD_TBL_UNPACK_BYTE( ___bitmask__ ) \
    _mm256_shuffle_epi8(_mm256_set1_epi64x( ___bitmask__), byte_unpack_shuffle)
    
 
#define ___IP_SIMD_TBL_UNPACK_BYTE_RSLI( ___bitmask__, ___RS__  ) \
  _mm256_srli_epi32(___IP_SIMD_TBL_UNPACK_BYTE(___bitmask__), ___RS__)
    
 
#define ___IP_SIMD_BITMASK_UNPACK_BYTE( ___bitmask__ ) \
  _mm256_shuffle_epi8(_mm256_set1_epi64x( _pdep_u64(___bitmask__, bitmask_bool_selmask)), byte_unpack_shuffle)
 
#define ___IP_SIMD_BITMASK_UNPACK_BYTE_RSLI( ___bitmask__, ___RS__ ) \
  _mm256_srli_epi32(___IP_SIMD_BITMASK_UNPACK_BYTE(___bitmask__), ___RS__)
   
  #if 0
     
    #define ___IP_SIMD_BITMASK_UNPACK_BOOL bitmask_unpack_bool0
  #else
     
    #define ___IP_SIMD_BITMASK_UNPACK_BOOL( ___bitmask__ ) \
      ___IP_SIMD_BITMASK_UNPACK_BYTE_RSLI(___bitmask__, 31)
     
  #endif 
 
#endif  

 
#if 0
 
#define ___IP_SIMD_STORE_BOOL(___res__, ___bitmask__) \
  _mm256_storeu_si256( \
    (__m256i *) ___res__ \
    , _mm256_set_epi32( \
        ( ___bitmask__ & ( 1 << 7 ) ) >> 7 \
      , ( ___bitmask__ & ( 1 << 6 ) ) >> 6 \
      , ( ___bitmask__ & ( 1 << 5 ) ) >> 5 \
      , ( ___bitmask__ & ( 1 << 4 ) ) >> 4 \
      , ( ___bitmask__ & ( 1 << 3 ) ) >> 3 \
      , ( ___bitmask__ & ( 1 << 2 ) ) >> 2 \
      , ( ___bitmask__ & ( 1 << 1 ) ) >> 1 \
      , ( ___bitmask__ & ( 1      ) ) \
    ) \
  );
#else 
 
#define ___IP_SIMD_STORE_BOOL(___res__, ___bitmask__) \
  _mm256_storeu_si256( \
    (__m256i *) ___res__ \
    , ___IP_SIMD_BITMASK_UNPACK_BOOL( ___bitmask__ ) \
  );
 
#endif 

 
#if 0
 
#define ___IP_SIMD_STORE_IDX(___res__, ___i__, ___mask__ ) \
  _mm256_storeu_si256( \
    (__m256i *) &___res__##_ip_idxptr[___i__] \
    , _mm256_set_epi32( \
        ( ___mask__ & ( 1 << 7 ) ) >> 7 \
      , ( ___mask__ & ( 1 << 6 ) ) >> 6 \
      , ( ___mask__ & ( 1 << 5 ) ) >> 5 \
      , ( ___mask__ & ( 1 << 4 ) ) >> 4 \
      , ( ___mask__ & ( 1 << 3 ) ) >> 3 \
      , ( ___mask__ & ( 1 << 2 ) ) >> 2 \
      , ( ___mask__ & ( 1 << 1 ) ) >> 1 \
      , ( ___mask__ & ( 1      ) ) \
    ) \
  );
#elif 0
 
#define ___IP_SIMD_STORE_IDX(___res__, ___i__, ___mask__) \
{ \
 \
  int a0, a1, a2, a3, a4, a5, a6, a7 ; \
  int b0, b1, b2, b3, b4, b5, b6, b7 ; \
  __m256i idx ; \
  b0 = ___res__##_ip_idx += (a0 =  ( ___mask__ & ( 1      ) )   ); \
  b1 = ___res__##_ip_idx += (a1 = (( ___mask__ & ( 1 << 1 ) ) >> 1 ) ); \
  b2 = ___res__##_ip_idx += (a2 = (( ___mask__ & ( 1 << 2 ) ) >> 2 ) ); \
  b3 = ___res__##_ip_idx += (a3 = (( ___mask__ & ( 1 << 3 ) ) >> 3 ) ); \
  b4 = ___res__##_ip_idx += (a4 = (( ___mask__ & ( 1 << 4 ) ) >> 4 ) ); \
  b5 = ___res__##_ip_idx += (a5 = (( ___mask__ & ( 1 << 5 ) ) >> 5 ) ); \
  b6 = ___res__##_ip_idx += (a6 = (( ___mask__ & ( 1 << 6 ) ) >> 6 ) ); \
  b7 = ___res__##_ip_idx += (a7 = (( ___mask__ & ( 1 << 7 ) ) >> 7 ) ); \
  idx = _mm256_set_epi32(b7, b6, b5, b4, b3, b2, b1, b0  ); \
  \
  \
 \
  __m256i mask = _mm256_cmpeq_epi32( \
      _mm256_set_epi32(a7, a6, a5, a4, a3, a2, a1, a0  ) \
    , _mm256_set1_epi32(1) \
  ); \
 \
  _mm256_storeu_si256( \
    (__m256i *) &___res__##_ip_idxptr[___i__] \
    , _mm256_castps_si256(_mm256_blendv_ps( \
        _mm256_castsi256_ps(_mm256_set1_epi32(NA_INTEGER)) \
      , _mm256_castsi256_ps(idx) \
      , _mm256_castsi256_ps( mask ) \
    )) \
  ); \
}
#else

 
#define ___IP_SIMD_STORE_IDX(___res__, ___i__, ___mask__) \
{ \
  __m256i mask = ___IP_SIMD_BITMASK_UNPACK_BYTE(___mask__ ); \
  __m256i idx = Rippaddr_i32x4_csum_0( _mm256_srli_epi32(mask, 31) ); \
  idx = _mm256_add_epi32(idx, offset); \
  __m256i a0 = _mm256_permute2f128_si256(idx, idx, 0x11); \
  offset = _mm256_castps_si256( _mm256_permute_ps(_mm256_castsi256_ps(a0), 0xff) ); \
  \
  \
  _mm256_storeu_si256( \
    (__m256i *) &___res__##_ip_idxptr[___i__] \
    , _mm256_castps_si256(_mm256_blendv_ps( \
        _mm256_castsi256_ps(_mm256_set1_epi32(NA_INTEGER)) \
      , _mm256_castsi256_ps(_mm256_add_epi32(idx, mone)) \
      , _mm256_castsi256_ps( mask ) \
    )) \
  ); \
}
#endif

#define ___IP_SIMD_STORE_IDX_1(___res__, ___i__, ___offset__, ___mask__) \
{ \
 \
  const __m256i unpackLoBitTbl_i32x8 = _mm256_set_epi8(  \
      0, 0,  0, 7,  \
      0, 0,  0, 6,  \
      0, 0,  0, 5,  \
      0, 0,  0, 4,  \
      0, 0,  0, 3,  \
      0, 0,  0, 2,  \
      0, 0,  0, 1,  \
      0, 0,  0, 0   \
  );\
  const __m256i unpackHiBitTbl_i32x8 =_mm256_set_epi8(  \
      7, 0, 0, 0,  \
      6, 0, 0, 0,  \
      5, 0, 0, 0,  \
      4, 0, 0, 0,  \
      3, 0, 0, 0,  \
      2, 0, 0, 0,  \
      1, 0, 0, 0,  \
      0, 0, 0, 0   \
  ); \
  __m256i idx =  _mm256_add_epi32( \
      _mm256_set1_epi32(___offset__)   \
    , _mm256_shuffle_epi8( \
      _mm256_set1_epi64x( invHiPermTbl8[___mask__] ) \
      , unpackLoBitTbl_i32x8 \
    ) \
  );  \
  __m256i cond = _mm256_shuffle_epi8( \
      _mm256_set1_epi64x( _pdep_u64(___mask__, 0x8080808080808080  )) \
      , unpackHiBitTbl_i32x8 \
    ); \
  _mm256_storeu_si256( \
    (__m256i *) &___res__##_ip_idxptr[___i__] \
    , _mm256_castps_si256(_mm256_blendv_ps( \
         _mm256_castsi256_ps( NA_INTEGER_i32x8 ) \
      ,  _mm256_castsi256_ps( idx ) \
      , _mm256_castsi256_ps( cond )     \
    )) \
  ); \
} 

 
#if 0
   
  #define RIPv6_SIMD_STORE_VALS(___ip__, ___i__, ___vals__, ___mask__ ) \
    _mm256_storeu_si256( \
      (__m256i *) &___ip__##_ip_lo_ptr[___i__] \
      , ___vals__##_vlo \
    ); \
    _mm256_storeu_si256( \
      (__m256i *) &___ip__##_ip_hi_ptr[___i__] \
      , ___vals__##_vhi \
    );
    
#elif 0
 
#define RIPv6_SIMD_STORE_VALS(___ip__, ___i__, ___vals__, ___mask__ ) \
  \
  _mm256_storeu_si256( \
    (__m256i *) &___ip__##_ip_lo_ptr[___i__] \
    , _mm256_permutevar8x32_epi32 ( \
      ___vals__##_vlo \
      , _mm256_set_epi32( \
          ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 56) ) >> 56 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 48) ) >> 48 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 40) ) >> 40 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 32) ) >> 32 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 24) ) >> 24 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 16) ) >> 16 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 8) ) >> 8 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL ) ) \
      ) \
    ) \
  ); \
  _mm256_storeu_si256( \
    (__m256i *) &___ip__##_ip_hi_ptr[___i__] \
    , _mm256_permutevar8x32_epi32 ( \
      ___vals__##_vhi \
      , _mm256_set_epi32( \
          ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 56) ) >> 56 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 48) ) >> 48 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 40) ) >> 40 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 32) ) >> 32 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 24) ) >> 24 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 16) ) >> 16 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL << 8) ) >> 8 \
        , ( mask_permTbl_Lo64x4[___mask__] & ( 0xfL ) ) \
      ) \
    ) \
  ); 
  
#else 
 
#define RIPv6_SIMD_STORE_VALS(___ip__, ___i__, ___vals__, ___mask__ ) \
{ \
__m256i p = _mm256_shuffle_epi8(_mm256_set1_epi64x( mask_permTbl_Lo64x4[___mask__]), byte_unpack_shuffle); \
 \
 \
p =  _mm256_srli_epi32(p, 24 ); \
  \
  _mm256_storeu_si256( \
    (__m256i *) &___ip__##_ip_lo_ptr[___i__] \
    , _mm256_permutevar8x32_epi32( \
      ___vals__##_vlo \
      , p \
    ) \
  ); \
  _mm256_storeu_si256( \
    (__m256i *) &___ip__##_ip_hi_ptr[___i__] \
    , _mm256_permutevar8x32_epi32 ( \
      ___vals__##_vhi \
      , p \
    ) \
  ); \
}

#endif

#define ___IP_SLOTS_GET   ___RIP_MACRO_CAT2( ___IP_VERSION__, SLOTS_GET )
 
#define ___IP_LEN_GET   ___RIP_MACRO_CAT2( ___IP_VERSION__, IP_LEN_GET )
 
#define ___IP_RIP_ALLOC ___RIP_MACRO_CAT2( ___IP_VERSION__, RIP_ALLOC )
 
 
#define ___IP_SLOTS_SET ___RIP_MACRO_CAT2( ___IP_VERSION__, SLOTS_SET )

 
#define ___IP_ELT_PTR_DCL ___RIP_MACRO_CAT2( ___IP_VERSION__, ELT_PTR_DCL )
 
#define ___IP_ITER_SET ___RIP_MACRO_CAT2( ___IP_VERSION__, ITER_SET )
 
#define ___IP_RES_DCL ___RIP_MACRO_CAT2( ___IP_VERSION__, RES_DCL )
 
#define ___IP_IS_NA_WARN_REPROTECT ___RIP_MACRO_CAT2( ___IP_VERSION__, IS_NA_WARN_REPROTECT )

 
#define ___IP_SIMD_LOAD ___RIP_MACRO_CAT2( ___IP_VERSION__, LOAD )
 
 
#define ___IP_SIMD_LOAD_IDX ___RIP_MACRO_CAT2( ___IP_VERSION__, LOAD_IDX )
 
#define ___IP_SIMD_LOAD_IDX_MASK ___RIP_MACRO_CAT2( ___IP_VERSION__, LOAD_IDX_MASK )

#define ___IP_SIMD_STORE_VALS ___RIP_MACRO_CAT2( ___IP_VERSION__, SIMD_STORE_VALS )

#if defined( ___IP_OP2_ARITH_BODY__)

  SEXP Res;  
  int nprotected=0, nip=0, i,i1,i2, dbg=1; 
 
  ___IP_SLOTS_GET( Rip1 ) 
  ___IP_SLOTS_GET( Rip2 ) 
    
  nip = ( ( Rip1_nip>0 ) & ( Rip2_nip >0 ) ) ? Rip1_nip> Rip2_nip ? Rip1_nip : Rip2_nip : 0; 
   
  ___IP_RIP_ALLOC(Res, nip) 
  if( nip<1 ){UNPROTECT(nprotected); ___IP_SLOTS_SET( Res ) return Res;}; 
   
  RIP_BEGIN 
  if(  
    (Rip1_nip==Rip2_nip) 
    && ( Rip1_nip==___IP_LEN_GET(Rip1) )  && ( ___IP_LEN_GET(Rip1)==___IP_LEN_GET(Rip2) )  
  ){ 
     
    int step=16;
     
    i = 0;
 
#if defined( __RIP_AVX2__) && defined(___SIMD_Fn__) 

    __m256i mone = _mm256_set1_epi32(-1); 
    __m256i offset = _mm256_setzero_si256();
     
    ___BITMASK_UNPACK_CONST__
     
    for(; i<nip-(nip%step); i+=step){
 
#if ___IP_VERSION_NUM__==41
       
      __m256i 
          res_x4_0_vlo, res_x4_0_vhi
        , res_x4_1_vlo, res_x4_1_vhi
         
         
      ;
       
      ___IP_SIMD_LOAD(Rip1, Rip2, 0, i) 
      ___IP_SIMD_LOAD(Rip1, Rip2, 1, i+8)

      int valid0 = ___SIMD_Fn__(
         Rip1_0, Rip2_0, &res_x4_0
      );  
       
      int valid1 = ___SIMD_Fn__(
         Rip1_1, Rip2_1, &res_x4_1
      );
       
      int valid01;
       
      valid01  = valid0 &= 0xf;
      valid1   = valid1 & 0xf ;
      valid01 |= valid1 << 4;
       
      ___IP_SIMD_STORE_IDX(Res, i  , valid01 )
       
      Res_ip_idx++;
      ___IP_SIMD_STORE_VALS( Res, Res_ip_idx  , res_x4_0, valid0)
      Res_ip_idx += __builtin_popcount(valid0);
      ___IP_SIMD_STORE_VALS( Res, Res_ip_idx , res_x4_1, valid1)
      Res_ip_idx += __builtin_popcount(valid1);
       
      Res_ip_idx--;
 
#elif ___IP_VERSION_NUM__==60 
       
      __m256i 
          res_x4_0_vlo, res_x4_0_vhi
        , res_x4_1_vlo, res_x4_1_vhi
        , res_x4_2_vlo, res_x4_2_vhi
        , res_x4_3_vlo, res_x4_3_vhi
      ;
       
       
      ___IP_SIMD_LOAD(Rip1, Rip2, 0, i) 
      ___IP_SIMD_LOAD(Rip1, Rip2, 1, i+4)
      ___IP_SIMD_LOAD(Rip1, Rip2, 2, i+8)
      ___IP_SIMD_LOAD(Rip1, Rip2, 3, i+12)
       
      int valid0 = ___SIMD_Fn__(
         Rip1_0, Rip2_0, &res_x4_0
      );  
       
      int valid1 = ___SIMD_Fn__(
         Rip1_1, Rip2_1, &res_x4_1
      );
       
      int valid2 = ___SIMD_Fn__(
         Rip1_2, Rip2_2, &res_x4_2
      );  
       
      int valid3 = ___SIMD_Fn__(
         Rip1_3, Rip2_3, &res_x4_3
      );

      int valid01, valid23;
       
      valid01  = valid0 &= 0xf;
      valid1   = valid1 & 0xf ;
      valid01 |= valid1 << 4;
       
      valid23  = valid2 &= 0xf;
      valid3   = valid3 & 0xf ;
      valid23 |= valid3 << 4;

#if 0
       
       
#elif 1
      ___IP_SIMD_STORE_IDX(Res, i  , valid01 )
      ___IP_SIMD_STORE_IDX(Res, i+8, valid23 )
 
 
#else  
       
      const __m256i NA_INTEGER_i32x8 = _mm256_set1_epi32(NA_INTEGER);
       
      #define ___PERM8_Hi_inv_Table__
      const uint64_t invHiPermTbl8[256] = {
        #include "Rip-common-tables.c"
      };
      #undef ___PERM8_Hi_inv_Table__
       
      ___IP_SIMD_STORE_IDX_1(Res, i  , ( Res_ip_idx+1 ), valid01 )
      ___IP_SIMD_STORE_IDX_1(Res, i+8, ( Res_ip_idx+1+__builtin_popcount( valid01 ) ), valid23 )
#endif
     
       
      Res_ip_idx++;
 
 
      ___IP_SIMD_STORE_VALS( Res, Res_ip_idx  , res_x4_0, valid0)
      Res_ip_idx += __builtin_popcount(valid0);
      ___IP_SIMD_STORE_VALS( Res, Res_ip_idx , res_x4_1, valid1)
      Res_ip_idx += __builtin_popcount(valid1);
      ___IP_SIMD_STORE_VALS( Res, Res_ip_idx , res_x4_2, valid2)
      Res_ip_idx += __builtin_popcount(valid2);
      ___IP_SIMD_STORE_VALS( Res, Res_ip_idx, res_x4_3, valid3)
      Res_ip_idx += __builtin_popcount(valid3);
       
      Res_ip_idx--;
 
 
#else  
 
#pragma error("unknown IP version");
 
#endif  
    }
     
 
#endif  
     
    for(; i < Rip1_nip; i++ ){ 
 
      ___IP_ELT_PTR_DCL(Rip1, i) 
      ___IP_ELT_PTR_DCL(Rip2, i) 
      ___IP_RES_DCL(res) 
      int valid = ___SCALAR_Fn__( 
         Rip1_ip_elt_ptr, Rip2_ip_elt_ptr, resptr 
      ); 
      if( valid ){ 
         ___IP_ITER_SET( Res, i, res) 
      } 
      else{ 
        Res_ip_idxptr[i] = NA_INTEGER; 
      } 
    } 
  }else{ 
 
     
    i=0;
 
#if  defined( __RIP_AVX2__) && defined(___SIMD_Fn__)
     
    if( (Rip1_nip==Rip2_nip) ){
 
       
      #define ___PERM8_Hi_inv_Table__
      const uint64_t invHiPermTbl8[256] = {
        #include "Rip-common-tables.c"
      };
      #undef ___PERM8_Hi_inv_Table__
       
      const __m256i one = _mm256_set1_epi32(1); 
      const __m256i NA_INTEGER_i32x8 = _mm256_set1_epi32(NA_INTEGER);
      const __m256i NA_INTEGER_i64x4 = _mm256_set1_epi64x(-1);
       
      ___BITMASK_UNPACK_CONST__
    __m256i mone = _mm256_set1_epi32(-1); 
    __m256i offset = _mm256_setzero_si256();
       
      const int step = 8;
       
      for(; i<nip-(nip%step); i+=step){
         
        __m256i Rip1_ip_vidx  = _mm256_loadu_si256( ( __m256i *) &Rip1_ip_idxptr[ i ]); 
        __m256i Rip2_ip_vidx  = _mm256_loadu_si256( ( __m256i *) &Rip2_ip_idxptr[ i ]); 
         
        __m256i vna1 = _mm256_cmpeq_epi32( Rip1_ip_vidx, NA_INTEGER_i32x8 );
        __m256i vna2 = _mm256_cmpeq_epi32( Rip2_ip_vidx, NA_INTEGER_i32x8 );
         
        __m256i vna  = _mm256_castps_si256(_mm256_or_ps( 
            _mm256_castsi256_ps( vna1 )
          , _mm256_castsi256_ps( vna2 )
        ));
         
        __m256i vnna =  _mm256_xor_si256 (vna, _mm256_set1_epi32(0xffffffff)); 
         
        int na  = _mm256_movemask_ps( _mm256_castsi256_ps(vna) );
        int nna =  ~na & ( ( 1 << 8) -1); 
         
        if( ( nna > 0 )  ){  

#if   ___IP_VERSION_NUM__==40 || ___IP_VERSION_NUM__==41 
#error "unimplemented" STRINGIFY(___IP_VERSION__) 

          ___IP_SIMD_LOAD_IDX_MASK(
            Rip1, Rip2, 0
            , Rip1_ip_vidx
            , Rip2_ip_vidx
            , NA_INTEGERx8, vnna
          );

          int64_t res0 = ___SIMD_Fn__(
             Rip1_0, Rip2_0
          ); 

#elif  ___IP_VERSION_NUM__==60 || ___IP_VERSION_NUM__==61 

          ___IP_SIMD_LOAD_IDX_MASK(
            Rip1, Rip2, 0
            , _mm256_extractf128_si256(Rip1_ip_vidx, 0)
            , _mm256_extractf128_si256(Rip2_ip_vidx, 0)
            , NA_INTEGER_i64x4
            , _mm256_slli_epi64( _mm256_cvtepu32_epi64( _mm256_extractf128_si256(vnna, 0) ), 63 )  
          );
 
          ___IP_SIMD_LOAD_IDX_MASK(
            Rip1, Rip2, 1
            , _mm256_extractf128_si256(Rip1_ip_vidx, 1)  
            , _mm256_extractf128_si256(Rip2_ip_vidx, 1)  
            , NA_INTEGER_i64x4  
            ,  _mm256_slli_epi64( _mm256_cvtepu32_epi64( _mm256_extractf128_si256(vnna, 1) ), 63 )   
          );
           
          __m256i 
              res_x4_0_vlo, res_x4_0_vhi
            , res_x4_1_vlo, res_x4_1_vhi
          ;
           
          int 
              res0, res00
            , res1, res01
          ;
           
          res0 = ___SIMD_Fn__(
             Rip1_0, Rip2_0, &res_x4_0
          ); 
           
          res1 = ___SIMD_Fn__(
             Rip1_1, Rip2_1, &res_x4_1
          ); 
#if 0  
Rippaddr_ipv6x4_Rprintf_0(Rip1_0_vlo, Rip1_0_vhi);Rprintf("\n");
Rippaddr_ipv6x4_Rprintf_0(Rip2_0_vlo, Rip2_0_vhi);Rprintf("\n");
Rippaddr_ipv6x4_Rprintf_0(res_x4_0_vlo, res_x4_0_vhi);Rprintf("\n");
Rippaddr_ipv6x4_Rprintf_0(Rip1_1_vlo, Rip1_1_vhi);Rprintf("\n");
Rippaddr_ipv6x4_Rprintf_0(Rip2_1_vlo, Rip2_1_vhi);Rprintf("\n");
Rippaddr_ipv6x4_Rprintf_0(res_x4_1_vlo, res_x4_1_vhi);Rprintf("\n");
#endif
 
           
          res0 = (
            ( res00 = (res0 & nna) & 0xF) |  ( res01 = (res1 & ( nna >> 4 ) ) & 0xF ) << 4
          );
 
           
          Res_ip_idx++;

          ___IP_SIMD_STORE_IDX_1(Res, i , (Res_ip_idx) , res0)
#if 0
 
Rprintf("\n");
Ripaddr_mm256i_i32_Rprintf_0(vna);Rprintf("\n");
Ripaddr_mm256i_i32_Rprintf_0(idx);Rprintf("\n");
Ripaddr_mm256i_i32_Rprintf_0(offset);Rprintf("\n");
Rprintf("  perm:%d\n" , invHiPermTbl8[res0] );
__m256i __idx =  _mm256_add_epi32(
    _mm256_shuffle_epi8(
      _mm256_set1_epi64x( invHiPermTbl8[res0])
       
      , _mm256_set_epi8( 
          0, 0,  0,   7, 
          0, 0,  0,   6, 
          0,  0,   0,   5, 
          0,  0,   0,   4, 
          0, 0,  0,   3, 
          0, 0,  0,   2, 
          0,  0,   0,   1, 
          0,  0,   0,   0 
      )
    )
    , offset
  ); 
__m256i __a0 = _mm256_permute2f128_si256(__idx, __idx, 0x11); 
Ripaddr_mm256i_i32_Rprintf_0(__idx);Rprintf("\n");
Ripaddr_mm256i_i32_Rprintf_0(__a0);Rprintf("\n");
Ripaddr_mm256i_i32_Rprintf_0(_mm256_castps_si256( _mm256_permute_ps(_mm256_castsi256_ps(__a0), 0xff) ) );Rprintf("\n");
#endif
          ___IP_SIMD_STORE_VALS( Res, Res_ip_idx , res_x4_0, res00 )
          Res_ip_idx += __builtin_popcount(res00);
          ___IP_SIMD_STORE_VALS( Res, Res_ip_idx , res_x4_1, res01 )
          Res_ip_idx += __builtin_popcount(res01);
           
          Res_ip_idx--;
 

#endif
        } else {  
 
           
          _mm256_storeu_si256( (__m256i *) & Res_ip_idxptr[i], NA_INTEGER_i32x8);
          
        } 
        
      }  
    }  
  
#endif  
 
     
    i1=i2=i;
    RIP_ITERATE_NEXT(nip, Rip1_nip, Rip2_nip){ 
     
     
      if( 
        ( Rip1_ip_idxptr[i1]==NA_INTEGER ) || ( Rip2_ip_idxptr[i2]==NA_INTEGER ) 
      ){ 
        Res_ip_idxptr[i] = NA_INTEGER; 
         
        continue; 
      } 
       
      ___IP_ELT_PTR_DCL(Rip1, i1) 
      ___IP_ELT_PTR_DCL(Rip2, i2) 
      ___IP_RES_DCL(res) 
      int valid = ___SCALAR_Fn__( 
         Rip1_ip_elt_ptr, Rip2_ip_elt_ptr, resptr 
      ); 
     
      if( valid ){ 
         ___IP_ITER_SET( Res, i, res) 
      } 
      else{ 
        Res_ip_idxptr[i] = NA_INTEGER; 
      } 
     
    }  
  } 
  RIP_END 
  ___IP_IS_NA_WARN_REPROTECT( Res, nip, STRINGIFY(___opname__) )   
  ___IP_SLOTS_SET( Res ) 
  RIP_IP_IDSLOT_CP(Res, Rip1 ) 
  RIP_IP_IDSLOT_CP(Res, Rip2 ) 
  UNPROTECT(nprotected); 
  return Res; 

#elif defined( ___IP_OP2_BOOL_BODY__)

  SEXP Res; 
  int nprotected=0, nip=0, i,i1,i2, *resptr, nres=0;   
  int idx1=-1, idx2=-1;  
   
  ___IP_SLOTS_GET( Rip1 ) 
  ___IP_SLOTS_GET( Rip2 ) 
   
  nip = ( (Rip1_nip >0) & (Rip2_nip>0) ) ? Rip1_nip > Rip2_nip ? Rip1_nip : Rip2_nip : 0; 
  
    
  PROTECT( Res = allocVector(LGLSXP, nip ) ); 
  nprotected++; 
  if( nip<1 ){UNPROTECT(nprotected); return Res;}; 
  resptr = INTEGER( Res ); 
  RIP_BEGIN 
  if(  
    (Rip1_nip==Rip2_nip) 
    && ( Rip1_nip==___IP_LEN_GET(Rip1) ) && ( ___IP_LEN_GET(Rip1)==___IP_LEN_GET(Rip2) )  
  ){
 
     
    i=0;
     
#if defined( __RIP_AVX2__) && defined(___SIMD_Fn__)
     
    int step=16;
 
 
#if 0
  const __m256 false = _mm256_castsi256_ps( _mm256_set1_epi32( 0x0 ) );
  const __m256 true  = _mm256_castsi256_ps( _mm256_set1_epi32( 0x1 )); 
#endif
     
    ___BITMASK_UNPACK_CONST__

    const int nstep = nip-(nip%step);
     
    for(; i<nstep; i+=step){
 
 
#if ___IP_VERSION_NUM__==40 || ___IP_VERSION_NUM__==41
       
      ___IP_SIMD_LOAD(Rip1, Rip2, 0, i)
      ___IP_SIMD_LOAD(Rip1, Rip2, 1, i+8)
       
      int res0 = ___SIMD_Fn__(
         Rip1_0, Rip2_0
      );  
       
      int res1 = ___SIMD_Fn__(
         Rip1_1, Rip2_1
      );
      ___IP_SIMD_STORE_BOOL(&resptr[i], res0)

      ___IP_SIMD_STORE_BOOL(&resptr[i+8], res1)

#elif ___IP_VERSION_NUM__==60 || ___IP_VERSION_NUM__==61
       
      ___IP_SIMD_LOAD(Rip1, Rip2, 0, i)
#if 1  
      ___IP_SIMD_LOAD(Rip1, Rip2, 1, i+4)
      ___IP_SIMD_LOAD(Rip1, Rip2, 2, i+8)
      ___IP_SIMD_LOAD(Rip1, Rip2, 3, i+12)
       
      int res0 = ___SIMD_Fn__(
         Rip1_0, Rip2_0
      );  
       
      int res1 = ___SIMD_Fn__(
         Rip1_1, Rip2_1
      );
       
      int res2 = ___SIMD_Fn__(
         Rip1_2, Rip2_2
      );  

      res0 = ( res0 & 0xF ) |  ( res1 & 0xF ) << 4;
      ___IP_SIMD_STORE_BOOL(&resptr[i], res0)

      int res3 = ___SIMD_Fn__(
         Rip1_3, Rip2_3
      );
       
      res2 = ( res2 & 0xF ) |  ( res3 & 0xF ) << 4;
      ___IP_SIMD_STORE_BOOL(&resptr[i+8], res2)

#else      
       
      __m256i res = ___SIMD_Fn__(
        Rip1_0, Rip2_0
        
        
      );
       
      resptr[i]   = res[0];
      resptr[i+1] = res[1];
      resptr[i+2] = res[2];
      resptr[i+3] = res[3];
 
#endif    
 
#else
 
#pragma error("unknown IP version");
 
#endif  
    }
 
#endif   
 
     
    for(;i<nip;i++){
      ___IP_ELT_PTR_DCL(Rip1, i) 
      ___IP_ELT_PTR_DCL(Rip2, i)
      resptr[i] = ___SCALAR_Fn__( 
         Rip1_ip_elt_ptr 
         , Rip2_ip_elt_ptr 
      ); 
    }
    
  }else{

    i=0;

#if defined( __RIP_AVX2__) && defined(___SIMD_Fn__)
     
    if( (Rip1_nip==Rip2_nip) ){  
 
       
      __m256i NA_INTEGER_i32x8     = _mm256_set1_epi32(NA_INTEGER);
#if   ___IP_VERSION_NUM__==60 || ___IP_VERSION_NUM__==61 
      __m256i NA_INTEGER_i64x4 = _mm256_set1_epi64x(-1);
#endif
       
      ___BITMASK_UNPACK_CONST__

      const int step = 8;
       
      const int nstep = nip-(nip%step);
      for(; i<nstep; i+=step){
         
        __m256i Rip1_ip_vidx  = _mm256_loadu_si256( ( __m256i *) &Rip1_ip_idxptr[ i ]); 
        __m256i Rip2_ip_vidx  = _mm256_loadu_si256( ( __m256i *) &Rip2_ip_idxptr[ i ]); 

        __m256i vna1 = _mm256_cmpeq_epi32( Rip1_ip_vidx, NA_INTEGER_i32x8 );
        __m256i vna2 = _mm256_cmpeq_epi32( Rip2_ip_vidx, NA_INTEGER_i32x8 );
 
 
        __m256i vna  = _mm256_castps_si256(_mm256_or_ps( 
            _mm256_castsi256_ps( vna1 )
          , _mm256_castsi256_ps( vna2 )
        ));
 
         
        __m256i vnna =  _mm256_xor_si256 (vna, _mm256_set1_epi32(0xffffffff));  
 
         
        int na  = _mm256_movemask_ps( _mm256_castsi256_ps(vna) );
        int nna =  ~na & ( ( 1 << 8) -1);  
 
#if 0
         
        if( nna == ( ( 1 << 8) -1) ){

          ___IP_SIMD_LOAD(Rip1, Rip2, 0, i_vip)
           
          int64_t res0 = ___SIMD_Fn__(
             Rip1_0, Rip2_0
          ); 
#if ___IP_VERSION_NUM__==60 || ___IP_VERSION_NUM__==61 
           
          ___IP_SIMD_LOAD(Rip1, Rip2, 3, i_vip+4)
           
          int64_t res3 = ___SIMD_Fn__(
             Rip1_3, Rip2_3
          );
           
          res0 = ( res0 & 0xF ) |  ( res3 & 0xF ) << 4 ;
#endif
           
          ___IP_SIMD_STORE_BOOL(&resptr[i], res0)
      
        } else 
#endif
        if( ( nna > 0 )  ){  

#if ___IP_VERSION_NUM__==40 || ___IP_VERSION_NUM__==41 

          ___IP_SIMD_LOAD_IDX_MASK(
            Rip1, Rip2, 0
            , Rip1_ip_vidx
            , Rip2_ip_vidx
            , NA_INTEGER_i32x8, vnna
          );

          int64_t res0 = ___SIMD_Fn__(
             Rip1_0, Rip2_0
          ); 

#elif ___IP_VERSION_NUM__==60 || ___IP_VERSION_NUM__==61 

          ___IP_SIMD_LOAD_IDX_MASK(
            Rip1, Rip2, 0
            , _mm256_extractf128_si256(Rip1_ip_vidx, 0)
            , _mm256_extractf128_si256(Rip2_ip_vidx, 0)
            , NA_INTEGER_i64x4
            , _mm256_slli_epi64( _mm256_cvtepu32_epi64( _mm256_extractf128_si256(vnna, 0) ), 63 )  

          );
 
          ___IP_SIMD_LOAD_IDX_MASK(
            Rip1, Rip2, 1
            , _mm256_extractf128_si256(Rip1_ip_vidx, 1)  
            , _mm256_extractf128_si256(Rip2_ip_vidx, 1)  
            , NA_INTEGER_i64x4  
            ,  _mm256_slli_epi64( _mm256_cvtepu32_epi64( _mm256_extractf128_si256(vnna, 1) ), 63 )   

          );
 
 
#if 0 
Rprintf("vnna: %u %\n", _mm256_movemask_ps( _mm256_castsi256_ps( vnna ) ) );
__m256i m = _mm256_shuffle_epi8(
    vnna
    , _mm256_set_epi8(
        15, 14, 13, 12, 15, 14, 13, 12
      , 11, 10,  9,  8, 11, 10,  9,  8
      ,  7,  6,  5,  4,  7,  6,  5,  4
      ,  3,  2,  1,  0,  3,  2,  1,  0
    )
  );
Rprintf("m0: %u %\n", _mm256_movemask_pd(_mm256_castsi256_pd( m )) );
RIP_mm256i_i64_Rprintf_0(m);Rprintf("\n");
RIP_mm256i_i64_Rprintf_0(
   _mm256_slli_epi64( _mm256_cvtepi32_epi64( _mm256_extractf128_si256(vnna, 0) ) , 63 )
);Rprintf("\n");
m = _mm256_shuffle_epi8(
    vnna
    , _mm256_set_epi8(
          31, 0, 0, 0, 0, 0, 0, 0
        , 27, 0, 0, 0, 0, 0, 0, 0
        , 23, 0, 0, 0, 0, 0, 0, 0
        , 19, 0, 0, 0, 0, 0, 0, 0
    )
  );
m= _mm256_permutevar8x32_epi32( vnna, _mm256_set_epi32(7, 7, 6, 6, 5, 5, 4, 4) );
Rprintf("m1: %u %\n", _mm256_movemask_pd(_mm256_castsi256_pd( m )) );
RIP_mm256i_i64_Rprintf_0(m);Rprintf("\n");
RIP_mm256i_i64_Rprintf_0(
   _mm256_slli_epi64( _mm256_cvtepi32_epi64( _mm256_extractf128_si256(vnna, 1) ) , 63 )
);Rprintf("\n");
#endif

          int64_t res0 = ___SIMD_Fn__(
             Rip1_0, Rip2_0
          ); 
           
          int64_t res1 = ___SIMD_Fn__(
             Rip1_1, Rip2_1
          ); 
 
           
          res0 = ( res0 & 0xF ) |  ( res1 & 0xF ) << 4;
#endif

          __m256i rv = _mm256_castps_si256(_mm256_blendv_ps(
              _mm256_castsi256_ps( ___IP_SIMD_BITMASK_UNPACK_BOOL( res0 ) )
            , _mm256_castsi256_ps(NA_INTEGER_i32x8)
            , _mm256_castsi256_ps(vna)
          ));
           
          _mm256_storeu_si256( (__m256i *) &resptr[i], rv);

#if 0
          
#if   ___IP_VERSION_NUM__==40 || ___IP_VERSION_NUM__==41 

          ___IP_SIMD_LOAD_MASK(Rip1, Rip2, 0, i_vip, vnna )

#elif ___IP_VERSION_NUM__==60 || ___IP_VERSION_NUM__==61 
           
          ___IP_SIMD_LOAD_MASK(
               Rip1, Rip2, 0,  i_vip
             
            , _mm256_cvtepu32_epi64(
              _mm256_extractf128_si256(vnna, 0)
            )
          )
#endif
           
           
          int64_t res0 = ___SIMD_Fn__(
             Rip1_0, Rip2_0
          ); 
 
#if ___IP_VERSION_NUM__==60 || ___IP_VERSION_NUM__==61  
           
          ___IP_SIMD_LOAD_MASK(
            Rip1, Rip2, 1, ( i_vip + __builtin_popcount(nna  & 0xF ) )
            , _mm256_cvtepu32_epi64(
              _mm256_extractf128_si256(vnna, 1)
            )
          )
           
          int64_t res1 = ___SIMD_Fn__(
             Rip1_1, Rip2_1
          );  
           
          res0 = ( res0 & 0xF ) |  ( res1 & 0xF ) << 4;
#endif
           
          res0 = _pext_u64(res0, nna);
Rprintf("res0:%d\n", res0);
           
           
          __m256i rv = _mm256_castps_si256(_mm256_blendv_ps(
              _mm256_castsi256_ps( ___IP_SIMD_BITMASK_UNPACK_BOOL( res0 ) )
            , _mm256_castsi256_ps(NA_INTEGERx8)
            , _mm256_castsi256_ps(vna)
          ));
Rprintf("%d %d %d %d %d %d %d %d\n", _mm256_extract_epi32(rv, 0),_mm256_extract_epi32(rv, 1), _mm256_extract_epi32(rv, 2), _mm256_extract_epi32(vna, 3), _mm256_extract_epi32(rv, 4), _mm256_extract_epi32(rv, 5), _mm256_extract_epi32(rv, 6), _mm256_extract_epi32(rv, 7));
          _mm256_storeu_si256( (__m256i *) &resptr[i], rv);
          
#endif  
           
        } else {  
 
           
          _mm256_storeu_si256( (__m256i *) &resptr[i], NA_INTEGER_i32x8);
           
          
        } 

      }  
 
    }
 
#endif  

    i1=i2=i;
    idx1=idx2=i-1;
    RIP_ITERATE_NEXT(nip, Rip1_nip, Rip2_nip){ 
      idx1 = (i1 == 0) ? 0 : idx1+1; 
      idx2 = (i2 == 0) ? 0 : idx2+1; 

#if 0
      if(  
           ( Rip1_ip_idxptr[i1]!=NA_INTEGER )  
        && ( Rip2_ip_idxptr[i2]!=NA_INTEGER ) 
      ){ 
        ___IP_ELT_PTR_DCL(Rip1, idx1) 
        ___IP_ELT_PTR_DCL(Rip2, idx2)
         
        resptr[i] = ___SCALAR_Fn__( 
           Rip1_ip_elt_ptr 
           , Rip2_ip_elt_ptr 
        );  
         
        nres++; 
         
        continue; 
      } 
       
      resptr[i] = NA_INTEGER; 
#else
      if(  
           ( Rip1_ip_idxptr[i1]==NA_INTEGER )  
        || ( Rip2_ip_idxptr[i2]==NA_INTEGER ) 
      ){ 
        resptr[i] = NA_INTEGER; 
        continue; 
      } 
      ___IP_ELT_PTR_DCL(Rip1, idx1) 
      ___IP_ELT_PTR_DCL(Rip2, idx2)
       
      resptr[i] = ___SCALAR_Fn__( 
         Rip1_ip_elt_ptr 
         , Rip2_ip_elt_ptr 
      );  
      nres++; 
       
#endif
    } 
 
 
  }
 
    
  RIP_END 
   
  RIP_Rvec_IDSLOT_CP(Res, Rip1 ) 
  RIP_Rvec_IDSLOT_CP(Res, Rip2 ) 
   
  UNPROTECT(nprotected); 
   
  return Res; 

#endif
 
 
#undef ___IP_SLOTS_GET
 
#undef ___IP_ELT_PTR_DCL
 
#undef ___IP_SIMD_LOAD
 
