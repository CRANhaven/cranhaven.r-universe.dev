#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod); // specified in get_mod.cpp
strings vector_to_strings(std::vector < std::string > v); //specified in helpers.cpp

[[cpp11::register]]
strings lompt_get_string_(const char * key) {
  r_string result(
      string::get(key)
  );
  return writable::strings(result);
}

[[cpp11::register]]
strings get_metadata_keys_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return vector_to_strings( my_mod->get_metadata_keys() );
}

[[cpp11::register]]
double get_duration_seconds_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_duration_seconds();
}

[[cpp11::register]]
double get_position_seconds_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_position_seconds();
}

[[cpp11::register]]
SEXP get_metadata_(SEXP mod, const char * key) {
  module * my_mod = get_mod(mod);
  r_string result(
      my_mod->get_metadata(key)
  );
  return writable::strings(result);
}

[[cpp11::register]]
int get_num_instruments_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_num_instruments();
}

[[cpp11::register]]
int get_num_samples_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_num_samples();
}

[[cpp11::register]]
int get_num_channels_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_num_channels();
}

[[cpp11::register]]
int get_num_orders_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_num_orders();
}

[[cpp11::register]]
int get_num_patterns_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_num_patterns();
}

[[cpp11::register]]
int get_num_subsongs_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_num_subsongs();
}

[[cpp11::register]]
int get_pattern_num_rows_(SEXP mod, int pattern) {
  module * my_mod = get_mod(mod);
  return my_mod->get_pattern_num_rows(pattern);
}

[[cpp11::register]]
int get_order_pattern_(SEXP mod, int order) {
  module * my_mod = get_mod(mod);
  return my_mod->get_order_pattern(order);
}
