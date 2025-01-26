#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod); // specified in get_mod.cpp

[[cpp11::register]]
int get_selected_subsong_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_selected_subsong();
}

[[cpp11::register]]
SEXP select_subsong_(SEXP mod, int subsong) {
  module * my_mod = get_mod(mod);
  try {
    my_mod->select_subsong(subsong);
  } catch(...) {
    cpp11::stop("Failed to select subsong");
  }
  return mod;
}
