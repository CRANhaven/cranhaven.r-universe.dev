#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
#include <libopenmpt/libopenmpt_ext.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod) {
  if (TYPEOF(mod) != EXTPTRSXP || !Rf_inherits(mod, "openmpt"))
    cpp11::stop("`mod` should be and external pointer of class openmpt");
  module_ext * my_mod =
    reinterpret_cast<module_ext *>(R_ExternalPtrAddr(mod));
  if (!my_mod) cpp11::stop("Invalid pointer");
  return my_mod;
}

[[cpp11::register]]
bool test_get_mod(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod != NULL;
}
