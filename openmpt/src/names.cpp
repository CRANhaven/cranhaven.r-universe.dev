#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod); // specified in get_mod.cpp
strings vector_to_strings(std::vector < std::string > v); //specified in helpers.cpp

[[cpp11::register]]
strings get_instrument_names_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return vector_to_strings( my_mod->get_instrument_names() );
}

[[cpp11::register]]
strings get_sample_names_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return vector_to_strings( my_mod->get_sample_names() );
}

[[cpp11::register]]
strings get_channel_names_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return vector_to_strings( my_mod->get_channel_names() );
}

[[cpp11::register]]
strings get_pattern_names_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return vector_to_strings( my_mod->get_pattern_names() );
}

[[cpp11::register]]
strings get_subsong_names_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return vector_to_strings( my_mod->get_subsong_names());
}

[[cpp11::register]]
strings get_order_names_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return vector_to_strings( my_mod->get_order_names() );
}
