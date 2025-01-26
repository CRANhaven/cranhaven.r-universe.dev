#include <cpp11.hpp>
#include <sstream>
#include <libopenmpt/libopenmpt.hpp>
#include <libopenmpt/libopenmpt_ext.hpp>
using namespace cpp11;
using namespace openmpt;

void destroy_mod(module * m) {
  delete m;
  return;
}

[[cpp11::register]]
SEXP read_from_raw_(raws data) {
  const uint8_t * rdata = (const uint8_t *)RAW(as_sexp(data));
  
  module_ext * my_mod = new module_ext(rdata, data.size());

  external_pointer<module, destroy_mod>modptr(my_mod);
  sexp result = as_sexp(modptr);
  result.attr("class") = "openmpt";
  
  return result;
}
