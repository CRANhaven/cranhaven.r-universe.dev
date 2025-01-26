#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod); // specified in get_mod.cpp

[[cpp11::register]]
int get_repeat_count_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_repeat_count();
}

[[cpp11::register]]
SEXP set_repeat_count_(SEXP mod, int repeat_count) {
  module * my_mod = get_mod(mod);
  try {
    my_mod->set_repeat_count(repeat_count);
  } catch(...) {
    cpp11::stop("Failed to set repeat_count");
  }
  return mod;
}
