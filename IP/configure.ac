AC_INIT([IP],[.0.1.1],[])

dnl set AVX2 flag
RIP_CFLAGS=
AC_ARG_ENABLE([avx2],
    AS_HELP_STRING([--enable-avx2], [compile with AVX2 support]))

AS_IF([test "x$enable_avx2" = "xyes"], [
  RIP_CFLAGS="-D__RIP_AVX2__ -march=native"
])

AC_MSG_NOTICE([RIP_CFLAGS: $RIP_CFLAGS])

## 
LIBIDN=
## 
## TODO: use pkg-config
## 
dnl Check IDN library availability
## 
AC_CHECK_LIB(idn, idna_to_ascii_8z, 
  [idn=1],
  [idn=0],
)

## 
if [[ "$idn" -eq 1 ]]; then
  echo "**** libidn found."
  LIBIDN="-lidn"
  RIP_CFLAGS="${RIP_CFLAGS} -D__RIP_IDN__"
else 
  echo "*** libidn not found."
  echo "*** Consider installing, e.g., libidn*-dev (Debian, Ubuntu)or  libidn-devel-* (RedHat, Fedora)"
  echo "*** then re-install package IP to enable IDN support"
fi

# AC_MSG_NOTICE([LIBIDN: $LIBIDN])

: ${R_HOME=`R RHOME`}

dnl R CC flags
CFLAGS=`"${R_HOME}/bin/R" CMD config CFLAGS`

dnl R linker flags
LDFLAGS=`"${R_HOME}/bin/R" CMD config LDFLAGS`

# PKG_CFLAGS=$CFLAGS
# PKG_LDFLAGS=$LDFLAGS

dnl substitute *FLAGS 
# AC_SUBST(CFLAGS)
# AC_SUBST(PKG_CFLAGS)
AC_SUBST(RIP_CFLAGS)
# AC_SUBST(LDFLAGS)
# AC_SUBST(PKG_LDFLAGS)
AC_SUBST(LIBIDN)

dnl then do subsitution in the Makevars.in 
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
