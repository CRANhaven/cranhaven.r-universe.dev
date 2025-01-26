#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod); // specified in get_mod.cpp

[[cpp11::register]]
SEXP set_position_seconds_(SEXP mod, double secs) {
  module * my_mod = get_mod(mod);
  my_mod->set_position_seconds(secs);
  return mod;
}

[[cpp11::register]]
SEXP set_position_order_row_(SEXP mod, int order, int row) {
  module * my_mod = get_mod(mod);
  my_mod->set_position_order_row(order, row);
  return mod;
}
